#include "process_monitor.h"

#include "utils.h"

#include <string.h>

#if defined(__APPLE__)
#include <errno.h>
#include <libproc.h>
#include <pwd.h>
#include <stdlib.h>
#include <sys/proc.h>
#include <sys/sysctl.h>
#include <sys/time.h>
#endif

enum {
    MONITOR_OK = 0,
    MONITOR_ERR_ARGS = -1,
    MONITOR_ERR_SYSCTL = -2,
    MONITOR_ERR_ALLOC = -3,
    MONITOR_ERR_PROC = -4,
    MONITOR_ERR_UNSUPPORTED = -5
};

#if defined(__APPLE__)

static const char *status_to_string(int status) {
    switch (status) {
        case SIDL:
            return "idle";
        case SRUN:
            return "running";
        case SSLEEP:
            return "sleeping";
        case SSTOP:
            return "stopped";
        case SZOMB:
            return "zombie";
        default:
            return "unknown";
    }
}

static double cpu_usage_for_pid(pid_t pid) {
    struct proc_taskinfo task_info;
    int task_ret = proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &task_info, (int)sizeof(task_info));
    if (task_ret != (int)sizeof(task_info)) {
        return 0.0;
    }

    struct proc_bsdinfo bsd_info;
    int bsd_ret = proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &bsd_info, (int)sizeof(bsd_info));
    if (bsd_ret != (int)sizeof(bsd_info)) {
        return 0.0;
    }

    struct timeval now;
    if (gettimeofday(&now, NULL) != 0) {
        return 0.0;
    }

    uint64_t now_us = (uint64_t)now.tv_sec * 1000000ULL + (uint64_t)now.tv_usec;
    uint64_t start_us = (uint64_t)bsd_info.pbi_start_tvsec * 1000000ULL + (uint64_t)bsd_info.pbi_start_tvusec;
    if (now_us <= start_us) {
        return 0.0;
    }

    uint64_t elapsed_us = now_us - start_us;
    uint64_t total_ns = task_info.pti_total_user + task_info.pti_total_system;

    // Average CPU usage since process start.
    double scaled = ((double)total_ns / (double)(elapsed_us * 1000ULL)) * 100.0;

    if (scaled < 0.0) {
        scaled = 0.0;
    }
    if (scaled > 100.0) {
        scaled = 100.0;
    }
    return scaled;
}

static uint64_t memory_usage_for_pid(pid_t pid) {
    struct proc_taskinfo task_info;
    int ret = proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &task_info, (int)sizeof(task_info));
    if (ret != (int)sizeof(task_info)) {
        return 0U;
    }
    return task_info.pti_resident_size;
}

static uint32_t thread_count_for_pid(pid_t pid) {
    struct proc_taskinfo task_info;
    int ret = proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &task_info, (int)sizeof(task_info));
    if (ret != (int)sizeof(task_info)) {
        return 0U;
    }
    return task_info.pti_threadnum;
}

static void username_for_uid(uid_t uid, char *out_user, size_t out_size) {
    if (!out_user || out_size == 0U) {
        return;
    }

    struct passwd *pwd = getpwuid(uid);
    if (pwd && pwd->pw_name) {
        safe_copy_string(out_user, out_size, pwd->pw_name);
        return;
    }

    safe_copy_string(out_user, out_size, "unknown");
}

static uint64_t start_time_ms_from_bsdinfo(const struct proc_bsdinfo *bsd_info) {
    if (!bsd_info) {
        return 0U;
    }

    uint64_t seconds = (uint64_t)bsd_info->pbi_start_tvsec;
    uint64_t micros = (uint64_t)bsd_info->pbi_start_tvusec;
    return (seconds * 1000ULL) + (micros / 1000ULL);
}

static int fill_name(pid_t pid, const struct kinfo_proc *kproc, char *out_name, size_t out_name_size) {
    if (!out_name || out_name_size == 0U) {
        return MONITOR_ERR_ARGS;
    }

    char name_buf[MAX_PROCESS_NAME] = {0};
    int name_len = proc_name(pid, name_buf, (uint32_t)sizeof(name_buf));
    if (name_len > 0) {
        safe_copy_string(out_name, out_name_size, name_buf);
        return MONITOR_OK;
    }

    if (kproc) {
        safe_copy_string(out_name, out_name_size, kproc->kp_proc.p_comm);
        return MONITOR_OK;
    }

    safe_copy_string(out_name, out_name_size, "unknown");
    return MONITOR_OK;
}

