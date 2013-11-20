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
    
    PTMeetingAttendeeAvailability availabilityLevel = [[dictionary objectForKey:self.meeting.objectId] integerValue];
    return availabilityLevel;
}

@end
