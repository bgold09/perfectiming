//
//  PTMeetingDateRange.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/24/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMeetingDateRange.h"

@implementation PTMeetingDateRange

- (id)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    self = [super init];
    if (self) {
        _startDate = startDate;
        _endDate = endDate;
    }
    return self;
}

- (PTDateConflict)conflictForDateRange:(PTMeetingDateRange *)meetingDateRange {
    return [self conflictForStartDate:meetingDateRange.startDate endDate:meetingDateRange.endDate];
}

- (PTDateConflict)conflictForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    BOOL condA;
    BOOL condB;
    
    if ([self.startDate compare:endDate] == NSOrderedDescending) {
        condA = NO;
    } else {
        condA = YES;
    }
    
    if ([self.endDate compare:startDate] == NSOrderedAscending) {
        condB = NO;
    } else {
        condB = YES;
    }
    
    if (condA && condB) {
        return PTDateConflictFull;
    } else {
        return PTDateConflictNone;
    }
}

@end
