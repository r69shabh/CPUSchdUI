#include "scheduler.h"

#include "metrics.h"
#include "utils.h"

#include <limits.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

enum {
    SCHED_OK = 0,
    SCHED_ERR_ARGS = -1,
    SCHED_ERR_ALLOC = -2
};

typedef struct {
    timeline_event_t *events;
    int count;
    int capacity;
} timeline_builder_t;

typedef struct {
    int *items;
    int head;
    int tail;
    int size;
    int capacity;
} int_queue_t;

static int timeline_builder_init(timeline_builder_t *builder) {
    if (!builder) {
        return SCHED_ERR_ARGS;
    }
    builder->capacity = 64;
    builder->count = 0;
    builder->events = (timeline_event_t *)calloc((size_t)builder->capacity, sizeof(timeline_event_t));
    return builder->events ? SCHED_OK : SCHED_ERR_ALLOC;
}

static void timeline_builder_free(timeline_builder_t *builder) {
    if (!builder) {
        return;
    }
    free(builder->events);
    builder->events = NULL;
    builder->count = 0;
    builder->capacity = 0;
}

static int timeline_builder_grow(timeline_builder_t *builder) {
    int new_capacity = builder->capacity * 2;
    if (new_capacity < 0) {
        return SCHED_ERR_ALLOC;
    }

    timeline_event_t *resized = (timeline_event_t *)realloc(builder->events, (size_t)new_capacity * sizeof(timeline_event_t));
    if (!resized) {
        return SCHED_ERR_ALLOC;
    }

    builder->events = resized;
    builder->capacity = new_capacity;
    return SCHED_OK;
}

static int timeline_builder_add(
    timeline_builder_t *builder,
    int process_id,
    const char *process_name,
    int start_time,
    int end_time
) {
    if (!builder || !builder->events || !process_name || end_time <= start_time) {
        return SCHED_ERR_ARGS;
    }

    // Merge adjacent segments for the same process to avoid fake context switches.
    if (builder->count > 0) {
        timeline_event_t *last = &builder->events[builder->count - 1];
        if (last->process_id == process_id && last->end_time == start_time) {
            last->end_time = end_time;
            return SCHED_OK;
        }
    }

    if (builder->count == builder->capacity) {
        int grow_result = timeline_builder_grow(builder);
        if (grow_result != SCHED_OK) {
            return grow_result;
        }
    }

    timeline_event_t *event = &builder->events[builder->count++];
    event->process_id = process_id;
    safe_copy_string(event->process_name, sizeof(event->process_name), process_name);
    event->start_time = start_time;
    event->end_time = end_time;
    return SCHED_OK;
}

static int int_queue_init(int_queue_t *queue, int initial_capacity) {
    if (!queue || initial_capacity <= 0) {
        return SCHED_ERR_ARGS;
    }
    queue->items = (int *)malloc((size_t)initial_capacity * sizeof(int));
    if (!queue->items) {
        return SCHED_ERR_ALLOC;
    }
    queue->head = 0;
    queue->tail = 0;
    queue->size = 0;
    queue->capacity = initial_capacity;
    return SCHED_OK;
}

static void int_queue_free(int_queue_t *queue) {
    if (!queue) {
        return;
    }
    free(queue->items);
    queue->items = NULL;
    queue->head = 0;
    queue->tail = 0;
    queue->size = 0;
    queue->capacity = 0;
}

static int int_queue_grow(int_queue_t *queue) {
    int new_capacity = queue->capacity * 2;
    int *new_items = (int *)malloc((size_t)new_capacity * sizeof(int));
    if (!new_items) {
        return SCHED_ERR_ALLOC;
    }

    for (int i = 0; i < queue->size; i++) {
        new_items[i] = queue->items[(queue->head + i) % queue->capacity];
    }

    free(queue->items);
    queue->items = new_items;
    queue->capacity = new_capacity;
    queue->head = 0;
    queue->tail = queue->size;
    return SCHED_OK;
}

