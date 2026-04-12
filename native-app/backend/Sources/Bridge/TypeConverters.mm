#import <Foundation/Foundation.h>

#import "../Core/process_types.h"

// This file is intentionally light; conversion helpers can be expanded as
// Swift model complexity grows.
NSString *CPUBackendCStringToNSString(const char *value) {
    if (!value) {
        return @"";
    }
    NSString *result = [NSString stringWithUTF8String:value];
    return result ?: @"";
}
