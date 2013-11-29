//
//  PFUser+Compare.m
//  PerfecTiming
//
//  Created by Brian Golden on 11/29/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PFUser+Compare.h"

@implementation PFUser (Compare)

- (NSComparisonResult)compareToUser:(PFUser *)user {
    return [self.username compare:user.username];
}

@end
