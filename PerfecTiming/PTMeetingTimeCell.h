//
//  PTMeetingTimeCell.h
//  PerfecTiming
//
//  Created by Brian Golden on 12/9/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTMeetingTime.h"

@interface PTMeetingTimeCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UILabel *availabilityNumberLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

- (void)setupWithMeetingTime:(PTMeetingTime *)meetingTime;

@end
