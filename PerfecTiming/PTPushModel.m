//
//  PTPushModel.m
//  PerfecTiming
//
//  Created by Brian Golden on 11/25/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTPushModel.h"
#import "PTMeetingAttendee.h"

@implementation PTPushModel

+ (void)sendPushToUser:(PFUser *)user message:(NSString *)message {
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" equalTo:user];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    [push setMessage:message];
    [push sendPushInBackground];
}

+ (void)sendPushToManagerForGroup:(PTGroup *)group message:(NSString *)message {
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" equalTo:group.manager];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    [push setMessage:message];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
    }];
}

+ (void)sendPushToAttendeesForMeetingTime:(PTMeetingTime *)meetingTime {
    [PTPushModel performSelectorInBackground:@selector(backgroundPushToAttendeesForMeetingTime:) withObject:meetingTime];
}

#pragma mark - Private methods

+ (void)backgroundPushToAttendeesForMeetingTime:(PTMeetingTime *)meetingTime {
    PTMeeting *meeting = (PTMeeting *) [meetingTime.meeting fetchIfNeeded];
    PTGroup *group = (PTGroup *) [meeting.group fetchIfNeeded];
    PFUser *manager = (PFUser *) [group.manager fetchIfNeeded];
    NSString *message = [NSString stringWithFormat:@"%@ chose a meeting time for '%@' in %@", manager.username, meeting.name, group.name];
    
    NSString *channelName = [group.name stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    
    [PFPush sendPushMessageToChannelInBackground:channelName withMessage:message block:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
    }];
}

@end