static int int_queue_push(int_queue_t *queue, int value) {
    if (!queue || !queue->items) {
        return SCHED_ERR_ARGS;
    }
    if (queue->size == queue->capacity) {
        int grow_result = int_queue_grow(queue);
        if (grow_result != SCHED_OK) {
            return grow_result;
        }
    }

    queue->items[queue->tail] = value;
    queue->tail = (queue->tail + 1) % queue->capacity;
    queue->size++;
    return SCHED_OK;
}

static int int_queue_pop(int_queue_t *queue, int *value) {
    if (!queue || !value || queue->size == 0) {
        return SCHED_ERR_ARGS;
    }

    *value = queue->items[queue->head];
    queue->head = (queue->head + 1) % queue->capacity;
    queue->size--;
    return SCHED_OK;
}

static int int_queue_empty(const int_queue_t *queue) {
    return (!queue || queue->size == 0);
}

static int compare_by_arrival_then_id(const void *lhs, const void *rhs, void *ctx) {
    const process_t *processes = (const process_t *)ctx;
    int li = *(const int *)lhs;
    int ri = *(const int *)rhs;

    if (processes[li].arrival_time != processes[ri].arrival_time) {
        return processes[li].arrival_time - processes[ri].arrival_time;
    }
    return processes[li].process_id - processes[ri].process_id;
}

static void sort_indices_by_arrival_then_id(int *indices, int count, const process_t *processes) {
    if (!indices || !processes || count <= 1) {
        return;
    }

    for (int i = 1; i < count; i++) {
        int key = indices[i];
        int j = i - 1;
        while (j >= 0) {
            int cmp = compare_by_arrival_then_id(&key, &indices[j], (void *)processes);
            if (cmp >= 0) {
                break;
            }
            indices[j + 1] = indices[j];
            j--;
        }
        indices[j + 1] = key;
    }
}

static int find_next_arrival(const process_t *processes, const bool *completed, int count, int current_time) {
    int next_arrival = INT_MAX;
    for (int i = 0; i < count; i++) {
        if (!completed[i] && processes[i].remaining_time > 0 && processes[i].arrival_time > current_time) {
            if (processes[i].arrival_time < next_arrival) {
                next_arrival = processes[i].arrival_time;
            }
        }
    }
    return next_arrival;
}

static void finalize_completed_process(process_t *proc, int completion_time) {
    proc->remaining_time = 0;
    proc->completion_time = completion_time;
    proc->turnaround_time = completion_time - proc->arrival_time;
    proc->waiting_time = proc->turnaround_time - proc->burst_time;
    if (proc->waiting_time < 0) {
        proc->waiting_time = 0;
    }
    if (proc->response_time < 0) {
        proc->response_time = 0;
    }
}

static int init_timeline_out(timeline_event_t **timeline, int *timeline_count) {
    if (!timeline || !timeline_count) {
        return SCHED_ERR_ARGS;
    }
    *timeline = NULL;
    *timeline_count = 0;
    return SCHED_OK;
}

static int allocate_index_array(int count, int **indices_out) {
    if (!indices_out || count <= 0) {
        return SCHED_ERR_ARGS;
    }

    int *indices = (int *)malloc((size_t)count * sizeof(int));
    if (!indices) {
        return SCHED_ERR_ALLOC;
    }
    for (int i = 0; i < count; i++) {
        indices[i] = i;
    }
    *indices_out = indices;
    return SCHED_OK;
}

static int initial_current_time(const process_t *processes, int count) {
    int min_arrival = INT_MAX;
    for (int i = 0; i < count; i++) {
        if (processes[i].remaining_time > 0 && processes[i].arrival_time < min_arrival) {
            min_arrival = processes[i].arrival_time;
        }
    }
    if (min_arrival == INT_MAX) {
        return 0;
    }
    return (min_arrival < 0) ? 0 : min_arrival;
}

