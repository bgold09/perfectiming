//
//  PTMeetingAttendeeAvailabilitiesViewController.h
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/19/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Parse/Parse.h>
#import "PTMeeting.h"

@interface PTMeetingAttendeeAvailabilitiesViewController : PFQueryTableViewController
@property (strong, nonatomic) PTMeeting *meeting;

@end
