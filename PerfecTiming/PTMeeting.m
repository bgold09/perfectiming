//
//  PTMeeting.m
//  PerfecTiming
//
//  Created by MTSS User on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMeeting.h"
#import <Parse/PFObject+Subclass.h>

@implementation PTMeeting

@dynamic name;
@dynamic location;
@dynamic group;

+ (NSString *)parseClassName {
    return @"Meeting";
}

+ (PTMeeting *)meetingWithName:(NSString *)name group:(PTGroup *)group location:(NSString *)location {
    PTMeeting *meeting = [PTMeeting object];
    meeting.name = name;
    meeting.group = group;
    meeting.location = location;
    return meeting;
}

@end
