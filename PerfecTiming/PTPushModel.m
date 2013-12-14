//
//  PTPushModel.m
//  PerfecTiming
//
//  Created by Brian Golden on 11/25/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTPushModel.h"
#import "PTMeetingAttendee.h"
#import "PTNotification.h"
#import "Constants.h"

static NSString * const kAlertKey = @"alert";
static NSString * const kBadgeKey = @"badge";

@implementation PTPushModel

+ (void)sendPushToUser:(PFUser *)user message:(NSString *)message pushType:(PTPushType)pushType {
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" equalTo:user];
    
    NSDictionary *data = @{kAlertKey: message,
                           kBadgeKey: @"Increment",
                           kPTPushTypeKey: [NSNumber numberWithInteger:pushType]};
    
    [PFPush sendPushDataToQueryInBackground:query withData:data block:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
    }];
}

+ (void)sendPushToManagerForGroup:(PTGroup *)group message:(NSString *)message pushType:(PTPushType)pushType {
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" equalTo:group.manager];
    
    NSDictionary *data = @{kAlertKey: message,
                           kBadgeKey: @"Increment",
                           kPTPushTypeKey: [NSNumber numberWithInteger:pushType]};
    
    [PFPush sendPushDataToQueryInBackground:query withData:data block:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
    }];
}

+ (void)sendPushToAttendeesForMeetingTime:(PTMeetingTime *)meetingTime {
    [PTPushModel performSelectorInBackground:@selector(backgroundPushToAttendeesForMeetingTime:) withObject:meetingTime];
}

#pragma mark - Private methods

// uses synchronous methods, dispatch on background thread
+ (void)backgroundPushToAttendeesForMeetingTime:(PTMeetingTime *)meetingTime {
    PTMeeting *meeting = (PTMeeting *) [meetingTime.meeting fetchIfNeeded];
    PTGroup *group = (PTGroup *) [meeting.group fetchIfNeeded];
    PFUser *manager = (PFUser *) [group.manager fetchIfNeeded];
    NSString *message = [NSString stringWithFormat:@"%@ chose a meeting time for %@ in %@", manager.username, meeting.name, group.name];
    
    NSString *channelName = [group channelName];
    NSDictionary *data = @{kAlertKey: message,
                           kBadgeKey: @"Increment",
                           kPTPushTypeKey: [NSNumber numberWithInteger:PTPushTypeMeetingTimeChosen],
                           @"meetingTime": meetingTime.objectId};
    
    NSError *error;
    [PFPush sendPushDataToChannel:channelName withData:data error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    // create Parse Notification object for user to retrieve notification details, take actions
    
    PFQuery *attendeeQuery = [PTMeetingAttendee query];
    [attendeeQuery whereKey:@"meeting" equalTo:meeting];
    NSArray *attendees = [attendeeQuery findObjects:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    NSMutableArray *users = [NSMutableArray array];
    for (PTMeetingAttendee *attendee in attendees) {
        [users addObject:attendee.user];
    }
    
    NSMutableArray *notifications = [NSMutableArray array];
    for (PFUser *user in users) {
        PTNotification *notification = [PTNotification notificationForUser:user message:message pushType:PTPushTypeMeetingTimeChosen object:meetingTime];
        [notifications addObject:notification];
    }
    
    [PFObject saveAll:notifications error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
}

@end
