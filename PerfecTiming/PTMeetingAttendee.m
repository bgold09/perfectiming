//
//  PTMeetingAttendee.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/19/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMeetingAttendee.h"
#import <Parse/PFObject+Subclass.h>

@implementation PTMeetingAttendee

@dynamic meeting;
@dynamic user;
@dynamic availability;
@dynamic isRequiredAttendee;

+ (NSString *)parseClassName {
    return @"MeetingAttendee";
}

+ (PTMeetingAttendee *)meetingAttendeeWithUser:(PFUser *)user meeting:(PTMeeting *)meeting {
    PTMeetingAttendee *attendee = [PTMeetingAttendee object];
    attendee.user = user;
    attendee.meeting = meeting;
    
    PFACL *ACL = [PFACL ACL];
    ACL.publicReadAccess = YES;
    ACL.publicWriteAccess = YES;
    attendee.ACL = ACL;
    return attendee;
}

- (BOOL)hasSubmittedAvailability {
    if (self.availability && self.availability.length > 0) {
        return YES;
    }
    return NO;
}

- (PTMeetingAttendeeAvailability)availabilityForMeeting:(PTMeeting *)meeting {
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[self.availability dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    
    NSNumber *availabilityNumber = [dictionary objectForKey:self.meeting.objectId];
    
    if (availabilityNumber) {
        return [availabilityNumber integerValue];
    }
    
    return PTMeetingAttendeeAvailabilityNotResponded;
}

@end
