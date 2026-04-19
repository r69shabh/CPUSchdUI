#include "metrics.h"

#include <string.h>

void calculate_metrics(
    const process_t *processes,
    int count,
    int context_switches,
    metrics_t *metrics
) {
    if (!metrics) {
        return;
    }

    (void)memset(metrics, 0, sizeof(*metrics));

    if (!processes || count <= 0) {
        return;
    }

    double total_turnaround = 0.0;
    double total_waiting = 0.0;
    double total_response = 0.0;
    int total_burst = 0;
    int max_completion = 0;

    for (int i = 0; i < count; i++) {
        total_turnaround += (double)processes[i].turnaround_time;
        total_waiting += (double)processes[i].waiting_time;
        total_response += (double)((processes[i].response_time < 0) ? 0 : processes[i].response_time);
        total_burst += processes[i].burst_time;

        if (processes[i].completion_time > max_completion) {
            max_completion = processes[i].completion_time;
        }
    }

    metrics->avg_turnaround_time = total_turnaround / (double)count;
    metrics->avg_waiting_time = total_waiting / (double)count;
    metrics->avg_response_time = total_response / (double)count;

    metrics->total_time = max_completion;
    if (max_completion > 0) {
        metrics->cpu_utilization = ((double)total_burst / (double)max_completion) * 100.0;
        metrics->throughput = (double)count / (double)max_completion;
    }

    metrics->context_switches = (context_switches < 0) ? 0 : context_switches;
}
