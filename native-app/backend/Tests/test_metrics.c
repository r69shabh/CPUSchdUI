#include "../Sources/Core/metrics.h"

#include <assert.h>
#include <math.h>
#include <stdio.h>

static int approx_equal(double a, double b, double eps) {
    return fabs(a - b) <= eps;
}

int main(void) {
    process_t processes[2] = {0};

    processes[0].burst_time = 4;
    processes[0].completion_time = 4;
    processes[0].turnaround_time = 4;
    processes[0].waiting_time = 0;
    processes[0].response_time = 0;

    processes[1].burst_time = 3;
    processes[1].completion_time = 7;
    processes[1].turnaround_time = 6;
    processes[1].waiting_time = 3;
    processes[1].response_time = 3;

    metrics_t metrics;
    calculate_metrics(processes, 2, 1, &metrics);

    assert(approx_equal(metrics.avg_turnaround_time, 5.0, 1e-9));
    assert(approx_equal(metrics.avg_waiting_time, 1.5, 1e-9));
    assert(approx_equal(metrics.avg_response_time, 1.5, 1e-9));
    assert(approx_equal(metrics.cpu_utilization, 100.0, 1e-9));
    assert(approx_equal(metrics.throughput, 2.0 / 7.0, 1e-9));
    assert(metrics.total_time == 7);
    assert(metrics.context_switches == 1);

    printf("Metrics tests passed.\n");
    return 0;
}
