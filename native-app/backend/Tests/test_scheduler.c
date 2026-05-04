#include "../Sources/Core/scheduler.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

static process_t make_process(int id, const char *name, int arrival, int burst, int priority) {
    process_t p = {0};
    p.process_id = id;
    snprintf(p.name, sizeof(p.name), "%s", name);
    p.arrival_time = arrival;
    p.burst_time = burst;
    p.priority = priority;
    p.remaining_time = burst;
    p.first_run_time = -1;
    p.response_time = -1;
    return p;
}

static void test_fcfs(void) {
    process_t processes[] = {
        make_process(1, "P1", 0, 5, 3),
        make_process(2, "P2", 1, 3, 2),
        make_process(3, "P3", 2, 2, 1),
    };

    timeline_event_t *timeline = NULL;
    int timeline_count = 0;
    metrics_t metrics = {0};

    int result = schedule_processes(processes, 3, ALGO_FCFS, 0, &timeline, &timeline_count, &metrics);
    assert(result == 0);
    assert(processes[0].completion_time == 5);
    assert(processes[1].completion_time == 8);
    assert(processes[2].completion_time == 10);
    assert(timeline_count == 3);
    assert(metrics.context_switches == 2);
    free(timeline);
}

static void test_sjf(void) {
    process_t processes[] = {
        make_process(1, "P1", 0, 8, 1),
        make_process(2, "P2", 1, 4, 1),
        make_process(3, "P3", 2, 2, 1),
        make_process(4, "P4", 3, 1, 1),
    };

    timeline_event_t *timeline = NULL;
    int timeline_count = 0;
    metrics_t metrics = {0};

    int result = schedule_processes(processes, 4, ALGO_SJF, 0, &timeline, &timeline_count, &metrics);
    assert(result == 0);
    assert(processes[0].completion_time == 8);
    assert(processes[1].completion_time == 15);
    assert(processes[2].completion_time == 11);
    assert(processes[3].completion_time == 9);
    free(timeline);
}

static void test_srtf(void) {
    process_t processes[] = {
        make_process(1, "P1", 0, 8, 1),
        make_process(2, "P2", 1, 4, 1),
        make_process(3, "P3", 2, 2, 1),
    };

    timeline_event_t *timeline = NULL;
    int timeline_count = 0;
    metrics_t metrics = {0};

    int result = schedule_processes(processes, 3, ALGO_SRTF, 0, &timeline, &timeline_count, &metrics);
    assert(result == 0);
    assert(processes[0].completion_time == 14);
    assert(processes[1].completion_time == 7);
    assert(processes[2].completion_time == 4);
    assert(metrics.context_switches == 4);
    free(timeline);
}

static void test_round_robin(void) {
    process_t processes[] = {
        make_process(1, "P1", 0, 5, 1),
        make_process(2, "P2", 1, 3, 1),
        make_process(3, "P3", 2, 1, 1),
    };

    timeline_event_t *timeline = NULL;
    int timeline_count = 0;
    metrics_t metrics = {0};

    int result = schedule_processes(processes, 3, ALGO_RR, 2, &timeline, &timeline_count, &metrics);
    assert(result == 0);
    assert(processes[0].completion_time == 9);
    assert(processes[1].completion_time == 8);
    assert(processes[2].completion_time == 5);

    for (int i = 0; i < timeline_count; i++) {
        int duration = timeline[i].end_time - timeline[i].start_time;
        assert(duration > 0);
        assert(duration <= 2);
    }

    free(timeline);
}

static void test_priority_np(void) {
    process_t processes[] = {
        make_process(1, "P1", 0, 4, 3),
        make_process(2, "P2", 1, 3, 1),
        make_process(3, "P3", 2, 1, 2),
    };

    timeline_event_t *timeline = NULL;
    int timeline_count = 0;
    metrics_t metrics = {0};

    int result = schedule_processes(processes, 3, ALGO_PRIORITY_NP, 0, &timeline, &timeline_count, &metrics);
    assert(result == 0);
    assert(processes[0].completion_time == 4);
    assert(processes[1].completion_time == 7);
    assert(processes[2].completion_time == 8);
    free(timeline);
}

static void test_priority_p(void) {
    process_t processes[] = {
        make_process(1, "P1", 0, 4, 3),
        make_process(2, "P2", 1, 3, 1),
        make_process(3, "P3", 2, 1, 2),
    };

    timeline_event_t *timeline = NULL;
    int timeline_count = 0;
    metrics_t metrics = {0};

    int result = schedule_processes(processes, 3, ALGO_PRIORITY_P, 0, &timeline, &timeline_count, &metrics);
    assert(result == 0);
    assert(processes[0].completion_time == 8);
    assert(processes[1].completion_time == 4);
    assert(processes[2].completion_time == 5);
    assert(metrics.context_switches == 3);
    free(timeline);
}

int main(void) {
    test_fcfs();
    test_sjf();
    test_srtf();
    test_round_robin();
    test_priority_np();
    test_priority_p();

    printf("All scheduler tests passed.\n");
    return 0;
}
