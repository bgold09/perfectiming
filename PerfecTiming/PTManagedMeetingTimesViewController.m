//
//  PTManagedMeetingTimesViewController.m
//  PerfecTiming
//
//  Created by MTSS User on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTManagedMeetingTimesViewController.h"
#import "PTCreateMeetingTimeViewController.h"
#import "PTMeetingAttendeeAvailabilitiesViewController.h"
#import "PTMeetingTime.h"
#import "PTMembership.h"
#import "PTMeetingAttendee.h"
#import "Constants.h"

static NSString * const CellIdentifierRed = @"RedCell";
static NSString * const CellIdentifierYellow = @"YellowCell";
static NSString * const CellIdentifierGreen = @"GreenCell";

@interface PTManagedMeetingTimesViewController ()

@end

@implementation PTManagedMeetingTimesViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = [PTMeetingTime parseClassName];
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 25;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:kPTMeetingTimeCreatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMeetingAttendees:) name:kPTMeetingTimeCreatedNotification object:nil];
}

#pragma mark - Notifcation Handlers

- (void)refreshTable:(NSNotification *)notification {
    [self loadObjects];
}

- (void)handleMeetingAttendees:(NSNotification *)notification {
    // a new meeting time was created
    // if first meeting time, create new MeetingAttendees
    // if not first meeting time, upadte existing MeetingAttendees for this meeting asking for availabilities

    if (self.objects.count == 0) {
        PTGroup *group = self.meeting.group;
        // get members of the group and create attendees
        [self performSelectorInBackground:@selector(findGroupMembersAndCreateAttendeesForGroup:) withObject:group];
    } else {
        // not first meeting time
        // update existing
    }
}

- (void)findGroupMembersAndCreateAttendeesForGroup:(PTGroup *)group {
    PFQuery *query = [PTMembership query];
    [query whereKey:@"group" equalTo:group];
    [query includeKey:@"user"];
    
    NSError *error;
    NSArray *memberships = [query findObjects:&error];
    
    if (error) {
        return;
    }
    
    NSMutableArray *attendees = [NSMutableArray array];
    for (PTMembership *membership in memberships) {
        PFUser *user = membership.user;
        PFQuery *query = [PTMeetingAttendee query];
        [query whereKey:@"user" equalTo:user];
        [query whereKey:@"meeting" equalTo:self.meeting];
        
        NSError *error;
        PFObject *object = [query getFirstObject:&error];
        
        if (object) {
            // create the MeetingAttendee object if one does not already exist for this user and meeting
            PTMeetingAttendee *attendee = [PTMeetingAttendee meetingAttendeeWithUser:user meeting:self.meeting];
            [attendees addObject:attendee];
        }
    }
    
    [PFObject saveAllInBackground:attendees block:^(BOOL succeeded, NSError *error) {
        if (error) {
            // delete meeting time?
            [self performSelectorOnMainThread:@selector(showCreationErrorAlertWithError:) withObject:error waitUntilDone:YES];
            return;
        }
    }];
}

- (void)showCreationErrorAlertWithError:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@", error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Creating Attendees" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
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
    
    [query orderByAscending:@"startDatetime"];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    PTMeetingTime *meetingTime = (PTMeetingTime *) object;
    
    // get meeting availability numbers for subtitle and cell color
    
    NSString *CellIdentifier = CellIdentifierRed;
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *startDateString = [dateFormatter stringFromDate:meetingTime.startDatetime];
    NSString *endDateString = [dateFormatter stringFromDate:meetingTime.endDatetime];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", startDateString, endDateString];
    
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"MeetingAvailabilitiesSegue" sender:self];
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
    } else if ([segue.identifier isEqualToString:@"MeetingAvailabilitiesSegue"]) {
        PTMeetingAttendeeAvailabilitiesViewController *availabilitiesViewController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PTMeetingTime *meetingTime = (PTMeetingTime *) [self objectAtIndexPath:indexPath];
        availabilitiesViewController.meetingTime = meetingTime;
    }
}

@end
