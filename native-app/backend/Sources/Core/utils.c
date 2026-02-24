#include "utils.h"

#include <string.h>

int clamp_int(int value, int min_value, int max_value) {
    if (value < min_value) {
        return min_value;
    }
    if (value > max_value) {
        return max_value;
    }
    return value;
}

void safe_copy_string(char *dst, size_t dst_size, const char *src) {
    if (!dst || dst_size == 0U) {
        return;
    }

    if (!src) {
        dst[0] = '\0';
        return;
    }

    (void)strncpy(dst, src, dst_size - 1U);
    dst[dst_size - 1U] = '\0';
}

void initialize_process_runtime_fields(process_t *processes, int count) {
    if (!processes || count <= 0) {
        return;
    }

    for (int i = 0; i < count; i++) {
        if (processes[i].burst_time < 0) {
            processes[i].burst_time = 0;
        }
        if (processes[i].arrival_time < 0) {
            processes[i].arrival_time = 0;
        }
        if (processes[i].priority <= 0) {
            processes[i].priority = 1;
        }

        processes[i].remaining_time = processes[i].burst_time;
        processes[i].completion_time = 0;
        processes[i].turnaround_time = 0;
        processes[i].waiting_time = 0;
        processes[i].response_time = -1;
        processes[i].first_run_time = -1;
    }
}
