//
//  PTPushModel.h
//  PerfecTiming
//
//  Created by Brian Golden on 11/25/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "PTGroup.h"
#import "PTMeetingTime.h"

typedef NS_ENUM(NSInteger, PTPushType) {
    PTPushTypeUnknown,
    PTPushTypeMeetingTimeChosen,
    PTPushTypeGroupUserJoined,
    PTPushTypeGroupUserLeft,
    PTPushTypeGroupUserSentAvailability
};

static NSString * const kPTPushTypeKey = @"PTPushTypeKey";

@interface PTPushModel : NSObject

+ (void)sendPushToUser:(PFUser *)user message:(NSString *)message pushType:(PTPushType)pushType;
+ (void)sendPushToManagerForGroup:(PTGroup *)group message:(NSString *)message pushType:(PTPushType)pushType;
+ (void)sendPushToAttendeesForMeetingTime:(PTMeetingTime *)meetingTime;

@end
