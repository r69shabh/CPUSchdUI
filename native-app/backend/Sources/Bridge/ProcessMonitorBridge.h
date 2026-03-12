#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BridgeSystemProcess : NSObject
@property (nonatomic, assign) int pid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) double cpuUsage;
@property (nonatomic, assign) uint64_t memoryUsage;
@property (nonatomic, assign) int threadCount;
@property (nonatomic, copy) NSString *user;
@property (nonatomic, assign) int priority;
@property (nonatomic, assign) uint64_t startTimeEpochMS;
@property (nonatomic, copy) NSString *state;
@end

@interface ProcessMonitorBridge : NSObject

+ (instancetype)shared;

- (NSArray<BridgeSystemProcess *> *)getAllProcesses;
- (NSArray<BridgeSystemProcess *> *)getActiveProcessesWithThreshold:(double)threshold;

- (void)startMonitoringWithInterval:(NSTimeInterval)interval
                           callback:(void (^)(NSArray<BridgeSystemProcess *> *processes))callback;

- (void)stopMonitoring;
- (BOOL)isMonitoring;

@end

NS_ASSUME_NONNULL_END
