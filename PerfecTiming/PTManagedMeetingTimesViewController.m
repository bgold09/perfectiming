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
#import "PTMeetingTimeCell.h"
#import "PTMeetingTime.h"
#import "PTMembership.h"
#import "PTMeetingAttendee.h"
#import "PTPushModel.h"
#import "Constants.h"

static NSString * const CellIdentifierRed = @"RedCell";
static NSString * const CellIdentifierYellow = @"YellowCell";
static NSString * const CellIdentifierGreen = @"GreenCell";

@interface PTManagedMeetingTimesViewController ()

@property (strong, nonatomic) UINib *cellNib;

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
    
    _cellNib = [UINib nibWithNibName:kPTMeetingTimeCellIdentifier bundle:nil];
    [self.tableView registerNib:_cellNib forCellReuseIdentifier:kPTMeetingTimeCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:kPTMeetingTimeCreatedNotification object:nil];
}

#pragma mark - Notifcation Handlers

- (void)refreshTable:(NSNotification *)notification {
    [self loadObjects];
}

- (void)showCreationErrorAlertWithError:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"%@", error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Creating Attendees" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - PFQueryTableViewController Delegate

- (PFQuery *)queryForTable {
    if (![PFUser currentUser]) {
        return nil;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"meeting" equalTo:self.meeting];
    [query includeKey:@"meeting"];
    [query includeKey:@"meeting.group"];
    
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
    
    PTMeetingTimeCell *cell = (PTMeetingTimeCell *)[tableView dequeueReusableCellWithIdentifier:kPTMeetingTimeCellIdentifier];
    if (!cell) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:kPTMeetingTimeCellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    [cell setupWithMeetingTime:meetingTime];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 128.0;
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
    PTMeetingTimeCell *cell = (PTMeetingTimeCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.availabilityReady) {
        PTMeetingTime *meetingTime = (PTMeetingTime *) [self objectAtIndexPath:indexPath];
        [self prepareForEventCreationWithMeetingTime:meetingTime];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    PTMeetingTimeCell *cell = (PTMeetingTimeCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.availabilityReady) {
        [self performSegueWithIdentifier:@"MeetingAvailabilitiesSegue" sender:self];
    }
}

#pragma mark - Event Creation 

- (void)prepareForEventCreationWithMeetingTime:(PTMeetingTime *)meetingTime {
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
                NSDictionary *dictionary = @{@"eventStore": eventStore, @"meetingTime": meetingTime};
                [self performSelectorOnMainThread:@selector(displayEventCreationViewController:) withObject:dictionary waitUntilDone:YES];
            }
        }];
    }
}

- (void)displayEventCreationViewController:(NSDictionary *)dictionary {
    EKEventEditViewController *editViewController = [[EKEventEditViewController alloc] init];
    editViewController.editViewDelegate = self;
    
    EKEventStore *eventStore = [dictionary objectForKey:@"eventStore"];
    editViewController.eventStore = eventStore;

    PTMeetingTime *meetingTime = [dictionary objectForKey:@"meetingTime"];
    EKEvent *event = [meetingTime eventWithEventStore:eventStore];
    editViewController.event = event;
    
    [self presentViewController:editViewController animated:YES completion:NULL];
}

#pragma mark - EKEventEditViewDelegate methods

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    if (action == EKEventEditViewActionCanceled) {
        [controller dismissViewControllerAnimated:YES completion:NULL];
    } else if (action == EKEventEditViewActionSaved) {
        NSError *error;
        [controller.eventStore saveEvent:controller.event span:EKSpanThisEvent commit:YES error:&error];
        
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Saving Event" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            PTMeetingTime *meetingTime = (PTMeetingTime *) [self objectAtIndexPath:indexPath];
            [PTPushModel sendPushToAttendeesForMeetingTime:meetingTime];
            [controller dismissViewControllerAnimated:YES completion:NULL];
        }
    }
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
