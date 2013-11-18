//
//  PTGroupMembersViewController.h
//  PerfecTiming
//
//  Created by MTSS User on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Parse/Parse.h>
#import "PTGroup.h"

@interface PTGroupMembersViewController : PFQueryTableViewController
@property (strong, nonatomic) PTGroup *group;

@end