static int build_process_list_from_pids(
    const pid_t *pids,
    int pid_count,
    system_process_t **processes,
    int *count
) {
    if (!pids || pid_count < 0 || !processes || !count) {
        return MONITOR_ERR_ARGS;
    }

    if (pid_count == 0) {
        *processes = NULL;
        *count = 0;
        return MONITOR_OK;
    }

    system_process_t *results = (system_process_t *)calloc((size_t)pid_count, sizeof(system_process_t));
    if (!results) {
        return MONITOR_ERR_ALLOC;
    }

    int out_count = 0;
    for (int i = 0; i < pid_count; i++) {
        if (pids[i] <= 0) {
            continue;
        }
        if (get_process_info(pids[i], &results[out_count]) == MONITOR_OK) {
            out_count++;
        }
    }

    if (out_count == 0) {
        free(results);
        *processes = NULL;
        *count = 0;
        return MONITOR_OK;
    }

    system_process_t *resized = (system_process_t *)realloc(results, (size_t)out_count * sizeof(system_process_t));
    if (resized) {
        results = resized;
    }

    *processes = results;
    *count = out_count;
    return MONITOR_OK;
}

static int get_all_processes_via_libproc(system_process_t **processes, int *count) {
    if (!processes || !count) {
        return MONITOR_ERR_ARGS;
    }

    int bytes = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0);
    if (bytes <= 0) {
        return MONITOR_ERR_PROC;
    }

    pid_t *pids = (pid_t *)malloc((size_t)bytes);
    if (!pids) {
        return MONITOR_ERR_ALLOC;
    }

    int filled = proc_listpids(PROC_ALL_PIDS, 0, pids, bytes);
    if (filled <= 0) {
        free(pids);
        return MONITOR_ERR_PROC;
    }

    int pid_count = filled / (int)sizeof(pid_t);
    int result = build_process_list_from_pids(pids, pid_count, processes, count);
    free(pids);
    return result;
}

#endif

int get_all_processes(system_process_t **processes, int *count) {
    if (!processes || !count) {
        return MONITOR_ERR_ARGS;
    }

    *processes = NULL;
    *count = 0;

#if !defined(__APPLE__)
    return MONITOR_ERR_UNSUPPORTED;
#else
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t size = 0;

    if (sysctl(mib, 4, NULL, &size, NULL, 0) != 0) {
        int fallback = get_all_processes_via_libproc(processes, count);
        return (fallback == MONITOR_OK) ? MONITOR_OK : MONITOR_ERR_SYSCTL;
    }

    struct kinfo_proc *kprocs = NULL;
    int got_list = 0;

    for (int attempt = 0; attempt < 3; attempt++) {
        kprocs = (struct kinfo_proc *)malloc(size);
        if (!kprocs) {
            return MONITOR_ERR_ALLOC;
        }

        size_t query_size = size;
        if (sysctl(mib, 4, kprocs, &query_size, NULL, 0) == 0) {
            size = query_size;
            got_list = 1;
            break;
        }

        int err = errno;
        free(kprocs);
        kprocs = NULL;

        if (err != ENOMEM) {
            int fallback = get_all_processes_via_libproc(processes, count);
            return (fallback == MONITOR_OK) ? MONITOR_OK : MONITOR_ERR_SYSCTL;
        }

        if (sysctl(mib, 4, NULL, &size, NULL, 0) != 0) {
            int fallback = get_all_processes_via_libproc(processes, count);
            return (fallback == MONITOR_OK) ? MONITOR_OK : MONITOR_ERR_SYSCTL;
        }
    }

    if (!got_list || !kprocs) {
        int fallback = get_all_processes_via_libproc(processes, count);
        return (fallback == MONITOR_OK) ? MONITOR_OK : MONITOR_ERR_SYSCTL;
    }

    int kproc_count = (int)(size / sizeof(struct kinfo_proc));
    if (kproc_count <= 0) {
        free(kprocs);
        int fallback = get_all_processes_via_libproc(processes, count);
        return (fallback == MONITOR_OK) ? MONITOR_OK : MONITOR_ERR_SYSCTL;
    }

    system_process_t *results = (system_process_t *)calloc((size_t)kproc_count, sizeof(system_process_t));
    if (!results) {
        free(kprocs);
        return MONITOR_ERR_ALLOC;
    }

    int out_count = 0;
    for (int i = 0; i < kproc_count; i++) {
        const struct kinfo_proc *kproc = &kprocs[i];
        pid_t pid = kproc->kp_proc.p_pid;
        if (pid <= 0) {
            continue;
        }

        system_process_t *dst = &results[out_count];
        if (get_process_info(pid, dst) == MONITOR_OK) {
            out_count++;
            continue;
        }

        // Fallback to sysctl-populated details if proc_pidinfo fails.
        dst->pid = pid;
        (void)fill_name(pid, kproc, dst->name, sizeof(dst->name));
        dst->cpu_usage = cpu_usage_for_pid(pid);
        dst->memory_usage = memory_usage_for_pid(pid);
        dst->thread_count = thread_count_for_pid(pid);
        username_for_uid(kproc->kp_eproc.e_ucred.cr_uid, dst->user, sizeof(dst->user));
        dst->priority = kproc->kp_proc.p_nice;
        dst->start_time_epoch_ms = 0U;
        safe_copy_string(dst->state, sizeof(dst->state), status_to_string(kproc->kp_proc.p_stat));

        struct proc_bsdinfo bsd_info;
        int bsd_ret = proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &bsd_info, (int)sizeof(bsd_info));
        if (bsd_ret == (int)sizeof(bsd_info)) {
            dst->start_time_epoch_ms = start_time_ms_from_bsdinfo(&bsd_info);
        }
        out_count++;
    }

    free(kprocs);

    if (out_count == 0) {
        free(results);
        return MONITOR_OK;
    }

    system_process_t *resized = (system_process_t *)realloc(results, (size_t)out_count * sizeof(system_process_t));
    if (resized) {
        results = resized;
    }

    *processes = results;
    *count = out_count;
    return MONITOR_OK;
