//
//  PTPushModel.m
//  PerfecTiming
//
//  Created by Brian Golden on 11/25/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTPushModel.h"

@implementation PTPushModel

+ (void)sendPushToUser:(PFUser *)user message:(NSString *)message {
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" equalTo:user];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    [push setMessage:message];
    [push sendPushInBackground];
}

+ (void)sendPushToManagerForGroup:(PTGroup *)group message:(NSString *)message {
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" equalTo:group.manager];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    [push setMessage:message];
    [push sendPushInBackground];
}

@end
