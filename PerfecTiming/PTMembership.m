//
//  PTMembership.m
//  PerfecTiming
//
//  Created by MTSS User on 11/17/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMembership.h"
#import <Parse/PFObject+Subclass.h>

@implementation PTMembership

@dynamic user;
@dynamic group;

+ (NSString *)parseClassName {
    return @"Membership";
}

@end