//
//  PTNotification.m
//  PerfecTiming
//
//  Created by Brian Golden on 12/14/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTNotification.h"
#import <Parse/PFObject+Subclass.h>

@implementation PTNotification

@dynamic user;
@dynamic message;
@dynamic notificationObject;
@dynamic read;
@dynamic pushType;

+ (NSString *)parseClassName {
    return @"Notification";
}

+ (PTNotification *)notificationForUser:(PFUser *)user message:(NSString *)message pushType:(PTPushType)pushType object:(PFObject *)object {
    PTNotification *notification = [PTNotification object];
    notification.user = user;
    notification.message = message;
    notification.pushType = pushType;
    notification.read = NO;
    
    if (object) {
        notification.notificationObject = object.objectId;
    }
    
    PFACL *ACL = [PFACL ACL];
    ACL.publicReadAccess = YES;
    ACL.publicWriteAccess = YES;
    notification.ACL = ACL;
    
    return notification;
}

- (void)clearNotification {
    [self deleteInBackground];
}

- (void)markRead {
    if (!self.read) {
        self.read = YES;
        [self saveInBackground];
    }
}

@end
