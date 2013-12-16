//
//  PTMeeting.m
//  PerfecTiming
//
//  Created by MTSS User on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMeeting.h"
#import <Parse/PFObject+Subclass.h>
#import "PTMembership.h"
#import "PTMeetingAttendee.h"

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
    
    PFACL *ACL = [PFACL ACL];
    ACL.publicReadAccess = YES;
    ACL.publicWriteAccess = YES;
    meeting.ACL = ACL;
    
    return meeting;
}

// create meeting attendee objects for this meeting, for all members of the group
- (void)createAttendees {
    [self performSelectorInBackground:@selector(backgroundCreateAttendees) withObject:nil];
}

- (void)cleanup {
    [self performSelectorInBackground:@selector(backgroundCleanup) withObject:nil];
}

- (NSComparisonResult)compareToMeeting:(PTMeeting *)meeting {
    return [self.name compare:meeting.name];
}

#pragma mark - Private methods

// !! uses synchronous methods, dispatch on background thread
- (void)backgroundCreateAttendees {
    PFQuery *membershipQuery = [PTMembership query];
    [membershipQuery whereKey:@"group" equalTo:self.group];
    
    NSError *error;
    NSArray *memberships = [membershipQuery findObjects:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    NSMutableArray *attendees = [NSMutableArray array];
    for (PTMembership *membership in memberships) {
        PTMeetingAttendee *attendee = [PTMeetingAttendee meetingAttendeeWithUser:membership.user meeting:self];
        [attendees addObject:attendee];
    }
    
    [PFObject saveAll:attendees error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
}

// !! uses synchronous methods, dispatch on background thread
- (void)backgroundCleanup {
    PFQuery *meetingTimesQuery = [PTMeetingTime query];
    [meetingTimesQuery whereKey:@"meeting" equalTo:self];
    
    NSError *error;
    NSArray *meetingTimes = [meetingTimesQuery findObjects:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    [PFObject deleteAll:meetingTimes error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    PFQuery *attendeesQuery = [PTMeetingAttendee query];
    [attendeesQuery whereKey:@"meeting" equalTo:self];
    NSArray *meetingAttendees = [attendeesQuery findObjects:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    [PFObject deleteAll:meetingAttendees error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
}

@end
