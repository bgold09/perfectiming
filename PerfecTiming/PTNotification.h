//
//  PTNotification.h
//  PerfecTiming
//
//  Created by Brian Golden on 12/14/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Parse/Parse.h>
#import "PTPushModel.h"

@interface PTNotification : PFObject <PFSubclassing>

@property (retain) PFUser *user;
@property (retain) NSString *message;
@property (retain) NSString *notificationObject;
@property BOOL read;
@property PTPushType pushType;

+ (PTNotification *)notificationForUser:(PFUser *)user message:(NSString *)message pushType:(PTPushType)pushType object:(PFObject *)object;
- (void)clearNotification;
- (void)markRead;

@end