static int count_context_switches(const timeline_event_t *timeline, int timeline_count) {
    if (!timeline || timeline_count <= 1) {
        return 0;
    }

    int switches = 0;
    for (int i = 1; i < timeline_count; i++) {
        if (timeline[i].process_id != timeline[i - 1].process_id) {
            switches++;
        }
    }
    return switches;
}

static int build_and_return_timeline(
    timeline_builder_t *builder,
    timeline_event_t **timeline,
    int *timeline_count
) {
    if (!builder || !timeline || !timeline_count) {
        return SCHED_ERR_ARGS;
    }

    if (builder->count == 0) {
        *timeline = NULL;
        *timeline_count = 0;
        return SCHED_OK;
    }

    timeline_event_t *out = (timeline_event_t *)malloc((size_t)builder->count * sizeof(timeline_event_t));
    if (!out) {
        return SCHED_ERR_ALLOC;
    }

    (void)memcpy(out, builder->events, (size_t)builder->count * sizeof(timeline_event_t));
    *timeline = out;
    *timeline_count = builder->count;
    return SCHED_OK;
}

int fcfs_schedule(process_t *processes, int count, timeline_event_t **timeline, int *timeline_count) {
    if (!processes || count <= 0) {
        return SCHED_ERR_ARGS;
    }
    int init_result = init_timeline_out(timeline, timeline_count);
    if (init_result != SCHED_OK) {
        return init_result;
    }

    initialize_process_runtime_fields(processes, count);

    int *indices = NULL;
    if (allocate_index_array(count, &indices) != SCHED_OK) {
        return SCHED_ERR_ALLOC;
    }

    sort_indices_by_arrival_then_id(indices, count, processes);

    timeline_builder_t builder;
    if (timeline_builder_init(&builder) != SCHED_OK) {
        free(indices);
        return SCHED_ERR_ALLOC;
    }

    int current_time = 0;
    for (int n = 0; n < count; n++) {
        process_t *proc = &processes[indices[n]];

        if (current_time < proc->arrival_time) {
            current_time = proc->arrival_time;
        }

        if (proc->first_run_time < 0) {
            proc->first_run_time = current_time;
            proc->response_time = current_time - proc->arrival_time;
        }

        int start = current_time;
        int end = current_time + proc->burst_time;

        if (proc->burst_time > 0) {
            if (timeline_builder_add(&builder, proc->process_id, proc->name, start, end) != SCHED_OK) {
                timeline_builder_free(&builder);
                free(indices);
                return SCHED_ERR_ALLOC;
            }
        }

        current_time = end;
        finalize_completed_process(proc, current_time);
    }

    int result = build_and_return_timeline(&builder, timeline, timeline_count);
    timeline_builder_free(&builder);
    free(indices);
    return result;
}

