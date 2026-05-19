#ifndef PROCESS_TYPES_H
#define PROCESS_TYPES_H

#include <stdbool.h>
#include <stdint.h>
#include <sys/types.h>

#define MAX_PROCESS_NAME 256
#define MAX_PROCESS_STATE_NAME 32
#define MAX_PROCESS_USER_NAME 64

typedef enum {
    PROCESS_STATE_IDLE = 0,
    PROCESS_STATE_RUNNING = 1,
    PROCESS_STATE_SLEEPING = 2,
    PROCESS_STATE_STOPPED = 3,
    PROCESS_STATE_ZOMBIE = 4,
    PROCESS_STATE_UNKNOWN = 5
} process_state_t;

typedef enum {
    ALGO_FCFS = 0,
    ALGO_SJF = 1,
    ALGO_SRTF = 2,
    ALGO_RR = 3,
    ALGO_PRIORITY_NP = 4,
    ALGO_PRIORITY_P = 5
} algorithm_type_t;

typedef struct {
    int process_id;
    char name[MAX_PROCESS_NAME];
    int arrival_time;
    int burst_time;
    int priority;         // 1-10 (lower number = higher priority)
    int remaining_time;   // runtime field for preemptive algorithms

    int completion_time;
    int turnaround_time;
    int waiting_time;
    int response_time;
    int first_run_time;   // -1 if process has not started yet
} process_t;

typedef struct {
    pid_t pid;
    char name[MAX_PROCESS_NAME];
    double cpu_usage;                      // percentage [0, 100]
    uint64_t memory_usage;                 // bytes
    uint32_t thread_count;
    char user[MAX_PROCESS_USER_NAME];
    int priority;                          // system priority / nice value
    uint64_t start_time_epoch_ms;          // process start timestamp (epoch ms)
    char state[MAX_PROCESS_STATE_NAME];    // "running", "sleeping", ...
} system_process_t;

typedef struct {
    int process_id;
    char process_name[MAX_PROCESS_NAME];
    int start_time;
    int end_time;
} timeline_event_t;

typedef struct {
    double avg_turnaround_time;
    double avg_waiting_time;
    double avg_response_time;
    double cpu_utilization;
    double throughput;
    int total_time;
    int context_switches;
} metrics_t;

#endif // PROCESS_TYPES_H
