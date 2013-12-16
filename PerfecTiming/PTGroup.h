//
//  PTGroup.h
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/12/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Parse/Parse.h>

@interface PTGroup : PFObject <PFSubclassing>

@property (retain) NSString *name;
@property (retain) PFUser *manager;
@property NSInteger pin;

+ (NSString *)parseClassName;
+ (PTGroup *)groupWithName:(NSString *)name manager:(PFUser *)manager;
- (void)cleanup;
- (NSComparisonResult)compareToGroup:(PTGroup *)group;
- (NSString *)channelName;

@end
