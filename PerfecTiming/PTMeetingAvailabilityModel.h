//
//  PTMeetingAvailabilityModel.h
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/22/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import "PTMeeting.h"
#import "PTMeetingAttendee.h"

@interface PTMeetingAvailabilityModel : NSObject

+ (void)buildAvailabilityForMeeting:(PTMeeting *)meeting calendarStore:(EKEventStore *)eventStore calendars:(NSSet *)calendars;
+ (void)sendAvailabilityForMeetingAttendee:(PTMeetingAttendee *)attendee availability:(NSDictionary *)availability;

@end