int sjf_schedule(process_t *processes, int count, timeline_event_t **timeline, int *timeline_count) {
    if (!processes || count <= 0) {
        return SCHED_ERR_ARGS;
    }
    int init_result = init_timeline_out(timeline, timeline_count);
    if (init_result != SCHED_OK) {
        return init_result;
    }

    initialize_process_runtime_fields(processes, count);

    bool *completed = (bool *)calloc((size_t)count, sizeof(bool));
    if (!completed) {
        return SCHED_ERR_ALLOC;
    }

    int finished_count = 0;
    int current_time = initial_current_time(processes, count);

    // Mark zero-burst processes as completed at arrival time.
    for (int i = 0; i < count; i++) {
        if (processes[i].burst_time == 0) {
            processes[i].first_run_time = processes[i].arrival_time;
            processes[i].response_time = 0;
            finalize_completed_process(&processes[i], processes[i].arrival_time);
            completed[i] = true;
            finished_count++;
        }
    }

    timeline_builder_t builder;
    if (timeline_builder_init(&builder) != SCHED_OK) {
        free(completed);
        return SCHED_ERR_ALLOC;
    }

    while (finished_count < count) {
        int chosen = -1;
        int best_burst = INT_MAX;

        for (int i = 0; i < count; i++) {
            if (completed[i] || processes[i].arrival_time > current_time || processes[i].remaining_time <= 0) {
                continue;
            }

            bool better = false;
            if (processes[i].burst_time < best_burst) {
                better = true;
            } else if (processes[i].burst_time == best_burst && chosen >= 0 &&
                       processes[i].arrival_time < processes[chosen].arrival_time) {
                better = true;
            } else if (processes[i].burst_time == best_burst && chosen >= 0 &&
                       processes[i].arrival_time == processes[chosen].arrival_time &&
                       processes[i].process_id < processes[chosen].process_id) {
                better = true;
            }

            if (chosen < 0 || better) {
                chosen = i;
                best_burst = processes[i].burst_time;
            }
        }

        if (chosen < 0) {
            int next_arrival = find_next_arrival(processes, completed, count, current_time);
            if (next_arrival == INT_MAX) {
                break;
            }
            current_time = next_arrival;
            continue;
        }

        process_t *proc = &processes[chosen];
        if (proc->first_run_time < 0) {
            proc->first_run_time = current_time;
            proc->response_time = current_time - proc->arrival_time;
        }

        int start = current_time;
        int end = current_time + proc->burst_time;

        if (timeline_builder_add(&builder, proc->process_id, proc->name, start, end) != SCHED_OK) {
            timeline_builder_free(&builder);
            free(completed);
            return SCHED_ERR_ALLOC;
        }

        current_time = end;
        finalize_completed_process(proc, current_time);
        completed[chosen] = true;
        finished_count++;
    }

    int result = build_and_return_timeline(&builder, timeline, timeline_count);
    timeline_builder_free(&builder);
    free(completed);
    return result;
}

int srtf_schedule(process_t *processes, int count, timeline_event_t **timeline, int *timeline_count) {
    if (!processes || count <= 0) {
        return SCHED_ERR_ARGS;
    }
    int init_result = init_timeline_out(timeline, timeline_count);
    if (init_result != SCHED_OK) {
        return init_result;
    }

    initialize_process_runtime_fields(processes, count);

    bool *completed = (bool *)calloc((size_t)count, sizeof(bool));
    if (!completed) {
        return SCHED_ERR_ALLOC;
    }

    int finished_count = 0;
    int current_time = initial_current_time(processes, count);

    for (int i = 0; i < count; i++) {
        if (processes[i].burst_time == 0) {
            processes[i].first_run_time = processes[i].arrival_time;
            processes[i].response_time = 0;
            finalize_completed_process(&processes[i], processes[i].arrival_time);
            completed[i] = true;
            finished_count++;
        }
    }

    timeline_builder_t builder;
    if (timeline_builder_init(&builder) != SCHED_OK) {
        free(completed);
        return SCHED_ERR_ALLOC;
    }

    int running_index = -1;
    int segment_start = current_time;

    while (finished_count < count) {
        int chosen = -1;
        int best_remaining = INT_MAX;

        for (int i = 0; i < count; i++) {
            if (completed[i] || processes[i].arrival_time > current_time || processes[i].remaining_time <= 0) {
                continue;
            }

            bool better = false;
            if (processes[i].remaining_time < best_remaining) {
                better = true;
            } else if (processes[i].remaining_time == best_remaining && chosen >= 0 &&
                       processes[i].arrival_time < processes[chosen].arrival_time) {
                better = true;
            } else if (processes[i].remaining_time == best_remaining && chosen >= 0 &&
                       processes[i].arrival_time == processes[chosen].arrival_time &&
                       processes[i].process_id < processes[chosen].process_id) {
                better = true;
            }

            if (chosen < 0 || better) {
                chosen = i;
                best_remaining = processes[i].remaining_time;
            }
        }

        if (chosen < 0) {
            if (running_index >= 0 && segment_start < current_time) {
                if (timeline_builder_add(&builder,
                                         processes[running_index].process_id,
                                         processes[running_index].name,
                                         segment_start,
                                         current_time) != SCHED_OK) {
                    timeline_builder_free(&builder);
                    free(completed);
                    return SCHED_ERR_ALLOC;
                }
                running_index = -1;
            }

            int next_arrival = find_next_arrival(processes, completed, count, current_time);
            if (next_arrival == INT_MAX) {
                break;
            }
            current_time = next_arrival;
            segment_start = current_time;
            continue;
        }

        if (running_index != chosen) {
            if (running_index >= 0 && segment_start < current_time) {
                if (timeline_builder_add(&builder,
                                         processes[running_index].process_id,
                                         processes[running_index].name,
                                         segment_start,
                                         current_time) != SCHED_OK) {
                    timeline_builder_free(&builder);
                    free(completed);
                    return SCHED_ERR_ALLOC;
                }
            }

            running_index = chosen;
            segment_start = current_time;

            if (processes[chosen].first_run_time < 0) {
                processes[chosen].first_run_time = current_time;
                processes[chosen].response_time = current_time - processes[chosen].arrival_time;
            }
        }

        processes[chosen].remaining_time--;
        current_time++;

        if (processes[chosen].remaining_time == 0) {
            if (timeline_builder_add(&builder,
                                     processes[chosen].process_id,
                                     processes[chosen].name,
                                     segment_start,
                                     current_time) != SCHED_OK) {
                timeline_builder_free(&builder);
                free(completed);
                return SCHED_ERR_ALLOC;
            }

            finalize_completed_process(&processes[chosen], current_time);
            completed[chosen] = true;
            finished_count++;
            running_index = -1;
            segment_start = current_time;
        }
    }

    int result = build_and_return_timeline(&builder, timeline, timeline_count);
    timeline_builder_free(&builder);
    free(completed);
    return result;
}

