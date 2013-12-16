//
//  PTGroup.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/12/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTGroup.h"
#import <Parse/PFObject+Subclass.h>
#import "PTMembership.h"
#import "PTMeetingAttendee.h"

#define kPINLowerBound 1000
#define kPINUpperBound 9999

@implementation PTGroup

@dynamic name;
@dynamic manager;
@dynamic pin;

+ (NSString *)parseClassName {
    return @"Group";
}

+ (PTGroup *)groupWithName:(NSString *)name manager:(PFUser *)manager {
    PTGroup *group = [PTGroup object];
    group.name = name;
    group.manager = manager;
    
    // generate a PIN for the group, used for users to join the group
    NSInteger pin = kPINLowerBound + arc4random() % (kPINUpperBound - kPINLowerBound);
    group.pin = pin;
    
    PFACL *ACL = [PFACL ACL];
    ACL.publicReadAccess = YES;
    ACL.publicWriteAccess = YES;
    group.ACL = ACL;
    
    return group;
}

// delete meetings, meeting times, memberships, attendees
- (void)cleanup {
    [self performSelectorInBackground:@selector(backgroundCleanup) withObject:nil];
}

- (NSComparisonResult)compareToGroup:(PTGroup *)group {
    return [self.name compare:group.name];
}

- (NSString *)channelName {
    return [self.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
}

#pragma mark - Private methods

// !! uses synchronous methods, dispatch on background thread
- (void)backgroundCleanup {
    PFQuery *membershipQuery = [PTMembership query];
    [membershipQuery whereKey:@"group" equalTo:self];
    
    NSError *error;
    NSArray *memberships = [membershipQuery findObjects:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    [PFObject deleteAll:memberships error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    PFQuery *meetingsQuery = [PTMeeting query];
    [meetingsQuery whereKey:@"group" equalTo:self];
    NSArray *meetings = [meetingsQuery findObjects:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    
    for (PTMeeting *meeting in meetings) {
        [meeting cleanup];
    }
    
    [PFObject deleteAll:meetings error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
}

@end
