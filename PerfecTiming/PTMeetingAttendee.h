//
//  PTMeetingAttendee.h
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/19/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Parse/Parse.h>
#import "PTMeeting.h"
#import "PTMeetingTime.h"

typedef NS_ENUM(NSInteger, PTMeetingAttendeeAvailability) {
    PTMeetingAttendeeAvailabilityFull,         // available
    PTMeetingAttendeeAvailabilityPartial,      // partially available
    PTMeetingAttendeeAvailabilityNot,          // unavailable
    PTMeetingAttendeeAvailabilityNotResponded  // request not responded to
};

@interface PTMeetingAttendee : PFObject <PFSubclassing>

@property (retain) PTMeeting *meeting;
@property (retain) PFUser *user;
@property (retain) NSString *availability;
@property BOOL isAvailable;
@property BOOL isRequiredAttendee;

+ (NSString *)parseClassName;
+ (PTMeetingAttendee *)meetingAttendeeWithUser:(PFUser *)user meeting:(PTMeeting *)meeting;
- (BOOL)hasSubmittedAvailability;
- (PTMeetingAttendeeAvailability)availabilityForMeeting;
- (PTMeetingAttendeeAvailability)availabilityForMeetingTime:(PTMeetingTime *)meetingTime response:(NSDictionary *)response;
- (NSComparisonResult)compare:(PTMeetingAttendee *)attendee;

@end
