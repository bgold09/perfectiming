//
//  PTPushModel.h
//  PerfecTiming
//
//  Created by Brian Golden on 11/25/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface PTPushModel : NSObject

+ (void)sendPushToUser:(PFUser *)user message:(NSString *)message;

@end
