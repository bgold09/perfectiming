//
//  PTMeetingAttendee.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/19/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMeetingAttendee.h"
#import "PTMeetingDateRange.h"
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

- (PTMeetingAttendeeAvailability)availabilityForMeeting {
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[self.availability dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    
    __block PTMeetingAttendeeAvailability attendeeAvailability = PTMeetingAttendeeAvailabilityFull;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *availabilityLevel = obj;
        PTDateConflict availability = [availabilityLevel integerValue];
        if (availability != PTDateConflictNone) {
            attendeeAvailability = PTMeetingAttendeeAvailabilityNot;
             *stop = YES;
        }
    }];

    return attendeeAvailability;
}

- (PTMeetingAttendeeAvailability)availabilityForMeetingTime:(PTMeetingTime *)meetingTime response:(NSDictionary *)response {
    NSNumber *availabilityNumber = [response objectForKey:meetingTime.objectId];
    
    if (availabilityNumber) {
        return [availabilityNumber integerValue];
    }
    
    return PTMeetingAttendeeAvailabilityNotResponded;
}

- (NSComparisonResult)compare:(PTMeetingAttendee *)attendee {
    return [self.meeting.name compare:attendee.meeting.name];
}

@end
