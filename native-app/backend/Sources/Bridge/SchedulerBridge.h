#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SchedulingAlgorithmType) {
    SchedulingAlgorithmFCFS = 0,
    SchedulingAlgorithmSJF,
    SchedulingAlgorithmSRTF,
    SchedulingAlgorithmRR,
    SchedulingAlgorithmPriorityNP,
    SchedulingAlgorithmPriorityP
};

@interface BridgeProcess : NSObject
@property (nonatomic, assign) int processID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int arrivalTime;
@property (nonatomic, assign) int burstTime;
@property (nonatomic, assign) int priority;
@end

@interface BridgeTimelineEvent : NSObject
@property (nonatomic, assign) int processID;
@property (nonatomic, copy) NSString *processName;
@property (nonatomic, assign) int startTime;
@property (nonatomic, assign) int endTime;
@end

@interface BridgeMetrics : NSObject
@property (nonatomic, assign) double averageTurnaroundTime;
@property (nonatomic, assign) double averageWaitingTime;
@property (nonatomic, assign) double averageResponseTime;
@property (nonatomic, assign) double cpuUtilization;
@property (nonatomic, assign) double throughput;
@property (nonatomic, assign) int totalTime;
@property (nonatomic, assign) int contextSwitches;
@property (nonatomic, strong) NSArray<NSDictionary *> *processMetrics;
@end

@interface BridgeSchedulingResult : NSObject
@property (nonatomic, strong) NSArray<BridgeTimelineEvent *> *timeline;
@property (nonatomic, strong) BridgeMetrics *metrics;
@end

@interface SchedulerBridge : NSObject

+ (instancetype)shared;

- (nullable BridgeSchedulingResult *)scheduleProcesses:(NSArray<BridgeProcess *> *)processes
                                         withAlgorithm:(SchedulingAlgorithmType)algorithm
                                           timeQuantum:(int)timeQuantum;

- (NSDictionary<NSString *, BridgeSchedulingResult *> *)compareAllAlgorithms:(NSArray<BridgeProcess *> *)processes
                                                                  timeQuantum:(int)timeQuantum;

@end

NS_ASSUME_NONNULL_END
