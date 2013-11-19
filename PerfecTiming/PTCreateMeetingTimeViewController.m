//
//  PTCreateMeetingTimeViewController.m
//  PerfecTiming
//
//  Created by MTSS User on 11/19/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTCreateMeetingTimeViewController.h"
#import "PTMeetingTime.h"
#import "Constants.h"

static NSString * const kCreateMeetingTimeNotification = @"CreateMeetingTimeNotification";

@interface PTCreateMeetingTimeViewController ()
@property (strong, nonatomic) NSDate *meetingDateTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *meetingTimePicker;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)savePressed:(id)sender;

@end

@implementation PTCreateMeetingTimeViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createMeetingTimeActual) name:kCreateMeetingTimeNotification object:nil];
}

- (void)meetingTimeExists {
    PFQuery *query = [PFQuery queryWithClassName:[PTMeeting parseClassName]];
    [query whereKey:@"meeting" equalTo:self.meeting];
    [query whereKey:@"date" equalTo:self.meetingDateTime];
    
    [query countObjectsInBackgroundWithBlock:^(NSInteger count, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a problem contacting the server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        if (count > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Meeting Time" message:@"A meeting time with this date and time already exists." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        [self performSelectorOnMainThread:@selector(fireStartMeetingTimeCreationNotification) withObject:self waitUntilDone:NO];
    }];
}

- (void)createMeetingTime {
    self.meetingDateTime = self.meetingTimePicker.date;
    [self meetingTimeExists];
}

- (void)createMeetingTimeActual {
    NSDate *meetingDate = self.meetingDateTime;

    PTMeetingTime *meetingTime = [PTMeetingTime meetingTimeWithMeeting:self.meeting date:meetingDate];
    
    PFACL *meetingTimeACL = [PFACL ACL];
    meetingTimeACL.publicReadAccess = YES;
    meetingTimeACL.publicWriteAccess = YES;
    meetingTime.ACL = meetingTimeACL;
    
    [meetingTime saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        if (succeeded) {
            [self performSelectorOnMainThread:@selector(fireMeetingTimeCreatedNotification) withObject:nil waitUntilDone:YES];
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)fireStartMeetingTimeCreationNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCreateMeetingTimeNotification object:self];
}

- (void)fireMeetingTimeCreatedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPTMeetingTimeCreatedNotification object:self];
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)savePressed:(id)sender {
    [self createMeetingTime];
}

@end
