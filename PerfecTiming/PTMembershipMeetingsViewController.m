//
//  PTMembershipMeetingsViewController.m
//  PerfecTiming
//
//  Created by MTSS User on 11/21/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMembershipMeetingsViewController.h"
#import "PTMeetingAttendee.h"
#import "PTMeetingAvailabilityModel.h"
#import "Constants.h"

@interface PTMembershipMeetingsViewController ()
@property (strong, nonatomic) PTMeetingAvailabilityModel *availabilityModel;
@property (strong, nonatomic) NSIndexPath *attendeeIndexPath;
@property (strong, nonatomic) EKEventStore *eventStore;

@end

@implementation PTMembershipMeetingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = [PTMeetingAttendee parseClassName];
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 25;
        _availabilityModel = [PTMeetingAvailabilityModel sharedInstance];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFailAlert:) name:kPTAvailabilityFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendAvailability:) name:kPTAvailabilityReadyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSuccessAlert:) name:kPTAvailabilitySentNotification object:nil];
}

#pragma mark - Notifcation Handlers

- (void)refreshTable:(NSNotification *)notification {
    [self loadObjects];
}

- (void)showFailAlert:(NSNotification *)notification {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sending Failed" message:@"There was an error sending your availability. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)showSuccessAlert:(NSNotification *)notification {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send Succeeded" message:@"Your availability was sent to the grouip manager." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self loadObjects]; 
}

- (void)sendAvailability:(NSNotification *)notification {
    NSDictionary *dictionary = notification.object;
    PTMeetingAttendee *attendee = (PTMeetingAttendee *) [self objectAtIndexPath:self.attendeeIndexPath];
    [self.availabilityModel sendAvailabilityForMeetingAttendee:attendee availability:dictionary];
}

#pragma mark - PFQueryTableViewController Delegate

- (PFQuery *)queryForTable {
    if (![PFUser currentUser]) {
        return nil;
    }
    
    // all meeting for this group
    PFQuery *meetingsQuery = [PTMeeting query];
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
    
    if ([attendee hasSubmittedAvailability]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
    return [self.objects objectAtIndex:indexPath.row];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    self.attendeeIndexPath = indexPath;
    
    PTMeetingAttendee *attendee = (PTMeetingAttendee *) [self objectAtIndex:indexPath];
    if ([attendee hasSubmittedAvailability]) {
        NSString *message = [NSString stringWithFormat:@"You have already sent your availability for the meeting '%@'. Send updated availability?", attendee.meeting.name];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
        [alert show];
    } else {
        NSString *message = [NSString stringWithFormat:@"Send your availability to the group manager for the meeting '%@'?", attendee.meeting.name];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
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
    EKCalendarChooser *calendarChooser = [[EKCalendarChooser alloc] initWithSelectionStyle:EKCalendarChooserSelectionStyleMultiple
                                                                              displayStyle:EKCalendarChooserDisplayAllCalendars
                                                                                eventStore:eventStore];
    
    calendarChooser.showsDoneButton = YES;
    calendarChooser.showsCancelButton = YES;
    calendarChooser.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    calendarChooser.delegate = self;
    calendarChooser.selectedCalendars = [[NSSet alloc] init];
    self.eventStore = eventStore;
    
    UINavigationController *cntrol = [[UINavigationController alloc] initWithRootViewController:calendarChooser];
    [self presentViewController:cntrol animated:YES completion:NULL];
}

#pragma mark - EKCalendarChooserDelegate methods

- (void)calendarChooserDidCancel:(EKCalendarChooser *)calendarChooser {
    [calendarChooser dismissViewControllerAnimated:YES completion:NULL];
}

- (void)calendarChooserDidFinish:(EKCalendarChooser *)calendarChooser {
    PTMeetingAttendee *attendee = (PTMeetingAttendee *) [self objectAtIndexPath:self.attendeeIndexPath];
    PTMeeting *meeting = attendee.meeting;
    
    [self.availabilityModel buildAvailabilityForMeeting:meeting calendarStore:self.eventStore calendars:calendarChooser.selectedCalendars];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)calendarChooserSelectionDidChange:(EKCalendarChooser *)calendarChooser {
    
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self prepareForCalendarChooser];
    }
}

@end
