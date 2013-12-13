//
//  PTMembershipModel.m
//  PerfecTiming
//
//  Created by Brian Golden on 11/26/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMembershipModel.h"
#import "PTPushModel.h"
#import "PTChannelModel.h"
#import "PTMeetingAttendee.h"

@implementation PTMembershipModel

+ (void)cleanupMembershipForGroup:(PTGroup *)group user:(PFUser *)user {
    PFQuery *meetingQuery = [PTMeeting query];
    [meetingQuery whereKey:@"group" equalTo:group];
    
    PFQuery *query = [PTMeetingAttendee query];
    [query whereKey:@"meeting" matchesQuery:meetingQuery];
    [query whereKey:@"user" equalTo:user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"error getting MeetingAttendee objects: %@", error);
            return;
        }
        
        if (objects) {
            NSError *error2;
            if (![PFObject deleteAll:objects error:&error2]) {
                NSLog(@"error deleting MeetingAttendee objects: %@", error2);
            }
        }
    }];
    
    [PTChannelModel removeChannelWithName:[group channelName] user:user];
}

@end
