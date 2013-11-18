//
//  PTSettingsViewController.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/8/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTSettingsViewController.h"
#import "PTRevealViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface PTSettingsViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
- (IBAction)logoutPressed:(id)sender;

@end

@implementation PTSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.menuButton.target = self.revealViewController;
    self.menuButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - Logout User

- (IBAction)logoutPressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log out of PerfecTiming?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log Out", nil];
    [alert show];
}

- (void)fireNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPTUserLoggedOutNotification object:self];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [PFUser logOut];
        [self performSelectorOnMainThread:@selector(fireNotification) withObject:nil waitUntilDone:YES];
    }
}

@end
