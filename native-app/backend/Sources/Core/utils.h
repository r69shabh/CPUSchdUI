#ifndef CPU_SCHEDULER_UTILS_H
#define CPU_SCHEDULER_UTILS_H

#include "process_types.h"
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

int clamp_int(int value, int min_value, int max_value);
void safe_copy_string(char *dst, size_t dst_size, const char *src);
void initialize_process_runtime_fields(process_t *processes, int count);

#ifdef __cplusplus
}
#endif

#endif // CPU_SCHEDULER_UTILS_H
