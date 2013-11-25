//
//  PTMeetingDateRange.h
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/24/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PTDateConflict) {
    PTDateConflictNone,     // no conflict between two dates
    PTDateConflictFull,     // full conflict between two dates
    PTDateConflictPartial,  // partial conflict between two dates
    PTDateConflictUnknown
};

@interface PTMeetingDateRange : NSObject

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

- (id)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (PTDateConflict)conflictForDateRange:(PTMeetingDateRange *)meetingDateRange;
- (PTDateConflict)conflictForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
