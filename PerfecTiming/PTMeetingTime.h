//
//  PTMeetingTime.h
//  PerfecTiming
//
//  Created by MTSS User on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Parse/Parse.h>
#import "PTMeeting.h"

@interface PTMeetingTime : PFObject <PFSubclassing>

@property (retain) PTMeeting *meeting;
@property (retain) NSDate *startDatetime;
@property (retain) NSDate *endDatetime;

+ (NSString *)parseClassName;
+ (PTMeetingTime *)meetingTimeWithMeeting:(PTMeeting *)meeting startDate:(NSDate *)startDate endDate:(NSDate *)endDate;
- (void)getAvailabilityForAllAttendees;
- (NSString *)availabilityReadyForMeetingTimeNotificationName;

@end
