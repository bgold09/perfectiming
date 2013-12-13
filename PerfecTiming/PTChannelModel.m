//
//  PTChannelModel.m
//  PerfecTiming
//
//  Created by Brian Golden on 12/12/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTChannelModel.h"

static NSString * const kChannelKey = @"channels";

@implementation PTChannelModel

+ (void)addChannelWithName:(NSString *)channelName user:(PFUser *)user {
    // add channel to user's list of channels
    [user addUniqueObject:channelName forKey:kChannelKey];
    [user saveEventually];
    
    // add channel to all installations for this user
    PFQuery *installationQuery = [PFInstallation query];
    [installationQuery whereKey:@"user" equalTo:user];
    [installationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        for (PFInstallation *installation in objects) {
            [installation addUniqueObject:channelName forKey:kChannelKey];
            [installation saveEventually];
        }
    }];
}

+ (void)addChannels:(NSArray *)channelNames user:(PFUser *)user {
    [user addUniqueObjectsFromArray:channelNames forKey:kChannelKey];
    [user saveEventually];
    
    PFQuery *installationQuery = [PFInstallation query];
    [installationQuery whereKey:@"user" equalTo:user];
    [installationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        for (PFInstallation *installation in objects) {
            [installation addUniqueObjectsFromArray:channelNames forKey:kChannelKey];
            [installation saveEventually];
        }
    }];
}

+ (void)removeChannelWithName:(NSString *)channelName user:(PFUser *)user {
    [user removeObject:channelName forKey:kChannelKey];
    [user saveEventually];
    
    PFQuery *installationQuery = [PFInstallation query];
    [installationQuery whereKey:@"user" equalTo:user];
    [installationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        for (PFInstallation *installation in objects) {
            [installation removeObject:channelName forKey:kChannelKey];
            [installation saveEventually];
        }
    }];
}

+ (void)updateInstallationChannelsWithUser:(PFUser *)user {
    __block NSArray *channels = [user objectForKey:kChannelKey];
    
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" equalTo:user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        for (PFInstallation *installation in objects) {
            [installation addUniqueObjectsFromArray:channels forKey:kChannelKey];
            [installation saveEventually];
        }
    }];
}

@end
