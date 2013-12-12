//
//  PTManagedMeetingTimesViewController.h
//  PerfecTiming
//
//  Created by MTSS User on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Parse/Parse.h>
#import <EventKitUI/EventKitUI.h>
#import "PTMeeting.h"

@interface PTManagedMeetingTimesViewController : PFQueryTableViewController <EKEventEditViewDelegate>
@property (strong, nonatomic) PTMeeting *meeting;

@end
