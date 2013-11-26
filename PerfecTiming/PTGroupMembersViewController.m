//
//  PTGroupMembersViewController.m
//  PerfecTiming
//
//  Created by MTSS User on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTGroupMembersViewController.h"
#import "PTGroupMemberInfoViewController.h"
#import "PTMembership.h"

@interface PTGroupMembersViewController ()
@property (strong, nonatomic) NSIndexPath *memberIndexPath;

@end

@implementation PTGroupMembersViewController
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
}

#pragma mark - Notifcation Handlers

- (void)refreshTable:(NSNotification *)notification {
    [self loadObjects];
}

#pragma mark - PFQueryTableViewController Delegate

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"group" equalTo:self.group];
    [query includeKey:@"user"];
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:@"createdAt"];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier= @"Cell";
    
    PTMembership *membership = (PTMembership *) object;
    PFTableViewCell *cell = (PFTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = membership.user.username;
    
    return cell;
}

- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
    return [self.objects objectAtIndex:indexPath.row];
}

/*
 // Override to customize the look of the cell that allows the user to load the next page of objects.
 // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
 static NSString *CellIdentifier = @"NextPage";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 }
 
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 cell.textLabel.text = @"Load more...";
 
 return cell;
 }
 */

#pragma mark - UITableViewDataSource Delegate

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
    self.memberIndexPath = indexPath;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"GroupMemberInfoSegue"]) {
        PTGroupMemberInfoViewController *infoViewController = segue.destinationViewController;
        infoViewController.membership = (PTMembership *) [self objectAtIndexPath:self.memberIndexPath];
    }
}

@end