#endif
}

int get_process_info(pid_t pid, system_process_t *process) {
    if (!process || pid <= 0) {
        return MONITOR_ERR_ARGS;
    }

#if !defined(__APPLE__)
    (void)pid;
    return MONITOR_ERR_UNSUPPORTED;
#else
    (void)memset(process, 0, sizeof(*process));

    struct proc_bsdinfo bsd_info;
    int ret = proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &bsd_info, (int)sizeof(bsd_info));
    if (ret != (int)sizeof(bsd_info)) {
        return MONITOR_ERR_PROC;
    }

    process->pid = pid;

    char name_buf[MAX_PROCESS_NAME] = {0};
    if (proc_name(pid, name_buf, (uint32_t)sizeof(name_buf)) > 0) {
        safe_copy_string(process->name, sizeof(process->name), name_buf);
    } else if (bsd_info.pbi_name[0] != '\0') {
        safe_copy_string(process->name, sizeof(process->name), bsd_info.pbi_name);
    } else {
        safe_copy_string(process->name, sizeof(process->name), "unknown");
    }

    process->cpu_usage = cpu_usage_for_pid(pid);
    process->memory_usage = memory_usage_for_pid(pid);
    process->thread_count = thread_count_for_pid(pid);
    username_for_uid(bsd_info.pbi_uid, process->user, sizeof(process->user));
    process->priority = bsd_info.pbi_nice;
    process->start_time_epoch_ms = start_time_ms_from_bsdinfo(&bsd_info);
    safe_copy_string(process->state, sizeof(process->state), status_to_string(bsd_info.pbi_status));

    return MONITOR_OK;
#endif
}

process_t system_to_schedulable_process(const system_process_t *sys_proc, int arrival_time) {
    process_t proc;
    (void)memset(&proc, 0, sizeof(proc));

    if (!sys_proc) {
        return proc;
    }

    proc.process_id = (int)sys_proc->pid;
    safe_copy_string(proc.name, sizeof(proc.name), sys_proc->name);
    proc.arrival_time = (arrival_time < 0) ? 0 : arrival_time;

    int burst_estimate = 1 + (int)(sys_proc->cpu_usage / 8.0);
    proc.burst_time = clamp_int(burst_estimate, 1, 20);

    int mapped_priority = 5;
    // Expected nice range is roughly [-20, 20], map to [1, 10].
    if (sys_proc->priority >= -20 && sys_proc->priority <= 20) {
        mapped_priority = 1 + ((sys_proc->priority + 20) * 9) / 40;
    }
    proc.priority = clamp_int(mapped_priority, 1, 10);

    proc.remaining_time = proc.burst_time;
    proc.completion_time = 0;
    proc.turnaround_time = 0;
    proc.waiting_time = 0;
    proc.response_time = -1;
    proc.first_run_time = -1;

    return proc;
}
