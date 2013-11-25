//
//  PTMeetingDateRange.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/24/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMeetingDateRange.h"
#import "NSDate+Compare.h"

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
    // (StartDate1 <= EndDate2) and (StartDate2 <= EndDate1)
    if ([self.startDate isLessThanDate:endDate] && [startDate isGreaterThanDate:self.endDate]) {
        return PTDateConflictFull;
    } else {
        return PTDateConflictNone;
    }
}

@end
