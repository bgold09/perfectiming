//
//  NSDate+Compare.m
//  PerfecTiming
//
//  Created by MTSS User on 11/25/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "NSDate+Compare.h"

@implementation NSDate (Compare)

- (BOOL)isLessThanDate:(NSDate *)date {
    return [self compare:date] == NSOrderedAscending;
}

- (BOOL)isLessThanOrEqualToDate:(NSDate *)date {
    return [self compare:date] == NSOrderedAscending && [self isEqualToDate:date];
}

- (BOOL)isGreaterThanDate:(NSDate *)date {
    return [self compare:date] == NSOrderedDescending;
}

- (BOOL)isGreaterThanOrEqualToDate:(NSDate *)date {
    return [self compare:date] == NSOrderedDescending && [self compare:date];
}

@end
