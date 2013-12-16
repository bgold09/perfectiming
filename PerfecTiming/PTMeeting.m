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

- (void)createAttendees {
    [self performSelectorInBackground:@selector(backgroundCreateAttendees) withObject:nil];
}

- (NSComparisonResult)compareToMeeting:(PTMeeting *)meeting {
    return [self.name compare:meeting.name];
}

#pragma mark - Private methods

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

@end
