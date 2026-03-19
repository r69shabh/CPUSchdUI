#import "ProcessMonitorBridge.h"

#import "../Core/process_monitor.h"

@implementation BridgeSystemProcess
- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"";
        _user = @"unknown";
        _state = @"unknown";
    }
    return self;
}
@end

@interface ProcessMonitorBridge ()
@property (nonatomic, strong, nullable) NSTimer *monitorTimer;
@property (nonatomic, copy, nullable) void (^monitorCallback)(NSArray<BridgeSystemProcess *> *);
@end

@implementation ProcessMonitorBridge

+ (instancetype)shared {
    static ProcessMonitorBridge *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSArray<BridgeSystemProcess *> *)getAllProcesses {
    system_process_t *processes = NULL;
    int count = 0;

    int result = get_all_processes(&processes, &count);
    if (result != 0 || count <= 0 || processes == NULL) {
        if (processes) {
            free(processes);
        }
        return @[];
    }

    NSMutableArray<BridgeSystemProcess *> *bridgeProcesses =
        [NSMutableArray arrayWithCapacity:(NSUInteger)count];

    for (int i = 0; i < count; i++) {
        BridgeSystemProcess *proc = [[BridgeSystemProcess alloc] init];
        proc.pid = processes[i].pid;

        NSString *name = [NSString stringWithUTF8String:processes[i].name];
        proc.name = name ?: @"";

        proc.cpuUsage = processes[i].cpu_usage;
        proc.memoryUsage = processes[i].memory_usage;
        proc.threadCount = (int)processes[i].thread_count;

        NSString *user = [NSString stringWithUTF8String:processes[i].user];
        proc.user = user ?: @"unknown";

        proc.priority = processes[i].priority;
        proc.startTimeEpochMS = processes[i].start_time_epoch_ms;

        NSString *state = [NSString stringWithUTF8String:processes[i].state];
        proc.state = state ?: @"unknown";

        [bridgeProcesses addObject:proc];
    }

    free(processes);
    return bridgeProcesses;
}

- (NSArray<BridgeSystemProcess *> *)getActiveProcessesWithThreshold:(double)threshold {
    NSArray<BridgeSystemProcess *> *allProcesses = [self getAllProcesses];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(BridgeSystemProcess *proc, NSDictionary *_) {
        return proc.cpuUsage >= threshold;
    }];
    return [allProcesses filteredArrayUsingPredicate:predicate];
}

- (void)startMonitoringWithInterval:(NSTimeInterval)interval
                           callback:(void (^)(NSArray<BridgeSystemProcess *> *processes))callback {
    [self stopMonitoring];

    self.monitorCallback = callback;

    if (self.monitorCallback) {
        self.monitorCallback([self getAllProcesses]);
    }

    NSTimeInterval safeInterval = (interval <= 0.0) ? 1.0 : interval;

    self.monitorTimer = [NSTimer scheduledTimerWithTimeInterval:safeInterval
                                                         repeats:YES
                                                           block:^(__unused NSTimer *timer) {
        if (!self.monitorCallback) {
            return;
        }
        self.monitorCallback([self getAllProcesses]);
    }];
}

- (void)stopMonitoring {
    [self.monitorTimer invalidate];
    self.monitorTimer = nil;
    self.monitorCallback = nil;
}

- (BOOL)isMonitoring {
    return self.monitorTimer != nil;
}

@end
