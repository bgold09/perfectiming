//
//  PTMeetingAvailabilityModel.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/22/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMeetingAvailabilityModel.h"
#import "PTMeetingTime.h"
#import "PTMeetingDateRange.h"
#import "Constants.h"

@implementation PTMeetingAvailabilityModel

+ (id)sharedInstance {
    static id singleton = nil;
    if (!singleton) {
        singleton = [[self alloc] init];
    }
    return singleton;
}

- (void)buildAvailabilityForMeeting:(PTMeeting *)meeting calendarStore:(EKEventStore *)eventStore calendars:(NSSet *)calendars {
    PFQuery *query = [PFQuery queryWithClassName:[PTMeetingTime parseClassName]];
    [query whereKey:@"meeting" equalTo:meeting];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [self performSelectorOnMainThread:@selector(fireAvailabilityFailedNotification) withObject:nil waitUntilDone:YES];
            return;
        }
        
        if (objects) {
            [self buildAvailabilityForMeeting:meeting meetingTimes:objects calendarStore:eventStore calendars:calendars];
        }
    }];
}

- (void)sendAvailabilityForMeetingAttendee:(PTMeetingAttendee *)attendee availability:(NSDictionary *)availability {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:availability
                                                       options:0
                                                         error:&error];
    
    if (!data) {
        NSLog(@"JSON error: %@", error);
    } else {
        NSString *originalAvailability = attendee.availability;
        NSString *availabilityString = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
        
        attendee.availability = availabilityString;
        [attendee saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                attendee.availability = originalAvailability;
                [self performSelectorOnMainThread:@selector(fireAvailabilityFailedNotification) withObject:nil waitUntilDone:NO];
                return;
            }
            
            if (succeeded) {
                [self performSelectorOnMainThread:@selector(fireAvailabilitySentNotification) withObject:nil waitUntilDone:NO];
            }
        }];
    }
}

#pragma mark - Private Methods

- (void)buildAvailabilityForMeeting:(PTMeeting *)meeting meetingTimes:(NSArray *)meetingTimes calendarStore:(EKEventStore *)eventStore calendars:(NSSet *)calendars {
    NSMutableDictionary *availability = [NSMutableDictionary dictionary];
    
    for (PTMeetingTime *meetingTime in meetingTimes) {
        PTMeetingDateRange *meetingDateRange = [[PTMeetingDateRange alloc] initWithStartDate:meetingTime.startDatetime endDate:meetingTime.endDatetime];
        NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:meetingTime.startDatetime endDate:meetingTime.endDatetime calendars:[calendars allObjects]];
        
        BOOL foundEvent = NO;
        NSArray *events = [eventStore eventsMatchingPredicate:predicate];
        for (EKEvent *event in events) {
            NSDate *startDate = event.startDate;
            NSDate *endDate = event.endDate;
            PTMeetingDateRange *eventDateRange = [[PTMeetingDateRange alloc] initWithStartDate:startDate endDate:endDate];
            
            PTDateConflict dateConflict = [meetingDateRange conflictForDateRange:eventDateRange];
            if (event.availability == EKEventAvailabilityBusy || event.availability == EKEventAvailabilityUnavailable || event.availability == EKEventAvailabilityNotSupported) {
                NSNumber *conflictNum = [NSNumber numberWithInt:dateConflict];
                [availability setValue:conflictNum forKey:meetingTime.objectId];
                foundEvent = YES;
                break;
            }
        }
        
        if (!foundEvent) {
            NSNumber *conflictNum = [NSNumber numberWithInt:PTDateConflictNone];
            [availability setValue:conflictNum forKey:meetingTime.objectId];
        }
    }
    
    [self performSelectorOnMainThread:@selector(fireAvailabilityNotificationWithDictionary:) withObject:availability waitUntilDone:YES];
}

#pragma mark - Notifications

- (void)fireAvailabilityFailedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPTAvailabilityFailedNotification object:nil];
}

- (void)fireAvailabilitySentNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPTAvailabilitySentNotification object:nil];
}

- (void)fireAvailabilityNotificationWithDictionary:(NSDictionary *)dictionary {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPTAvailabilityReadyNotification object:dictionary];
}

@end