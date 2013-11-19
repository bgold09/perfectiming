//
//  PTMeetingTime.m
//  PerfecTiming
//
//  Created by MTSS User on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMeetingTime.h"
#import <Parse/PFObject+Subclass.h>

@implementation PTMeetingTime

@dynamic meeting;
@dynamic datetime;

+ (NSString *)parseClassName {
    return @"MeetingTime";
}

+ (PTMeetingTime *)meetingTimeWithMeeting:(PTMeeting *)meeting date:(NSDate *)date {
    PTMeetingTime *meetingTime = [PTMeetingTime object];
    meetingTime.meeting = meeting;
    meetingTime.datetime = date;
    return meetingTime;
}

@end
