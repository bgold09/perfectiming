//
//  Constants.h
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/16/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

FOUNDATION_EXPORT NSString * const kPTGroupAddedNotification;
FOUNDATION_EXPORT NSString * const kPTGroupDeletedNotification;
FOUNDATION_EXPORT NSString * const kPTMembershipAddedNotification;
FOUNDATION_EXPORT NSString * const kPTMeetingAddedNotification;
FOUNDATION_EXPORT NSString * const kPTMeetingDeletedNotification;
FOUNDATION_EXPORT NSString * const kPTMeetingTimeCreatedNotification;
FOUNDATION_EXPORT NSString * const kPTUserLoggedInNotification;
FOUNDATION_EXPORT NSString * const kPTUserLoggedOutNotification;
FOUNDATION_EXPORT NSString * const kPTAvailabilityReadyNotification;
FOUNDATION_EXPORT NSString * const kPTAvailabilityFailedNotification;
FOUNDATION_EXPORT NSString * const kPTAvailabilitySentNotification;
FOUNDATION_EXPORT NSString * const kPTUserSettingsChangedNotification;
FOUNDATION_EXPORT NSString * const kPTMeetingAvailabilityReadyNotification;

FOUNDATION_EXPORT NSString * const kPTMeetingTimeCellIdentifier;
FOUNDATION_EXPORT NSString * const kPTUserChannelsKey;
FOUNDATION_EXPORT NSString * const kPTUserNameKey;

+ (UIColor *)tintColor;

@end
