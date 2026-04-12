#include "../Sources/Core/scheduler.h"

#include <stdio.h>
#include <stdlib.h>

int main(void) {
    process_t processes[] = {
        {1, "Safari", 0, 5, 3, 0, 0, 0, 0, -1, -1},
        {2, "Xcode", 1, 3, 1, 0, 0, 0, 0, -1, -1},
        {3, "Music", 2, 4, 2, 0, 0, 0, 0, -1, -1},
    };

    timeline_event_t *timeline = NULL;
    int timeline_count = 0;
    metrics_t metrics = {0};

    int result = schedule_processes(
        processes,
        3,
        ALGO_PRIORITY_P,
        2,
        &timeline,
        &timeline_count,
        &metrics
    );

    if (result != 0) {
        fprintf(stderr, "Scheduling failed: %d\n", result);
        return 1;
    }

    printf("Timeline:\n");
    for (int i = 0; i < timeline_count; i++) {
        printf("  PID %d (%s): %d -> %d\n",
               timeline[i].process_id,
               timeline[i].process_name,
               timeline[i].start_time,
               timeline[i].end_time);
    }

    printf("\nMetrics:\n");
    printf("  Avg Turnaround: %.2f\n", metrics.avg_turnaround_time);
    printf("  Avg Waiting: %.2f\n", metrics.avg_waiting_time);
    printf("  Avg Response: %.2f\n", metrics.avg_response_time);
    printf("  CPU Utilization: %.2f%%\n", metrics.cpu_utilization);
    printf("  Throughput: %.4f\n", metrics.throughput);
    printf("  Total Time: %d\n", metrics.total_time);
    printf("  Context Switches: %d\n", metrics.context_switches);

    free(timeline);
    return 0;
}