int round_robin_schedule(process_t *processes, int count, int quantum, timeline_event_t **timeline, int *timeline_count) {
    if (!processes || count <= 0) {
        return SCHED_ERR_ARGS;
    }
    int init_result = init_timeline_out(timeline, timeline_count);
    if (init_result != SCHED_OK) {
        return init_result;
    }

    initialize_process_runtime_fields(processes, count);

    int safe_quantum = (quantum <= 0) ? 1 : quantum;

    int *arrival_order = NULL;
    if (allocate_index_array(count, &arrival_order) != SCHED_OK) {
        return SCHED_ERR_ALLOC;
    }

    sort_indices_by_arrival_then_id(arrival_order, count, processes);

    bool *completed = (bool *)calloc((size_t)count, sizeof(bool));
    bool *queued = (bool *)calloc((size_t)count, sizeof(bool));
    if (!completed || !queued) {
        free(arrival_order);
        free(completed);
        free(queued);
        return SCHED_ERR_ALLOC;
    }

    int_queue_t queue;
    if (int_queue_init(&queue, (count < 16) ? 16 : count * 2) != SCHED_OK) {
        free(arrival_order);
        free(completed);
        free(queued);
        return SCHED_ERR_ALLOC;
    }

    int finished_count = 0;
    for (int i = 0; i < count; i++) {
        if (processes[i].burst_time == 0) {
            processes[i].first_run_time = processes[i].arrival_time;
            processes[i].response_time = 0;
            finalize_completed_process(&processes[i], processes[i].arrival_time);
            completed[i] = true;
            finished_count++;
        }
    }

    int current_time = initial_current_time(processes, count);
    int next_arrival_idx = 0;

    // Prime queue with processes available at current_time.
    while (next_arrival_idx < count && processes[arrival_order[next_arrival_idx]].arrival_time <= current_time) {
        int proc_index = arrival_order[next_arrival_idx++];
        if (!completed[proc_index] && !queued[proc_index]) {
            if (int_queue_push(&queue, proc_index) != SCHED_OK) {
                int_queue_free(&queue);
                free(arrival_order);
                free(completed);
                free(queued);
                return SCHED_ERR_ALLOC;
            }
            queued[proc_index] = true;
        }
    }

    timeline_builder_t builder;
    if (timeline_builder_init(&builder) != SCHED_OK) {
        int_queue_free(&queue);
        free(arrival_order);
        free(completed);
        free(queued);
        return SCHED_ERR_ALLOC;
    }

    while (finished_count < count) {
        if (int_queue_empty(&queue)) {
            if (next_arrival_idx >= count) {
                break;
            }
            current_time = processes[arrival_order[next_arrival_idx]].arrival_time;
            while (next_arrival_idx < count && processes[arrival_order[next_arrival_idx]].arrival_time <= current_time) {
                int proc_index = arrival_order[next_arrival_idx++];
                if (!completed[proc_index] && !queued[proc_index]) {
                    if (int_queue_push(&queue, proc_index) != SCHED_OK) {
                        timeline_builder_free(&builder);
                        int_queue_free(&queue);
                        free(arrival_order);
                        free(completed);
                        free(queued);
                        return SCHED_ERR_ALLOC;
                    }
                    queued[proc_index] = true;
                }
            }
            continue;
        }

        int proc_index = -1;
        if (int_queue_pop(&queue, &proc_index) != SCHED_OK) {
            break;
        }
        queued[proc_index] = false;

        process_t *proc = &processes[proc_index];
        if (proc->remaining_time <= 0) {
            continue;
        }

        if (current_time < proc->arrival_time) {
            current_time = proc->arrival_time;
        }

        if (proc->first_run_time < 0) {
            proc->first_run_time = current_time;
            proc->response_time = current_time - proc->arrival_time;
        }

        int slice = (proc->remaining_time < safe_quantum) ? proc->remaining_time : safe_quantum;
        int start = current_time;
        int end = current_time + slice;

        if (timeline_builder_add(&builder, proc->process_id, proc->name, start, end) != SCHED_OK) {
            timeline_builder_free(&builder);
            int_queue_free(&queue);
            free(arrival_order);
            free(completed);
            free(queued);
            return SCHED_ERR_ALLOC;
        }

        current_time = end;
        proc->remaining_time -= slice;

        while (next_arrival_idx < count && processes[arrival_order[next_arrival_idx]].arrival_time <= current_time) {
            int arrived_index = arrival_order[next_arrival_idx++];
            if (!completed[arrived_index] && !queued[arrived_index] && processes[arrived_index].remaining_time > 0) {
                if (int_queue_push(&queue, arrived_index) != SCHED_OK) {
                    timeline_builder_free(&builder);
                    int_queue_free(&queue);
                    free(arrival_order);
                    free(completed);
                    free(queued);
                    return SCHED_ERR_ALLOC;
                }
                queued[arrived_index] = true;
            }
        }

        if (proc->remaining_time > 0) {
            if (int_queue_push(&queue, proc_index) != SCHED_OK) {
                timeline_builder_free(&builder);
                int_queue_free(&queue);
                free(arrival_order);
                free(completed);
                free(queued);
                return SCHED_ERR_ALLOC;
            }
            queued[proc_index] = true;
        } else {
            finalize_completed_process(proc, current_time);
            completed[proc_index] = true;
            finished_count++;
        }
    }

    int result = build_and_return_timeline(&builder, timeline, timeline_count);
    timeline_builder_free(&builder);
    int_queue_free(&queue);
    free(arrival_order);
    free(completed);
    free(queued);
    return result;
}

