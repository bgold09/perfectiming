//
//  PTAddManagedGroupViewController.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/12/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTAddManagedGroupViewController.h"
#import <Parse/Parse.h>

@interface PTAddManagedGroupViewController ()
@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)savePressed:(id)sender;

@end

@implementation PTAddManagedGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.groupNameField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textInputChanged:) name:UITextFieldTextDidChangeNotification object:self.groupNameField];
}

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
    } else {
        [self createManagedGroup];
    }
}

- (void)createManagedGroup {
    PFUser *currentUser = [PFUser currentUser];
    NSString *groupName = self.groupNameField.text;
    
    PFObject *group = [PFObject objectWithClassName:@"Group"];
    [group setObject:groupName forKey:@"name"];
    [group setObject:currentUser forKey:@"manager"];
    
    PFACL *groupACL = [PFACL ACL];
    groupACL.publicReadAccess = YES;
    groupACL.publicWriteAccess = NO;
    group.ACL = groupACL;
    
    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddedGroupNotification" object:self];
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

@end
