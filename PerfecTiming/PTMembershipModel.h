//
//  PTMembershipModel.h
//  PerfecTiming
//
//  Created by Brian Golden on 11/26/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "PTGroup.h"

@interface PTMembershipModel : NSObject

+ (void)cleanupMembershipForGroup:(PTGroup *)group user:(PFUser *)user;

@end
