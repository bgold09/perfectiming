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

@interface PTPushModel : NSObject

+ (void)sendPushToUser:(PFUser *)user message:(NSString *)message;
+ (void)sendPushToManagerForGroup:(PTGroup *)group message:(NSString *)message;
+ (void)sendPushToAttendeesForMeetingTime:(PTMeetingTime *)meetingTime;

@end