int priority_np_schedule(process_t *processes, int count, timeline_event_t **timeline, int *timeline_count) {
    if (!processes || count <= 0) {
        return SCHED_ERR_ARGS;
    }
    int init_result = init_timeline_out(timeline, timeline_count);
    if (init_result != SCHED_OK) {
        return init_result;
    }

    initialize_process_runtime_fields(processes, count);

    bool *completed = (bool *)calloc((size_t)count, sizeof(bool));
    if (!completed) {
        return SCHED_ERR_ALLOC;
    }

    int finished_count = 0;
    int current_time = initial_current_time(processes, count);

    for (int i = 0; i < count; i++) {
        if (processes[i].burst_time == 0) {
            processes[i].first_run_time = processes[i].arrival_time;
            processes[i].response_time = 0;
            finalize_completed_process(&processes[i], processes[i].arrival_time);
            completed[i] = true;
            finished_count++;
        }
    }

    timeline_builder_t builder;
    if (timeline_builder_init(&builder) != SCHED_OK) {
        free(completed);
        return SCHED_ERR_ALLOC;
    }

    while (finished_count < count) {
        int chosen = -1;
        int best_priority = INT_MAX;

        for (int i = 0; i < count; i++) {
            if (completed[i] || processes[i].arrival_time > current_time || processes[i].remaining_time <= 0) {
                continue;
            }

            bool better = false;
            if (processes[i].priority < best_priority) {
                better = true;
            } else if (processes[i].priority == best_priority && chosen >= 0 &&
                       processes[i].arrival_time < processes[chosen].arrival_time) {
                better = true;
            } else if (processes[i].priority == best_priority && chosen >= 0 &&
                       processes[i].arrival_time == processes[chosen].arrival_time &&
                       processes[i].process_id < processes[chosen].process_id) {
                better = true;
            }

            if (chosen < 0 || better) {
                chosen = i;
                best_priority = processes[i].priority;
            }
        }

        if (chosen < 0) {
            int next_arrival = find_next_arrival(processes, completed, count, current_time);
            if (next_arrival == INT_MAX) {
                break;
            }
            current_time = next_arrival;
            continue;
        }

        process_t *proc = &processes[chosen];
        if (proc->first_run_time < 0) {
            proc->first_run_time = current_time;
            proc->response_time = current_time - proc->arrival_time;
        }

        int start = current_time;
        int end = current_time + proc->burst_time;

        if (timeline_builder_add(&builder, proc->process_id, proc->name, start, end) != SCHED_OK) {
            timeline_builder_free(&builder);
            free(completed);
            return SCHED_ERR_ALLOC;
        }

        current_time = end;
        finalize_completed_process(proc, current_time);
        completed[chosen] = true;
        finished_count++;
    }

    int result = build_and_return_timeline(&builder, timeline, timeline_count);
    timeline_builder_free(&builder);
    free(completed);
    return result;
}

