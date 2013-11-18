//
//  PTManagedMeetingsViewController.h
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Parse/Parse.h>
#import "PTGroup.h"

@interface PTManagedMeetingsViewController : PFQueryTableViewController
@property (strong, nonatomic) PTGroup *group;

@end
