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
    PTNotification *notification = [[PTNotification alloc] initWithUser:user message:message pushType:pushType object:object];
    return notification;
}

- (id)initWithUser:(PFUser *)user message:(NSString *)message pushType:(PTPushType)pushType object:(PFObject *)object {
    self = [PTNotification object];
    if (self) {
        self.user = user;
        self.message = message;
        self.pushType = pushType;
        self.read = NO;

        if (object) {
            self.notificationObject = object.objectId;
        }
        
        PFACL *ACL = [PFACL ACL];
        ACL.publicReadAccess = YES;
        ACL.publicWriteAccess = YES;
        self.ACL = ACL;
    }
    
    return self;
}

- (void)clearNotification {
    [self deleteInBackground];
}

- (void)markRead {
    if (!read) {
        self.read = YES;
        [self saveInBackground];
    }
}

@end
