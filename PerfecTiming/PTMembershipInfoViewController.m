//
//  PTMembershipInfoViewController.m
//  PerfecTiming
//
//  Created by Brian Golden on 12/15/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMembershipInfoViewController.h"

@interface PTMembershipInfoViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *groupNameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *managerCell;

@end

@implementation PTMembershipInfoViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.groupNameCell.detailTextLabel.text = self.group.name;
    self.managerCell.detailTextLabel.text = self.group.manager.username;
}

@end
