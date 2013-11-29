//
//  PTManagedMeetingsViewController.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTManagedMeetingsViewController.h"
#import "PTRevealViewController.h"
#import "PTAddMeetingViewController.h"
#import "PTManagedMeetingInfoViewController.h"
#import "PTManagedMeetingTimesViewController.h"
#import "PTMeeting.h"
#import "Constants.h"

static NSString * const kCellIdentifierWithLocation = @"CellWithLocation";
static NSString * const kCellIdentifierWithoutLocation = @"CellWithoutLocation";

@interface PTManagedMeetingsViewController ()
@property (strong, nonatomic) NSIndexPath *deleteIndexPath;
@property (strong, nonatomic) UIBarButtonItem *navButton;

@end

@implementation PTManagedMeetingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = [PTMeeting parseClassName];
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 25;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:kPTMeetingAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:kPTMeetingDeletedNotification object:nil];
}

#pragma mark - Notifcation Handlers

- (void)refreshTable:(NSNotification *)notification {
    [self loadObjects];
}

#pragma mark - PFQueryTableViewController Delegate

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    if ([PFUser currentUser]) {
        [query whereKey:@"group" equalTo:self.group];
    }
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:@"name"];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    PTMeeting *meeting = (PTMeeting *) object;
    
    NSString *CellIdentifier;
    if (meeting.location && meeting.location.length > 0) {
        CellIdentifier = kCellIdentifierWithLocation;
    } else {
        CellIdentifier = kCellIdentifierWithoutLocation;
    }
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = meeting.name;
    
    if ([CellIdentifier isEqualToString:kCellIdentifierWithLocation]) {
        cell.detailTextLabel.text = meeting.location;
    }
    
    return cell;
}

- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
    return [self.objects objectAtIndex:indexPath.row];
}

#pragma mark - UITableViewDataSource Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PTGroup *group = [self.objects objectAtIndex:indexPath.row];
        
        self.deleteIndexPath = indexPath;
        NSString *confirmMessage = [NSString stringWithFormat:@"Are you sure you want to delete the meeting '%@'?", group.name];
        UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:confirmMessage delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [confirmAlert show];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, and save it to Parse
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"MeetingTimesSegue" sender:self];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ManagedMeetingInfoSegue" sender:self];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        PTMeeting *meeting =  (PTMeeting *) [self objectAtIndexPath:self.deleteIndexPath];
        
        [meeting deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSString *message = [NSString stringWithFormat:@"%@", error];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Deleting Meeting" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
            if (succeeded) {
                [self loadObjects];
            }
        }];
    }
}

#pragma mark - Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    
    if (editing) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];
        self.navButton = self.navigationItem.leftBarButtonItem;
        [self.navigationItem setLeftBarButtonItem:addButton animated:YES];
    } else {
        [self.navigationItem setLeftBarButtonItem:self.navButton animated:YES];
    }
}

#pragma mark - Segues

- (void)addButtonPressed {
    [self performSegueWithIdentifier:@"AddMeetingSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddMeetingSegue"]) {
        PTAddMeetingViewController *addMeetingViewController = segue.destinationViewController;
        addMeetingViewController.group = self.group;
    } else if ([segue.identifier isEqualToString:@"ManagedMeetingInfoSegue"]) {
        PTManagedMeetingInfoViewController *infoViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        infoViewController.meeting = (PTMeeting *) [self objectAtIndex:indexPath];
    } else if ([segue.identifier isEqualToString:@"MeetingTimesSegue"]) {
        PTManagedMeetingTimesViewController *timesViewController = segue.destinationViewController;
                NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        timesViewController.meeting = (PTMeeting *) [self objectAtIndex:indexPath];
    }
}

@end
