//
//  PTRevealViewController.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/11/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTRevealViewController.h"

@interface PTRevealViewController ()
@property (strong, nonatomic) PFLogInViewController *logInViewController;

@end

@implementation PTRevealViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _logInViewController = [[PFLogInViewController alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    if (![PFUser currentUser]) {
        self.logInViewController.delegate = self;
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        signUpViewController.delegate = self;
        [self.logInViewController setSignUpController:signUpViewController];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self presentViewController:self.logInViewController animated:YES completion:NULL];
}

#pragma mark - PFLogInViewController Delegate

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    
    if (username && password && username.length && password.length) {
        return YES;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"You must provide a username and password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    return NO;
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    
}

#pragma mark - PFSignUpViewController Delegate

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) {
            informationComplete = NO;
            break;
        }
    }
    
    if (!informationComplete) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Be sure to fill out all required fields!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    return informationComplete;
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {   
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    
}

@end
