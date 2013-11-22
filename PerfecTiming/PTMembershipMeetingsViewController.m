//
//  PTMembershipMeetingsViewController.m
//  PerfecTiming
//
//  Created by MTSS User on 11/21/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMembershipMeetingsViewController.h"
#import "PTMeetingAttendee.h"

@interface PTMembershipMeetingsViewController ()

@end

@implementation PTMembershipMeetingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = [PTMeetingAttendee parseClassName];
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
    if (![PFUser currentUser]) {
        return nil;
    }
    
    // all meeting for this group
    PFQuery *meetingsQuery = [PFQuery queryWithClassName:[PTMeeting parseClassName]];
    [meetingsQuery whereKey:@"group" equalTo:self.group];
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"meeting" matchesQuery:meetingsQuery];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query includeKey:@"meeting"];
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PTMeetingAttendee *attendee = (PTMeetingAttendee *) object;
    cell.textLabel.text = attendee.meeting.name;
    
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    PTMeetingAttendee *attendee = (PTMeetingAttendee *) [self objectAtIndex:indexPath];
    if (attendee.availability && attendee.availability.length > 0) {
        // already responded to meeting request
    } else {
        // yet to respond
        NSString *message = [NSString stringWithFormat:@"Send your availability to the group manager for the meeting '%@'?", attendee.meeting.name];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Respond to meeting?" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
        [alert show];
    }
}

#pragma mark - Calendar Chooser

- (void)prepareForCalendarChooser {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError* error) {
            if (!granted) {
                NSString *message = @"Hey! I Can't access your Calendar... check your privacy settings to let me in!";
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Warning"
                                                                   message:message
                                                                  delegate:self
                                                         cancelButtonTitle:@"Ok"
                                                         otherButtonTitles:nil];
                [alertView show];
            } else {
                [self performSelectorOnMainThread:@selector(displayCalendarChooserWithEventStore:) withObject:eventStore waitUntilDone:YES];
            }
        }];
    }
}

- (void)displayCalendarChooserWithEventStore:(EKEventStore *)eventStore {
    EKCalendarChooser *calendarChooser = [[EKCalendarChooser alloc]
                                          initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple
                                          displayStyle:EKCalendarChooserDisplayAllCalendars
                                          eventStore:eventStore];
    
    calendarChooser.showsDoneButton = YES;
    calendarChooser.showsCancelButton = YES;
    calendarChooser.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    calendarChooser.delegate = self;
    
    UINavigationController *cntrol = [[UINavigationController alloc] initWithRootViewController:calendarChooser];
    [self presentViewController:cntrol animated:YES completion:NULL];
}

#pragma mark - EKCalendarChooserDelegate methods

- (void)calendarChooserDidCancel:(EKCalendarChooser *)calendarChooser {
    [calendarChooser dismissViewControllerAnimated:YES completion:NULL];
}

- (void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser {
    
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self prepareForCalendarChooser];
    }
}

@end
