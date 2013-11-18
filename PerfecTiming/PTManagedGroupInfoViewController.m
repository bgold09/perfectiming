//
//  PTManagedGroupInfoViewController.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/17/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTManagedGroupInfoViewController.h"
#import "Constants.h"

@interface PTManagedGroupInfoViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *pinCell;
- (IBAction)deletePressed:(id)sender;

@end

@implementation PTManagedGroupInfoViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.group.name;
    [self.nameCell.detailTextLabel setText:self.group.name];
    [self.pinCell.detailTextLabel setText:[NSString stringWithFormat:@"%d", self.group.pin]];
}

- (IBAction)deletePressed:(id)sender {
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete the group '%@'?", self.group.name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:message delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
}

- (void)fireNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPTDeletedGroupNotification object:self];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self.group deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[error userInfo] objectForKey:@"error"] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
            
            if (succeeded) {
                [self performSelectorOnMainThread:@selector(fireNotification) withObject:nil waitUntilDone:YES];
            }
        }];
        
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