int priority_p_schedule(process_t *processes, int count, timeline_event_t **timeline, int *timeline_count) {
    if (!processes || count <= 0) {
        return SCHED_ERR_ARGS;
    }
    int init_result = init_timeline_out(timeline, timeline_count);
    if (init_result != SCHED_OK) {
        return init_result;
    }

    initialize_process_runtime_fields(processes, count);

    bool *completed = (bool *)calloc((size_t)count, sizeof(bool));
    if (!completed) {
        return SCHED_ERR_ALLOC;
    }

    int finished_count = 0;
    int current_time = initial_current_time(processes, count);

    for (int i = 0; i < count; i++) {
        if (processes[i].burst_time == 0) {
            processes[i].first_run_time = processes[i].arrival_time;
            processes[i].response_time = 0;
            finalize_completed_process(&processes[i], processes[i].arrival_time);
            completed[i] = true;
            finished_count++;
        }
    }

    timeline_builder_t builder;
    if (timeline_builder_init(&builder) != SCHED_OK) {
        free(completed);
        return SCHED_ERR_ALLOC;
    }

    int running_index = -1;
    int segment_start = current_time;

    while (finished_count < count) {
        int chosen = -1;
        int best_priority = INT_MAX;

        for (int i = 0; i < count; i++) {
            if (completed[i] || processes[i].arrival_time > current_time || processes[i].remaining_time <= 0) {
                continue;
            }

            bool better = false;
            if (processes[i].priority < best_priority) {
                better = true;
            } else if (processes[i].priority == best_priority && chosen >= 0 &&
                       processes[i].remaining_time < processes[chosen].remaining_time) {
                better = true;
            } else if (processes[i].priority == best_priority && chosen >= 0 &&
                       processes[i].remaining_time == processes[chosen].remaining_time &&
                       processes[i].arrival_time < processes[chosen].arrival_time) {
                better = true;
            }

            if (chosen < 0 || better) {
                chosen = i;
                best_priority = processes[i].priority;
            }
        }

        if (chosen < 0) {
            if (running_index >= 0 && segment_start < current_time) {
                if (timeline_builder_add(&builder,
                                         processes[running_index].process_id,
                                         processes[running_index].name,
                                         segment_start,
                                         current_time) != SCHED_OK) {
                    timeline_builder_free(&builder);
                    free(completed);
                    return SCHED_ERR_ALLOC;
                }
            }
            running_index = -1;

            int next_arrival = find_next_arrival(processes, completed, count, current_time);
            if (next_arrival == INT_MAX) {
                break;
            }
            current_time = next_arrival;
            segment_start = current_time;
            continue;
        }

        if (running_index != chosen) {
            if (running_index >= 0 && segment_start < current_time) {
                if (timeline_builder_add(&builder,
                                         processes[running_index].process_id,
                                         processes[running_index].name,
                                         segment_start,
                                         current_time) != SCHED_OK) {
                    timeline_builder_free(&builder);
                    free(completed);
                    return SCHED_ERR_ALLOC;
                }
            }

            running_index = chosen;
            segment_start = current_time;

            if (processes[chosen].first_run_time < 0) {
                processes[chosen].first_run_time = current_time;
                processes[chosen].response_time = current_time - processes[chosen].arrival_time;
            }
        }

        processes[chosen].remaining_time--;
        current_time++;

        if (processes[chosen].remaining_time == 0) {
            if (timeline_builder_add(&builder,
                                     processes[chosen].process_id,
                                     processes[chosen].name,
                                     segment_start,
                                     current_time) != SCHED_OK) {
                timeline_builder_free(&builder);
                free(completed);
                return SCHED_ERR_ALLOC;
            }

            finalize_completed_process(&processes[chosen], current_time);
            completed[chosen] = true;
            finished_count++;
            running_index = -1;
            segment_start = current_time;
        }
    }

    int result = build_and_return_timeline(&builder, timeline, timeline_count);
    timeline_builder_free(&builder);
    free(completed);
    return result;
}

