//
//  PTCreateMeetingTimeViewController.m
//  PerfecTiming
//
//  Created by MTSS User on 11/19/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTCreateMeetingTimeViewController.h"
#import "PTMeetingTime.h"
#import "NSDate+Compare.h"
#import "Constants.h"

@interface PTCreateMeetingTimeViewController ()
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *startTimePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
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
    self.startTimePicker.minimumDate = [NSDate date];
    [self.startTimePicker addTarget:self action:@selector(startDateChanged) forControlEvents:UIControlEventValueChanged];
    [self.endDatePicker addTarget:self action:@selector(endDateChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)meetingTimeExists {
    PFQuery *query = [PTMeeting query];
    [query whereKey:@"meeting" equalTo:self.meeting];
    [query whereKey:@"startDatetime" equalTo:self.startTime];
    [query whereKey:@"endDatetime" equalTo:self.endTime];
    
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
        
        [self performSelectorInBackground:@selector(createMeetingTimeActual) withObject:nil];
    }];
}

- (void)createMeetingTime {
    self.startTime = self.startTimePicker.date;
    self.endTime = self.endDatePicker.date;
    [self meetingTimeExists];
}

- (void)createMeetingTimeActual {
    NSDate *startDate = self.startTime;
    NSDate *endDate = self.endTime;

    PTMeetingTime *meetingTime = [PTMeetingTime meetingTimeWithMeeting:self.meeting startDate:startDate endDate:endDate];
    NSError *error;
    [meetingTime save:&error];
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self performSelectorOnMainThread:@selector(fireMeetingTimeCreatedNotification) withObject:nil waitUntilDone:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Notifications

- (void)fireMeetingTimeCreatedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPTMeetingTimeCreatedNotification object:self];
}

#pragma mark - Target Actions

- (void)startDateChanged {
    NSDate *selectedDate = self.startTimePicker.date;
    NSDate *minDate = self.startTimePicker.minimumDate;
    
    if ([selectedDate isLessThanDate:minDate]) {
        [self.startTimePicker setDate:minDate animated:YES];
    } else if ([selectedDate isGreaterThanDate:self.endDatePicker.date]) {
        NSDate *newEndDate = [self.startTimePicker.date dateByAddingTimeInterval:60*60];
        [self.endDatePicker setDate:newEndDate];
    }
}

- (void)endDateChanged {
    
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)savePressed:(id)sender {
    [self createMeetingTime];
}

@end
