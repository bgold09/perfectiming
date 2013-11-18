//
//  PTAddMeetingViewController.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTAddMeetingViewController.h"
#import <Parse/Parse.h>
#import "PTMeeting.h"
#import "Constants.h"

@interface PTAddMeetingViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)savePressed:(id)sender;

@end

@implementation PTAddMeetingViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameField.delegate = self;
    self.locationField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.nameField];
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)savePressed:(id)sender {
    [self.nameField resignFirstResponder];
    [self.locationField resignFirstResponder];
    
    if (!self.nameField.text) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Name Provided"
                                                        message:@"You must enter the name for this new meeting."
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        [self createMeeting];
    }
}

- (void)createMeeting {
    NSString *meetingName = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    
    PTMeeting *meeting = [PTMeeting meetingWithName:meetingName group:self.group location:self.locationField.text];
    
    PFACL *meetingACL = [PFACL ACL];
    meetingACL.publicReadAccess = YES;
    meetingACL.publicWriteAccess = YES;
    meeting.ACL = meetingACL;
    
    [meeting saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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

- (void)fireNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPTMeetingAddedNotification object:self];
}

#pragma mark - Notification Handlers

- (void)textInputChanged:(NSNotification *)notification {
    BOOL enableSaveButton = NO;
    
    if (self.nameField.text && self.nameField.text.length > 0) {
        enableSaveButton = YES;
    }
    
    self.saveButton.enabled = enableSaveButton;
}

#pragma mark - UITextView Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end

