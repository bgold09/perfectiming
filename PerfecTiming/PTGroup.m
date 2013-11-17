//
//  PTGroup.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/12/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTGroup.h"
#import <Parse/PFObject+Subclass.h>

@implementation PTGroup

@dynamic name;
@dynamic manager;
@dynamic pin;

+ (NSString *)parseClassName {
    return @"Group";
}

@end
