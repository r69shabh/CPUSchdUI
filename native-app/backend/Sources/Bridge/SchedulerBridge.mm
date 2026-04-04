#import "SchedulerBridge.h"

#import "../Core/metrics.h"
#import "../Core/process_types.h"
#import "../Core/scheduler.h"

#import <vector>

@implementation BridgeProcess
- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"";
        _priority = 1;
    }
    return self;
}
@end

@implementation BridgeTimelineEvent
@end

@implementation BridgeMetrics
- (instancetype)init {
    self = [super init];
    if (self) {
        _processMetrics = @[];
    }
    return self;
}
@end

@implementation BridgeSchedulingResult
- (instancetype)init {
    self = [super init];
    if (self) {
        _timeline = @[];
        _metrics = [[BridgeMetrics alloc] init];
    }
    return self;
}
@end

static NSString *BridgeStringFromCString(const char *value) {
    if (!value) {
        return @"";
    }
    NSString *stringValue = [NSString stringWithUTF8String:value];
    return stringValue ?: @"";
}

@implementation SchedulerBridge

+ (instancetype)shared {
    static SchedulerBridge *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (nullable BridgeSchedulingResult *)scheduleProcesses:(NSArray<BridgeProcess *> *)processes
                                         withAlgorithm:(SchedulingAlgorithmType)algorithm
                                           timeQuantum:(int)timeQuantum {
    if (processes.count == 0) {
        return nil;
    }

    std::vector<process_t> cProcesses;
    cProcesses.reserve(processes.count);

    for (BridgeProcess *proc in processes) {
        process_t cProc = {};
        cProc.process_id = proc.processID;
        cProc.arrival_time = proc.arrivalTime;
        cProc.burst_time = proc.burstTime;
        cProc.priority = proc.priority;
        cProc.remaining_time = proc.burstTime;
        cProc.response_time = -1;
        cProc.first_run_time = -1;

        const char *nameCString = proc.name.UTF8String;
        if (nameCString) {
            strncpy(cProc.name, nameCString, sizeof(cProc.name) - 1);
            cProc.name[sizeof(cProc.name) - 1] = '\0';
        } else {
            cProc.name[0] = '\0';
        }

        cProcesses.push_back(cProc);
    }

    timeline_event_t *timeline = NULL;
    int timelineCount = 0;
    metrics_t metrics = {};

    int scheduleResult = schedule_processes(
        cProcesses.data(),
        (int)cProcesses.size(),
        (algorithm_type_t)algorithm,
        timeQuantum,
        &timeline,
        &timelineCount,
        &metrics
    );

    if (scheduleResult != 0) {
        if (timeline != NULL) {
            free(timeline);
        }
        return nil;
    }

    BridgeSchedulingResult *bridgeResult = [[BridgeSchedulingResult alloc] init];

    NSMutableArray<BridgeTimelineEvent *> *timelineArray =
        [NSMutableArray arrayWithCapacity:(NSUInteger)timelineCount];

    for (int i = 0; i < timelineCount; i++) {
        BridgeTimelineEvent *event = [[BridgeTimelineEvent alloc] init];
        event.processID = timeline[i].process_id;
        event.processName = BridgeStringFromCString(timeline[i].process_name);
        event.startTime = timeline[i].start_time;
        event.endTime = timeline[i].end_time;
        [timelineArray addObject:event];
    }

    BridgeMetrics *bridgeMetrics = [[BridgeMetrics alloc] init];
    bridgeMetrics.averageTurnaroundTime = metrics.avg_turnaround_time;
    bridgeMetrics.averageWaitingTime = metrics.avg_waiting_time;
    bridgeMetrics.averageResponseTime = metrics.avg_response_time;
    bridgeMetrics.cpuUtilization = metrics.cpu_utilization;
    bridgeMetrics.throughput = metrics.throughput;
    bridgeMetrics.totalTime = metrics.total_time;
    bridgeMetrics.contextSwitches = metrics.context_switches;

    NSMutableArray<NSDictionary *> *perProcessMetrics =
        [NSMutableArray arrayWithCapacity:(NSUInteger)cProcesses.size()];

    for (const process_t &proc : cProcesses) {
        NSDictionary *metric = @{
            @"processID" : @(proc.process_id),
            @"processName" : BridgeStringFromCString(proc.name),
            @"arrivalTime" : @(proc.arrival_time),
            @"burstTime" : @(proc.burst_time),
            @"priority" : @(proc.priority),
            @"completionTime" : @(proc.completion_time),
            @"turnaroundTime" : @(proc.turnaround_time),
            @"waitingTime" : @(proc.waiting_time),
            @"responseTime" : @(proc.response_time)
        };
        [perProcessMetrics addObject:metric];
    }
    bridgeMetrics.processMetrics = perProcessMetrics;

    bridgeResult.timeline = timelineArray;
    bridgeResult.metrics = bridgeMetrics;

    free(timeline);
    return bridgeResult;
}

- (NSDictionary<NSString *, BridgeSchedulingResult *> *)compareAllAlgorithms:(NSArray<BridgeProcess *> *)processes
                                                                  timeQuantum:(int)timeQuantum {
    NSMutableDictionary<NSString *, BridgeSchedulingResult *> *results = [NSMutableDictionary dictionary];

    NSArray<NSArray *> *algorithms = @[
        @[ @"FCFS", @(SchedulingAlgorithmFCFS) ],
        @[ @"SJF", @(SchedulingAlgorithmSJF) ],
        @[ @"SRTF", @(SchedulingAlgorithmSRTF) ],
        @[ @"Round Robin", @(SchedulingAlgorithmRR) ],
        @[ @"Priority NP", @(SchedulingAlgorithmPriorityNP) ],
        @[ @"Priority P", @(SchedulingAlgorithmPriorityP) ]
    ];

    for (NSArray *entry in algorithms) {
        NSString *name = (NSString *)entry[0];
        SchedulingAlgorithmType type = (SchedulingAlgorithmType)[entry[1] integerValue];

        BridgeSchedulingResult *result = [self scheduleProcesses:processes
                                                   withAlgorithm:type
                                                     timeQuantum:timeQuantum];
        if (result) {
            results[name] = result;
        }
    }

    return results;
}

@end
