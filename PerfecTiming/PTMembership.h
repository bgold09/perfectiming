//
//  PTMembership.h
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/17/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Parse/Parse.h>
#import "PTGroup.h"

@interface PTMembership : PFObject <PFSubclassing>

@property (retain) PFUser *user;
@property (retain) PTGroup *group;
+ (NSString *)parseClassName;

@end
