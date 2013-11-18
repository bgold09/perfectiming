//
//  PTManagedGroupInfoViewController.h
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/17/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTGroup.h"

@interface PTManagedGroupInfoViewController : UITableViewController <UIAlertViewDelegate>
@property (strong, nonatomic) PTGroup *group;

@end
