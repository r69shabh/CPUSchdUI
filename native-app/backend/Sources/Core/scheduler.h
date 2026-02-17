#ifndef SCHEDULER_H
#define SCHEDULER_H

#include "process_types.h"

#ifdef __cplusplus
extern "C" {
#endif

int schedule_processes(
    process_t *processes,
    int process_count,
    algorithm_type_t algorithm,
    int time_quantum,
    timeline_event_t **timeline,
    int *timeline_count,
    metrics_t *metrics
);

int fcfs_schedule(process_t *processes, int count, timeline_event_t **timeline, int *timeline_count);
int sjf_schedule(process_t *processes, int count, timeline_event_t **timeline, int *timeline_count);
int srtf_schedule(process_t *processes, int count, timeline_event_t **timeline, int *timeline_count);
int round_robin_schedule(process_t *processes, int count, int quantum, timeline_event_t **timeline, int *timeline_count);
int priority_np_schedule(process_t *processes, int count, timeline_event_t **timeline, int *timeline_count);
int priority_p_schedule(process_t *processes, int count, timeline_event_t **timeline, int *timeline_count);

#ifdef __cplusplus
}
#endif

#endif // SCHEDULER_H
