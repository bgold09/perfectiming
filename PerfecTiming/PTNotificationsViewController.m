//
//  PTNotificationsViewController.m
//  PerfecTiming
//
//  Created by Brian Golden on 12/14/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTNotificationsViewController.h"
#import "PTRevealViewController.h"
#import "PTNotification.h"
#import "MBProgressHUD.h"
#import "Constants.h"

@interface PTNotificationsViewController ()

@end

@implementation PTNotificationsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = [PTNotification parseClassName];
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 25;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor: [Constants tintColor]];
    [self placeMenuButton];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)placeMenuButton {
    UIImage *menuImage = [UIImage imageNamed:@"menu.png"];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStyleBordered target:self.revealViewController action:@selector(revealToggle:)];
    [self.navigationItem setLeftBarButtonItem:menuButton animated:YES];
}

#pragma mark - PFQueryTableViewController Delegate

- (PFQuery *)queryForTable {
    if (![PFUser currentUser]) {
        return nil;
    }
    
    PFQuery *query = [PTNotification query];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
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
    PTNotification *notification = (PTNotification *) [self objectAtIndexPath:indexPath];
    
    NSString *CellIdentifier = @"Cell";
    
    switch (notification.pushType) {
        case PTPushTypeGroupUserJoined:
            break;
        case PTPushTypeGroupUserLeft:
            break;
        case PTPushTypeGroupUserSentAvailability:
            break;
        case PTPushTypeMeetingTimeChosen:
            CellIdentifier = @"MeetingTimeChosenCell";
            break;
        default:
            break;
    }
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = notification.message;
    
    return cell;
}

- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
    return [self.objects objectAtIndex:indexPath.row];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PTNotification *notification = (PTNotification *) [self objectAtIndexPath:indexPath];
    [notification markRead];

    PFInstallation *installation = [PFInstallation currentInstallation];
    if (installation.badge != 0) {
        installation.badge--;
        [installation saveEventually];
    }
    
    if (notification.pushType == PTPushTypeMeetingTimeChosen) {
        [self showProgressHUD];
        PTMeetingTime *meetingTime = (PTMeetingTime *) notification.notificationObject;
        [self prepareForEventCreationWithMeetingTime:meetingTime];
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
                [self performSelectorInBackground:@selector(displayEventCreationViewController:) withObject:dictionary];
            }
        }];
    }
}

// uses synchronous methods, dispatch on background thread
- (void)displayEventCreationViewController:(NSDictionary *)dictionary {
    EKEventEditViewController *editViewController = [[EKEventEditViewController alloc] init];
    editViewController.editViewDelegate = self;
    
    EKEventStore *eventStore = [dictionary objectForKey:@"eventStore"];
    editViewController.eventStore = eventStore;
    
    NSString *meetingTimeId = [dictionary objectForKey:@"meetingTime"];
    PTMeetingTime *meetingTime = (PTMeetingTime *) [PFObject objectWithoutDataWithClassName:[PTMeetingTime parseClassName] objectId:meetingTimeId];
    
    NSError *error;
    [meetingTime fetch:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
    [meetingTime.meeting fetchIfNeeded:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
    [meetingTime.meeting.group fetch:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
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
            [controller dismissViewControllerAnimated:YES completion:NULL];
        }
    }
    
    [self hideProgressHUD];
}

#pragma mark - Progress HUD

- (void)showProgressHUD {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading Event";
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)hideProgressHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

@end
