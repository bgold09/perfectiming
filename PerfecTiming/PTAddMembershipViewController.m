//
//  PTAddMembershipViewController.m
//  PerfecTiming
//
//  Created by MTSS User on 11/17/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTAddMembershipViewController.h"
#import <Parse/Parse.h>
#import "PTMembership.h"
#import "PTMeetingAttendee.h"
#import "PTPushModel.h"
#import "PTChannelModel.h"
#import "MBProgressHUD.h"
#import "Constants.h"

@interface PTAddMembershipViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *pinField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)savePressed:(id)sender;

@end

@implementation PTAddMembershipViewController

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
    self.pinField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.nameField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.pinField];
}

// calls synchronous methods; should be dispatched on background thread
- (void)createGroupMembership {
    NSString *groupName = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    PFQuery *query = [PTMembership query];
    [query whereKey:@"name" equalTo:groupName];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    NSError *error;
    NSInteger count = [query countObjects:&error];
    if (error) {
        [self performSelectorOnMainThread:@selector(showFailureAlert:) withObject:error waitUntilDone:NO];
        return;
    } else if (count > 0) {
        NSString *message = [NSString stringWithFormat:@"You are already a member of the group '%@'", groupName];
        [self performSelectorOnMainThread:@selector(showAlertWithMessage:) withObject:message waitUntilDone:NO];
        return;
    }
    
    PFQuery *groupQuery = [PTGroup query];
    [groupQuery whereKey:@"name" equalTo:groupName];
    PTGroup *group = (PTGroup *) [groupQuery getFirstObject:&error];
    if (error) {
        [self performSelectorOnMainThread:@selector(showFailureAlert:) withObject:error waitUntilDone:NO];
        return;
    }
    
    NSInteger pin = [self.pinField.text integerValue];
    if (group.pin != pin) {
        NSString *message = [NSString stringWithFormat:@"The PIN you entered does not match the PIN for the group '%@'.", groupName];
        [self performSelectorOnMainThread:@selector(showFailureAlert:) withObject:message waitUntilDone:NO];
        return;
    }
    
    PTMembership *membership = [PTMembership membershipWithGroup:group user:[PFUser currentUser]];
    if (![membership save:&error]) {
        [self performSelectorOnMainThread:@selector(showFailureAlert:) withObject:error waitUntilDone:NO];
    }
    
    // create attendee objects for existing meetings
    PFQuery *meetingQuery = [PTMeeting query];
    [query whereKey:@"group" equalTo:group];
    NSArray *meetings = [meetingQuery findObjects:&error];
    if (error) {
        [self performSelectorOnMainThread:@selector(showFailureAlert:) withObject:error waitUntilDone:NO];
        return;
    }
    
    NSMutableArray *attendees = [NSMutableArray array];
    for (PTMeeting *meeting in meetings) {
        PTMeetingAttendee *attendee = [PTMeetingAttendee meetingAttendeeWithUser:[PFUser currentUser] meeting:meeting];
        [attendees addObject:attendee];
    }
    
    [PFObject saveAll:attendees error:&error];
    if (error) {
        [self performSelectorOnMainThread:@selector(showFailureAlert:) withObject:error waitUntilDone:NO];
        return;
    }
    
    NSString *channelName = [group channelName];
    [PTChannelModel addChannelWithName:channelName user:[PFUser currentUser]];
    
    [self performSelectorOnMainThread:@selector(fireNotification:) withObject:group waitUntilDone:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Target Actions

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)savePressed:(id)sender {
    [self.nameField resignFirstResponder];
    [self.pinField resignFirstResponder];
    self.saveButton.enabled = NO;
    self.cancelButton.enabled = NO;
    
    if (!self.nameField.text) {
        NSDictionary *dictionary = @{@"title": @"No Name Provided",
                                     @"message": @"You must enter the name of the group to join."};
        [self showAlert:dictionary];
        
        self.saveButton.enabled = YES;
        self.cancelButton.enabled = YES;
    } else if ([self.nameField.text rangeOfString:@"_"].location != NSNotFound) {
        NSDictionary *dictionary = @{@"title": @"Group name cannot contain underscores."};
        [self showAlert:dictionary];
        
        self.saveButton.enabled = YES;
        self.cancelButton.enabled = YES;
    } else if (!self.pinField.text) {
        NSDictionary *dictionary = @{@"title": @"No PIN Provided",
                                     @"message": @"You must enter the PIN of the group to join."};
        [self showAlert:dictionary];
        
        self.saveButton.enabled = YES;
        self.cancelButton.enabled = YES;
    } else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Joining Group";
        [self performSelectorInBackground:@selector(createGroupMembership) withObject:nil];
    }
}

#pragma mark - Notifications

- (void)fireNotification:(PTGroup *)group {
    PFUser *user = [PFUser currentUser];
    NSString *message =[NSString stringWithFormat:@"User %@ joined your group '%@'", user.username, group.name];
    [PTPushModel sendPushToManagerForGroup:group message:message pushType:PTPushTypeGroupUserJoined];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPTMembershipAddedNotification object:self];
}

#pragma mark - Notification Handlers

- (void)textInputChanged:(NSNotification *)notification {
    BOOL enableSaveButton = NO;
    
    if (self.nameField.text && self.nameField.text.length > 0 &&
        self.pinField.text && self.pinField.text.length > 0) {
        enableSaveButton = YES;
    }
    
    self.saveButton.enabled = enableSaveButton;
}

#pragma mark - Alerts

- (void)showFailureAlert:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a problem contacting the server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    self.saveButton.enabled = YES;
    self.cancelButton.enabled = YES;
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    self.saveButton.enabled = YES;
    self.cancelButton.enabled = YES;
}

- (void)showAlert:(NSDictionary *)content {
    NSString *title = [content objectForKey:@"title"];
    NSString *message = [content objectForKey:@"message"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UITextView Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
