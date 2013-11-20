//
//  PTMeetingAttendeeAvailabilitiesViewController.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/19/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTMeetingAttendeeAvailabilitiesViewController.h"
#import "PTMeetingAttendee.h"

static NSString * const CellIdentifierUnavailable = @"UnavailableCell";
static NSString * const CellIdentifierPartiallyAvailable = @"PartiallyAvailableCell";
static NSString * const CellIdentifierAvailable = @"AvailableCell";

@interface PTMeetingAttendeeAvailabilitiesViewController ()

@end

@implementation PTMeetingAttendeeAvailabilitiesViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = [PTMeetingAttendee parseClassName];
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 25;
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
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
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"meeting" equalTo:self.meeting];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
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
    
//    [query orderByAscending:@"group"];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    PTMeetingAttendee *attendee = (PTMeetingAttendee *) object;
    PTMeetingAttendeeAvailability availabilityLevel = [attendee availabilityForMeeting:self.meeting];
    
    NSString *CellIdentifier;
    switch (availabilityLevel) {
        case PTMeetingAttendeeAvailabilityFull:
            CellIdentifier = CellIdentifierAvailable;
            break;
        case PTMeetingAttendeeAvailabilityPartial:
            CellIdentifier = CellIdentifierPartiallyAvailable;
            break;
        case PTMeetingAttendeeAvailabilityNot:
            CellIdentifier = CellIdentifierUnavailable;
            break;
        default:
            CellIdentifier = CellIdentifierUnavailable;
            break;
    }
    
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = attendee.user.username;
    
    return cell;
}

- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
    return [self.objects objectAtIndex:indexPath.row];
}

@end
