//
//  PTSettingsViewController.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/8/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTSettingsViewController.h"
#import "PTEditSettingsViewController.h"
#import "PTRevealViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface PTSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *usernameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
- (IBAction)logoutPressed:(id)sender;

@end

@implementation PTSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor: [UIColor colorWithRed:150.0/255.0 green:210.0/255.0 blue:108.0/255.0 alpha:1.0]];
    
    self.menuButton.target = self.revealViewController;
    self.menuButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self setFields:nil];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    self.logoutCell.backgroundView = backView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFields:) name:kPTUserSettingsChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFields:) name:kPTUserLoggedInNotification object:nil];
}

#pragma mark - Notification Handlers

- (void)setFields:(NSNotification *)notification {
    self.usernameCell.detailTextLabel.text = [[PFUser currentUser] username];
    self.emailCell.detailTextLabel.text = [[PFUser currentUser] email];
    self.nameCell.detailTextLabel.text = [[PFUser currentUser] objectForKey:@"name"];
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

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditSettingsSegue"]) {
        PTEditSettingsViewController *viewController = segue.destinationViewController;
        PFUser *user = [PFUser currentUser];
        
        NSString *name = [user objectForKey:@"name"];
        if (!name) {
            name = @"";
        }
        
        NSDictionary *dictionary = @{@"name": name, @"email": user.email};
        viewController.dictionary = dictionary;
    }
}

@end
