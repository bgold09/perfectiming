//
//  PTEditSettingsViewController.m
//  PerfecTiming
//
//  Created by Brian Golden on 11/26/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTEditSettingsViewController.h"
#import <Parse/Parse.h>
#import "NSString+Email.h"
#import "Constants.h"

@interface PTEditSettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)savePressed:(id)sender;

@end

@implementation PTEditSettingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor: [Constants tintColor]];
    
    self.nameField.delegate = self;
    self.emailField.delegate = self;
    
    self.nameField.text = [self.dictionary objectForKey:@"name"];
    self.emailField.text = [self.dictionary objectForKey:@"email"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.nameField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.emailField];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Notification Handlers

- (void)textInputChanged:(NSNotification *)notification {
    BOOL enableSaveButton = NO;
    
    if (self.nameField.text && self.nameField.text.length > 0 &&
        self.emailField.text && [self.emailField.text isValidEmail]) {
        enableSaveButton = YES;
    }
    
    self.saveButton.enabled = enableSaveButton;
}

#pragma mark - Target Actions

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)savePressed:(id)sender {
    PFUser *user = [PFUser currentUser];
    [user setEmail:self.emailField.text];
    [user setObject:self.nameField.text forKey:@"name"];
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self performSelectorOnMainThread:@selector(fireNotification) withObject:nil waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:NO];
            return;
        }
        
        [self performSelectorOnMainThread:@selector(showFailureAlertForError:) withObject:error waitUntilDone:NO];
    }];
}

- (void)showFailureAlertForError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)fireNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPTUserSettingsChangedNotification object:nil];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
