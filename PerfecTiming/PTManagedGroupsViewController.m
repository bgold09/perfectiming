//
//  PTManagedGroupsViewController.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/12/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTManagedGroupsViewController.h"
#import "PTRevealViewController.h"
#import "PTManagedGroupInfoViewController.h"
#import "PTManagedMeetingsViewController.h"
#import "PTGroup.h"
#import "Constants.h"

@interface PTManagedGroupsViewController ()
@property (strong, nonatomic) NSIndexPath *deleteIndexPath;
@property (strong, nonatomic) NSIndexPath *infoIndexPath;

@end

@implementation PTManagedGroupsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = [PTGroup parseClassName];
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 25;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor: [UIColor colorWithRed:150.0/255.0 green:210.0/255.0 blue:108.0/255.0 alpha:1.0]];
    
    self.navigationItem.rightBarButtonItems = @[self.editButtonItem];
    [self placeMenuButton];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:kPTGroupAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:kPTGroupDeletedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:kPTUserLoggedOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:kPTUserLoggedInNotification object:nil];
}

- (void)placeMenuButton {
    UIImage *menuImage = [UIImage imageNamed:@"menu.png"];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStyleBordered target:self.revealViewController action:@selector(revealToggle:)];
    [self.navigationItem setLeftBarButtonItems:@[menuButton] animated:YES];
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
    [query whereKey:@"manager" equalTo:[PFUser currentUser]];
    
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
    static NSString *CellIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PTGroup *group = (PTGroup *) object;
    cell.textLabel.text = group.name;
    
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
        PTGroup *group = [self.objects objectAtIndex:indexPath.row];
        
        self.deleteIndexPath = indexPath;
        NSString *confirmMessage = [NSString stringWithFormat:@"Are you sure you want to delete the group '%@'?", group.name];
        UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:confirmMessage delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
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
//    [super tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    self.infoIndexPath = indexPath;
    [self performSegueWithIdentifier:@"ManagedGroupInfoSegue" sender:nil];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        PTGroup *group =  (PTGroup *) [self objectAtIndexPath:self.deleteIndexPath];
        
        [group deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSString *message = [NSString stringWithFormat:@"%@", error];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Deleting Group" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
        [self.navigationItem setLeftBarButtonItems:@[addButton] animated:YES];
        [self.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
    } else {
        [self placeMenuButton];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddManagedGroupSegue"]) {
        
    } else if ([segue.identifier isEqualToString:@"ManagedGroupInfoSegue"]) {
        PTManagedGroupInfoViewController *infoViewController = segue.destinationViewController;
        PTGroup *group = (PTGroup *) [self objectAtIndexPath:self.infoIndexPath];
        infoViewController.group = group;
    } else if ([segue.identifier isEqualToString:@"ManagedMeetingsSegue"]) {
        PTManagedMeetingsViewController *meetingsViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PTGroup *group = (PTGroup *) [self objectAtIndexPath:indexPath];
        meetingsViewController.group = group;
    }
}

- (void)addButtonPressed {
    [self performSegueWithIdentifier:@"AddManagedGroupSegue" sender:self];
}

@end
