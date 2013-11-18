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
#import "Constants.h"

@interface PTAddMembershipViewController ()
@property (strong, nonatomic) PTGroup *group;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *pinField;
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
    
    self.nameField.delegate = self;
    self.pinField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.nameField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.pinField];
}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)savePressed:(id)sender {
    [self.nameField resignFirstResponder];
    [self.pinField resignFirstResponder];
    
    if (!self.nameField.text) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Name Provided"
                                                        message:@"You must enter the name of the group to join."
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else if (!self.pinField.text) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No PIN Provided"
                                                        message:@"You must enter the PIN of the group to join."
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        [self createGroupMembership];
    }
}

- (BOOL)userIsMemberOfGroupWithName:(NSString *)groupName {
    PTGroup *group = [PTGroup groupWithName:groupName];
    
    if (!group) {
        return NO;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:[PTMembership parseClassName]];
    [query whereKey:@"group" equalTo:group];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    NSError *error;
    BOOL memberOfGroup = NO;
    NSInteger count = [query countObjects:&error];
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a problem contacting the server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        memberOfGroup = YES;
    }
    
    if (count > 0) {
        NSString *message = [NSString stringWithFormat:@"You are already a member of the group '%@' already exists.", group.name];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Group Name" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        memberOfGroup = YES;
    } else {
        self.group = group;
    }
    
    return memberOfGroup;
}

- (void)createGroupMembership {
    NSString *groupName = self.nameField.text;
    if ([self userIsMemberOfGroupWithName:groupName]) {
        return;
    }
    
    NSInteger pin = [self.pinField.text integerValue];
    
    if (self.group.pin != pin) {
        NSString *message = [NSString stringWithFormat:@"The PIN you entered does not match the PIN for the group '%@'.", groupName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PIN Incorrect" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    PTMembership *membership = [PTMembership membershipWithGroup:self.group user:[PFUser currentUser]];
    
    PFACL *groupACL = [PFACL ACL];
    groupACL.publicReadAccess = YES;
    groupACL.publicWriteAccess = YES;
    membership.ACL = groupACL;
    
    [membership saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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

#pragma mark - UITextView Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
