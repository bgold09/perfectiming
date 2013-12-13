//
//  PTAddManagedGroupViewController.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/12/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTAddManagedGroupViewController.h"
#import <Parse/Parse.h>
#import "PTGroup.h"
#import "Constants.h"

#define kPINLowerBound 1000
#define kPINUpperBound 9999

@interface PTAddManagedGroupViewController ()
@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)savePressed:(id)sender;

@end

@implementation PTAddManagedGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor: [Constants tintColor]];
    
    self.groupNameField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.groupNameField];
}

// calls synchronous functions; should be dispatched on background thread
- (void)checkAndCreateManagedGroup {
    NSString *groupName = [self.groupNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    PFQuery *query = [PTGroup query];
    [query whereKey:@"name" equalTo:groupName];
    
    NSError *error;
    NSInteger count = [query countObjects:&error];
    
    if (error) {
        [self performSelectorOnMainThread:@selector(showFailureAlert:) withObject:error waitUntilDone:NO];
        return;
    } else if (count > 0) {
        NSString *message = [NSString stringWithFormat:@"A group with the name '%@' already exists.", groupName];
        [self performSelectorOnMainThread:@selector(showAlertWithMessage:) withObject:message waitUntilDone:NO];
        return;
    }
    
    NSInteger pin = kPINLowerBound + arc4random() % (kPINUpperBound - kPINLowerBound);
    
    PTGroup *group = [[PTGroup alloc] initWithName:groupName manager:[PFUser currentUser] pin:pin];
    if (![group save:&error]) {
        [self performSelectorOnMainThread:@selector(showFailureAlert:) withObject:error waitUntilDone:NO];
        return;
    } else {
        [self performSelectorOnMainThread:@selector(fireNotification) withObject:nil waitUntilDone:YES];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)fireNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPTGroupAddedNotification object:self];
}

#pragma mark - Notification Handlers

- (void)textInputChanged:(NSNotification *)notification {
    BOOL enableSaveButton = NO;
    
    if (self.groupNameField.text && self.groupNameField.text.length > 0) {
        enableSaveButton = YES;
    }
    
    self.saveButton.enabled = enableSaveButton;
}

#pragma mark - UITextView Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Alerts

- (void)showFailureAlert:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a problem contacting the server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Target Actions

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)savePressed:(id)sender {
    [self.groupNameField resignFirstResponder];
    
    if (!self.groupNameField.text) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Name Provided"
                                                        message:@"You must enter a name for your new group."
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    } else if ([self.groupNameField.text rangeOfString:@"_"].location != NSNotFound) {
        [self showAlertWithMessage:@"Group name cannot contain underscores."];
    } else {
        [self performSelectorInBackground:@selector(checkAndCreateManagedGroup) withObject:nil];
    }
}

@end
