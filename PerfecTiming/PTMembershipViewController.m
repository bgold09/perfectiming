//
//  PTMembershipViewController.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/8/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMembershipViewController.h"
#import "UIViewController+FrontRevealSetup.h"
#import "PTRevealViewController.h"
#import "PTMembershipMeetingsViewController.h"
#import "PTMembershipInfoViewController.h"
#import "PTMembership.h"
#import "PTPushModel.h"
#import "PTMembershipModel.h"
#import "Constants.h"

@interface PTMembershipViewController ()
@property (strong, nonatomic) NSIndexPath *deleteIndexPath;
@property (strong, nonatomic) NSIndexPath *infoIndexPath;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@end

@implementation PTMembershipViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = [PTMembership parseClassName];
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 25;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpForFrontReveal];
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:kPTMembershipAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:kPTUserLoggedOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:kPTUserLoggedInNotification object:nil];
}

#pragma mark - Notifcation Handlers

- (void)refreshTable:(NSNotification *)notification {
    [self loadObjects];
}

#pragma mark - PFQueryTableViewController Delegate

- (PFQuery *)queryForTable {
    if (![PFUser currentUser]) {
        return nil;
    }

    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query includeKey:@"group"];
    [query includeKey:@"group.manager"];
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"group" ascending:YES selector:@selector(compareToGroup:)];
    [query orderBySortDescriptor:sortDescriptor];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PTMembership *membership = (PTMembership *) object;
    cell.textLabel.text = membership.group.name;
    
    return cell;
}

- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
    return [self.objects objectAtIndex:indexPath.row];
}

#pragma mark - UITableViewDataSource Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PTMembership *membership = [self.objects objectAtIndex:indexPath.row];
        
        self.deleteIndexPath = indexPath;
        NSString *confirmMessage = [NSString stringWithFormat:@"Are you sure you want to remove yourself from the group '%@'?", membership.group.name];
        UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"Confirm Removal" message:confirmMessage delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [confirmAlert show];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, and save it to Parse
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    self.infoIndexPath = indexPath;
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        PTMembership *membership = (PTMembership *) [self objectAtIndexPath:self.deleteIndexPath];
        
        [membership deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSString *message = [NSString stringWithFormat:@"%@", error];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Removing From Group" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
            if (succeeded) {
                [self deleteMembershipForGroup:membership.group];
            }
        }];
    }
}

- (void)deleteMembershipForGroup:(PTGroup *)group {
    PFUser *user = [PFUser currentUser];
    [PTMembershipModel cleanupMembershipForGroup:group user:user];
    NSString *message = [NSString stringWithFormat:@"User %@ left your group '%@'.", user.username, group.name];
    [PTPushModel sendPushToManagerForGroup:group message:message pushType:PTPushTypeGroupUserLeft];
    [self loadObjects];
}

#pragma mark - Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    if (editing) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];
        [self.navigationItem setLeftBarButtonItems:@[addButton] animated:YES];
        [self.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
    } else {
        [self placeMenuButton];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark - Segues

- (void)addButtonPressed {
    [self performSegueWithIdentifier:@"AddMembershipSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MembershipMeetingsSegue"]) {
        PTMembershipMeetingsViewController *meetingsViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PTMembership *membership = (PTMembership *) [self objectAtIndexPath:indexPath];
        meetingsViewController.group = membership.group;
    } else if ([segue.identifier isEqualToString:@"MembershipInfoSegue"]) {
        PTMembershipInfoViewController *infoViewController = segue.destinationViewController;
        PTMembership *membership = (PTMembership *) [self objectAtIndexPath:self.infoIndexPath];
        PTGroup *group = membership.group;
        infoViewController.group = group;
    }
}

@end
