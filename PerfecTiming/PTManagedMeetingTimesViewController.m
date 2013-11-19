//
//  PTManagedMeetingTimesViewController.m
//  PerfecTiming
//
//  Created by MTSS User on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTManagedMeetingTimesViewController.h"
#import "PTCreateMeetingTimeViewController.h"
#import "PTMeetingTime.h"
#import "Constants.h"

static NSString * const CellIdentifierRed = @"RedCell";
static NSString * const CellIdentifierYellow = @"YellowCell";
static NSString * const CellIdentifierGreen = @"GreenCell";

@interface PTManagedMeetingTimesViewController ()
@property (strong, nonatomic) NSIndexPath *meetingTimeIndexPath;

@end

@implementation PTManagedMeetingTimesViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // The className to query on
        self.parseClassName = [PTMeetingTime parseClassName];
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 25;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:kPTMeetingTimeCreatedNotification object:nil];
}

#pragma mark - Notifcation Handlers

- (void)refreshTable:(NSNotification *)notification {
    [self loadObjects];
}

#pragma mark - PFQueryTableViewController Delegate

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    if ([PFUser currentUser]) {
        [query whereKey:@"meeting" equalTo:self.meeting];
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
    
    [query orderByAscending:@"createdAt"];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    PTMeetingTime *meetingTime = (PTMeetingTime *) object;
    
    // get meeting availability numbers for subtitle and cell color
    
    NSString *CellIdentifier = CellIdentifierRed;
//    if (meeting.location && meeting.location.length > 0) {
//        CellIdentifier = kCellIdentifierWithLocation;
//    } else {
//        CellIdentifier = kCellIdentifierWithoutLocation;
//    }
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [dateFormatter stringFromDate:meetingTime.datetime];
    
    cell.textLabel.text = dateString;
    
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

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        PTGroup *group = [self.objects objectAtIndex:indexPath.row];
//
//        self.deleteIndexPath = indexPath;
//        NSString *confirmMessage = [NSString stringWithFormat:@"Are you sure you want to delete the meeting '%@'?", group.name];
//        UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"Confirm Delete" message:confirmMessage delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
//        [confirmAlert show];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, and save it to Parse
//    }
//}

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
    self.meetingTimeIndexPath = indexPath;
//    [self performSegueWithIdentifier:@"ManagedMeetingInfoSegue" sender:self];
}

//#pragma mark - UIAlertView Delegate
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex != [alertView cancelButtonIndex]) {
//        PTMeeting *meeting =  (PTMeeting *) [self objectAtIndexPath:self.deleteIndexPath];
//        
//        [meeting deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (error) {
//                NSString *message = [NSString stringWithFormat:@"%@", error];
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Deleting Meeting" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [alert show];
//            }
//            
//            if (succeeded) {
//                [self loadObjects];
//            }
//        }];
//    }
//}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddMeetingTimeSegue"]) {
        PTCreateMeetingTimeViewController *createMeetingTimeViewController = segue.destinationViewController;
        createMeetingTimeViewController.meeting = self.meeting;
    } else if ([segue.identifier isEqualToString:@""]) {
        
    }
}

@end
