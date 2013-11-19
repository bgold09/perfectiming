//
//  PTManagedMeetingInfoViewController.m
//  PerfecTiming
//
//  Created by MTSS User on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTManagedMeetingInfoViewController.h"
#import "PTManagedMeetingTimesViewController.h"

@interface PTManagedMeetingInfoViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *locationCell;

@end

@implementation PTManagedMeetingInfoViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameCell.detailTextLabel.text = self.meeting.name;
    if (self.meeting.location && self.meeting.location.length > 0) {
        self.locationCell.detailTextLabel.text = self.meeting.location;
    } else {
        self.locationCell.detailTextLabel.text = @"N/A";
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MeetingTimesSegue"]) {
        PTManagedMeetingTimesViewController *timesViewController = segue.destinationViewController;
        timesViewController.meeting = self.meeting;
    } else if ([segue.identifier isEqualToString:@"MeetingAttendeesSegue"]) {
        
    }
}

@end
