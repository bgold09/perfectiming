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
@property (strong, nonatomic) MBProgressHUD *progressHUD;
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

- (BOOL)groupExistsWithName:(NSString *)name {
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKey:@"name" equalTo:name];
    
    __block NSError *error;
    __block NSInteger count;
    __block BOOL groupExists = NO;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        count = [query countObjects:&error];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a problem contacting the server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            groupExists = YES;
        }
        
        if (count > 0) {
            NSString *message = [NSString stringWithFormat:@"A group with the name '%@' already exists.", name];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate Group Name" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            groupExists = YES;
        }
    });
    
    return groupExists;
}

- (void)createManagedGroup {
    NSString *groupName = self.groupNameField.text;
    
    if ([self groupExistsWithName:groupName]) {
        return;
    }
    
    NSInteger pin = kPINLowerBound + arc4random() % (kPINUpperBound - kPINLowerBound);
    
    PTGroup *group = [PTGroup object];
    group.name = groupName;
    group.manager = [PFUser currentUser];
    group.pin = pin;
    
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kPTAddGroupNotification object:self];
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
