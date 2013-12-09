//
//  PTMeeting.m
//  PerfecTiming
//
//  Created by MTSS User on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMeeting.h"
#import <Parse/PFObject+Subclass.h>
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

- (NSComparisonResult)compareToMeeting:(PTMeeting *)meeting {
    return [self.name compare:meeting.name];
}

// uses synchronous methods, dispatch on background thread
- (CGFloat)getGroupAvailability {
    PFQuery *attendeesQuery = [PTMeetingAttendee query];
    [attendeesQuery whereKey:@"meeting" equalTo:self];
    
    NSError *error;
    NSArray *attendees = [attendeesQuery findObjects:&error];
    if (error) {
        NSLog(@"error: %@", error);
        return 0.0;
    }
    
    PFQuery *meetingTimeQuery = [PTMeetingTime query];
    [meetingTimeQuery whereKey:@"meeting" equalTo:self];
    
    NSArray *meetingTimes = [meetingTimeQuery findObjects:&error];
    if (error) {
        NSLog(@"error: %@", error);
        return 0.0;
    }
    
    NSInteger count = 0;
    for (PTMeetingAttendee *attendee in attendees) {
        NSData *data = [attendee.availability dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        for (PTMeetingTime *meetingTime in meetingTimes) {
            PTMeetingAttendeeAvailability availability = [attendee availabilityForMeetingTime:meetingTime response:response];
            
            switch (availability) {
                case PTMeetingAttendeeAvailabilityFull:
                    count++;
                    break;
                case PTMeetingAttendeeAvailabilityPartial:
                    break;
                case PTMeetingAttendeeAvailabilityNot:
                    break;
                case PTMeetingAttendeeAvailabilityNotResponded:
                    break;
                default:
                    break;
            }
        }
    }
    
    CGFloat percentage = (CGFloat) count / (CGFloat) attendees.count;
    
    return percentage;
}

@end
