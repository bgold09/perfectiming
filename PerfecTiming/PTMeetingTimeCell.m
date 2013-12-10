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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *startString = [dateFormatter stringFromDate:meetingTime.startDatetime];
    NSString *endString = [dateFormatter stringFromDate:meetingTime.endDatetime];
    _startLabel.text = [NSString stringWithFormat:@"Start: %@", startString];
    _endLabel.text = [NSString stringWithFormat:@"End: %@", endString];
    _availabilityNumberLabel.text = @"Retrieving meeting availability...";
    
    NSString *notificationName = [meetingTime availabilityReadyForMeetingTimeNotificationName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateColorWithPercentage:) name:notificationName object:nil];
    
    [self performSelectorInBackground:@selector(getAvailabilityForMeetingTime:) withObject:meetingTime];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (NSString *)reuseIdentifier {
    return kPTMeetingTimeCellIdentifier;
}

#pragma mark - Notification Handlers

- (void)updateColorWithPercentage:(NSNotification *)notification {
    NSNumber *number = notification.object;
    CGFloat percentage = [number floatValue];
    
    if (percentage < kYellowThreshhold) {
        self.backgroundColor = [UIColor redColor];
    } else if (percentage >= kYellowThreshhold && percentage < kGreenThreshhold) {
        self.backgroundColor = [UIColor yellowColor];
    } else {
        self.backgroundColor = [UIColor greenColor];
    }
}

#pragma mark - Private Methods

- (void)getAvailabilityForMeetingTime:(PTMeetingTime *)meetingTime {
    [meetingTime getAvailabilityForAllAttendees];
}

@end
