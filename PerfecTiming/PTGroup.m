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

@implementation PTGroup

@dynamic name;
@dynamic manager;
@dynamic pin;

+ (NSString *)parseClassName {
    return @"Group";
}

+ (BOOL)groupExistsWithName:(NSString *)name {
    PFQuery *query = [PFQuery queryWithClassName:[self parseClassName]];
    [query whereKey:@"name" equalTo:name];
    
    NSError *error;
    NSInteger count = [query countObjects:&error];
    
    if (error) {
        NSLog(@"%@", error);
        return NO;
    }
    
    if (count > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (id)initWithName:(NSString *)name manager:(PFUser *)manager pin:(NSInteger)pin {
    self = [PTGroup object];
    
    if (self) {
        self.name = name;
        self.manager = manager;
        self.pin = pin;
        
        PFACL *ACL = [PFACL ACL];
        ACL.publicReadAccess = YES;
        ACL.publicWriteAccess = YES;
        self.ACL = ACL;
    }
    
    return self;
}

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

// uses synchronous methods, dispatch on background thread
- (void)backgroundCleanup {
    // delete meetings, meeting times, memberships, attendees
    
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
