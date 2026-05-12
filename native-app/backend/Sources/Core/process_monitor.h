#ifndef PROCESS_MONITOR_H
#define PROCESS_MONITOR_H

#include "process_types.h"

#ifdef __cplusplus
extern "C" {
#endif

int get_all_processes(system_process_t **processes, int *count);
int get_process_info(pid_t pid, system_process_t *process);
process_t system_to_schedulable_process(const system_process_t *sys_proc, int arrival_time);

#ifdef __cplusplus
}
#endif

#endif // PROCESS_MONITOR_H
