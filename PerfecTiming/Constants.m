//
//  Constants.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/16/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString * const kPTMeetingTimeCellIdentifier = @"PTMeetingTimeCell";
NSString * const kPTUserChannelsKey = @"channels";
NSString * const kPTUserNameKey = @"name";

#pragma mark - Notification Names

NSString * const kPTGroupAddedNotification = @"AddedGroupNotification";
NSString * const kPTGroupDeletedNotification = @"DeletedGroupNotification";
NSString * const kPTMembershipAddedNotification = @"AddedMembershipNotification";
NSString * const kPTMeetingAddedNotification = @"MeetingAddedNotification";
NSString * const kPTMeetingDeletedNotification = @"MeetingDeletedNotification";
NSString * const kPTMeetingTimeCreatedNotification = @"MeetingTimeCreatedNotification";
NSString * const kPTUserLoggedInNotification = @"UserLoggedInNotification";
NSString * const kPTUserLoggedOutNotification = @"UserLoggedOutNotification";
NSString * const kPTAvailabilityReadyNotification = @"AvailabilityReadyNotification";
NSString * const kPTAvailabilityFailedNotification = @"AvailabilityFailedNotification";
NSString * const kPTAvailabilitySentNotification = @"AvailabilitySentNotification";
NSString * const kPTUserSettingsChangedNotification = @"UserSettingsChangedNotification";
NSString * const kPTMeetingAvailabilityReadyNotification = @"MeetingAvailabilityReadyNotification";

#pragma mark - Other Constants

+ (UIColor *)tintColor {
    return [UIColor colorWithRed:150.0/255.0 green:210.0/255.0 blue:108.0/255.0 alpha:1.0];
}

@end
