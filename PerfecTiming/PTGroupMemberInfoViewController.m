//
//  PTGroupMemberInfoViewController.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTGroupMemberInfoViewController.h"

@interface PTGroupMemberInfoViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *memberSinceCell;

@end

@implementation PTGroupMemberInfoViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameCell.detailTextLabel.text = self.membership.user.username;
    self.emailCell.detailTextLabel.text = self.membership.user.email;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *dateString = [dateFormatter stringFromDate:self.membership.createdAt];
    
    self.memberSinceCell.textLabel.text = [NSString stringWithFormat:@"%@", dateString];
}

@end
