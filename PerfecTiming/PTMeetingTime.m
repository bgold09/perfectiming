//
//  PTMeetingTime.m
//  PerfecTiming
//
//  Created by MTSS User on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMeetingTime.h"
#import "PTMeetingAttendee.h"
#import <Parse/PFObject+Subclass.h>

@implementation PTMeetingTime

@dynamic meeting;
@dynamic startDatetime;
@dynamic endDatetime;

+ (NSString *)parseClassName {
    return @"MeetingTime";
}

+ (PTMeetingTime *)meetingTimeWithMeeting:(PTMeeting *)meeting startDate:(NSDate *)startDate endDate:(NSDate *)endDate  {
    PTMeetingTime *meetingTime = [PTMeetingTime object];
    meetingTime.meeting = meeting;
    meetingTime.startDatetime = startDate;
    meetingTime.endDatetime = endDate;
    
    PFACL *ACL = [PFACL ACL];
    ACL.publicReadAccess = YES;
    ACL.publicWriteAccess = YES;
    meetingTime.ACL = ACL;
    return meetingTime;
}

- (void)getAvailabilityForAllAttendees {
    [self performSelectorInBackground:@selector(getAvailability) withObject:nil];
}

- (NSString *)availabilityReadyForMeetingTimeNotificationName {
    return [NSString stringWithFormat:@"kPTAvailabilityPercentageReadyFor-%@", self.objectId];;
}

- (EKEvent *)event {
    EKEvent *event = [[EKEvent alloc] init];
    event.startDate = self.startDatetime;
    event.endDate = self.endDatetime;
    event.availability = EKEventAvailabilityBusy;
    
    return event;
}

- (EKEvent *)eventWithEventStore:(EKEventStore *)eventStore {
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.startDate = self.startDatetime;
    event.endDate = self.endDatetime;
    
    if (self.meeting.location) {
        event.location = self.meeting.location;
    }
    
    event.title = [NSString stringWithFormat:@"%@: %@", self.meeting.group.name, self.meeting.name];
    event.availability = EKEventAvailabilityBusy;
    event.notes = @"Event created by PerfecTiming";
    
    return event;
}

#pragma mark - Private Methods

// uses synchronous methods, dispatch in background
- (void)getAvailability {
    PFQuery *attendeesQuery = [PTMeetingAttendee query];
    [attendeesQuery whereKey:@"meeting" equalTo:self.meeting];
    
    NSError *error;
    NSArray *attendees = [attendeesQuery findObjects:&error];
    if (error) {
        NSLog(@"error: %@", error);
        return;
    }
    
    NSInteger count = 0;
    NSInteger unresponded = 0;
    for (PTMeetingAttendee *attendee in attendees) {
        if (!attendee.availability || attendee.availability.length == 0) {
            unresponded++;
            continue;
        }
        
        NSData *data = [attendee.availability dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        PTMeetingAttendeeAvailability availability = [attendee availabilityForMeetingTime:self response:response];
        
        switch (availability) {
            case PTMeetingAttendeeAvailabilityFull:
                count++;
                break;
            case PTMeetingAttendeeAvailabilityPartial:
                break;
            case PTMeetingAttendeeAvailabilityNot:
                break;
            case PTMeetingAttendeeAvailabilityNotResponded:
                unresponded++;
                break;
            default:
                break;
        }
    }
    
    CGFloat percentage = 0.0;
    if (attendees.count > 0) {
        percentage = (CGFloat) count / (CGFloat) attendees.count;
    }
    
    NSNumber *percentageNumber = [NSNumber numberWithFloat:percentage];
    NSNumber *unrespondedNumber = [NSNumber numberWithInteger:unresponded];
    NSDictionary *dictionary = @{@"percentage": percentageNumber, @"unresponded": unrespondedNumber};
    [self performSelectorOnMainThread:@selector(fireNotificationWithPercentage:) withObject:dictionary waitUntilDone:NO];
}

- (void)fireNotificationWithPercentage:(NSNumber *)percentage {
    NSString *notificationName = [self availabilityReadyForMeetingTimeNotificationName];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:percentage];
}

@end
