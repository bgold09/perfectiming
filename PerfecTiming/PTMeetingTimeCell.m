//
//  PTMeetingTimeCell.m
//  PerfecTiming
//
//  Created by Brian Golden on 12/4/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMeetingTimeCell.h"
#import "Constants.h"

#define kGreenThreshhold 0.8
#define kYellowThreshhold 0.5

@interface PTMeetingTimeCell ()


@end

@implementation PTMeetingTimeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setupWithMeetingTime:(PTMeetingTime *)meetingTime {
    _availabilityReady = NO;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *startString = [dateFormatter stringFromDate:meetingTime.startDatetime];
    NSString *endString = [dateFormatter stringFromDate:meetingTime.endDatetime];
    _startLabel.text = [NSString stringWithFormat:@"Start: %@", startString];
    _endLabel.text = [NSString stringWithFormat:@"End: %@", endString];
    _availabilityNumberLabel.text = @"Retrieving meeting availability...";
    
    NSString *notificationName = [meetingTime availabilityReadyForMeetingTimeNotificationName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellWithPercentage:) name:notificationName object:nil];
    
    [_indicatorView startAnimating];
    [_indicatorView setHidesWhenStopped:YES];
    
    [self performSelectorInBackground:@selector(getAvailabilityForMeetingTime:) withObject:meetingTime];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - Notification Handlers

- (void)updateCellWithPercentage:(NSNotification *)notification {
    NSDictionary *dictionary = notification.object;
    
    NSNumber *percentageNumber = [dictionary objectForKey:@"percentage"];
    CGFloat percentage = [percentageNumber floatValue];
    
    NSNumber *unrespondedNumber = [dictionary objectForKey:@"unresponded"];
    NSInteger unresponded = [unrespondedNumber integerValue];
    
    NSMutableString *availabilityString = [NSMutableString stringWithFormat:@"%.0f%% available", percentage * 100];
    if (unresponded > 0) {
        NSString *unrespondedString = [NSString stringWithFormat:@" (%d unresponded)", unresponded];
        [availabilityString appendString:unrespondedString];
    }
    
    self.availabilityNumberLabel.text = availabilityString;
    
    if (percentage < kYellowThreshhold) {
        self.backgroundColor = [UIColor redColor];
    } else if (percentage >= kYellowThreshhold && percentage < kGreenThreshhold) {
        self.backgroundColor = [UIColor yellowColor];
    } else {
        self.backgroundColor = [UIColor greenColor];
    }
    
    [self.indicatorView stopAnimating];
    self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    _availabilityReady = YES;
}

#pragma mark - Private Methods

- (void)getAvailabilityForMeetingTime:(PTMeetingTime *)meetingTime {
    [meetingTime getAvailabilityForAllAttendees];
}

@end
