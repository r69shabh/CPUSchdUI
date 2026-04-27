#ifndef METRICS_H
#define METRICS_H

#include "process_types.h"

#ifdef __cplusplus
extern "C" {
#endif

void calculate_metrics(
    const process_t *processes,
    int count,
    int context_switches,
    metrics_t *metrics
);

#ifdef __cplusplus
}
#endif

#endif // METRICS_H