int schedule_processes(
    process_t *processes,
    int process_count,
    algorithm_type_t algorithm,
    int time_quantum,
    timeline_event_t **timeline,
    int *timeline_count,
    metrics_t *metrics
) {
    if (!processes || process_count <= 0 || !timeline || !timeline_count || !metrics) {
        return SCHED_ERR_ARGS;
    }

    *timeline = NULL;
    *timeline_count = 0;

    int result = SCHED_OK;
    switch (algorithm) {
        case ALGO_FCFS:
            result = fcfs_schedule(processes, process_count, timeline, timeline_count);
            break;
        case ALGO_SJF:
            result = sjf_schedule(processes, process_count, timeline, timeline_count);
            break;
        case ALGO_SRTF:
            result = srtf_schedule(processes, process_count, timeline, timeline_count);
            break;
        case ALGO_RR:
            result = round_robin_schedule(processes, process_count, time_quantum, timeline, timeline_count);
            break;
        case ALGO_PRIORITY_NP:
            result = priority_np_schedule(processes, process_count, timeline, timeline_count);
            break;
        case ALGO_PRIORITY_P:
            result = priority_p_schedule(processes, process_count, timeline, timeline_count);
            break;
        default:
            return SCHED_ERR_ARGS;
    }

    if (result != SCHED_OK) {
        return result;
    }

    int context_switches = count_context_switches(*timeline, *timeline_count);
    calculate_metrics(processes, process_count, context_switches, metrics);
    return SCHED_OK;
}
