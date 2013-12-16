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
    NSDictionary *dictionary = @{@"user": user, @"group": group};
    [PTMembershipModel performSelectorInBackground:@selector(backgroundCleanupMembership:) withObject:dictionary];
    
    [PTChannelModel removeChannelWithName:[group channelName] user:user];
}

#pragma mark - Private methods

+ (void)backgroundCleanupMembership:(NSDictionary *)dictionary {
    PFUser *user = [dictionary objectForKey:@"user"];
    PTGroup *group = [dictionary objectForKey:@"group"];
    
    // find all meetings for the group
    PFQuery *meetingQuery = [PTMeeting query];
    [meetingQuery whereKey:@"group" equalTo:group];
    
    // find attendee objects for the meetings for this user
    PFQuery *query = [PTMeetingAttendee query];
    [query whereKey:@"meeting" matchesQuery:meetingQuery];
    [query whereKey:@"user" equalTo:user];
    
    NSError *error;
    NSArray *attendees = [query findObjects:&error];
    if (error) {
        NSLog(@"error getting MeetingAttendee objects: %@", error);
        return;
    }
    
    if (attendees) {
        if (![PFObject deleteAll:attendees error:&error]) {
            NSLog(@"error deleting MeetingAttendee objects: %@", error);
            return;
        }
    }
}

@end
