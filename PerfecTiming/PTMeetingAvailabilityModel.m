//
//  PTMeetingAvailabilityModel.m
//  PerfecTiming
//
//  Created by MTSS User on 11/22/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMeetingAvailabilityModel.h"

@implementation PTMeetingAvailabilityModel

+ (id)sharedInstance {
    static id singletion = nil;
    if (!singletion) {
        singletion = [[self alloc] init];
    }
    return singletion;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
