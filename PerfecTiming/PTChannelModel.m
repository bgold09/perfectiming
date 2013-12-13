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
    [user saveInBackground];
    
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation addUniqueObject:channelName forKey:kChannelKey];
    [installation saveInBackground];
}

+ (void)addChannels:(NSArray *)channelNames user:(PFUser *)user {
    [user addUniqueObjectsFromArray:channelNames forKey:kChannelKey];
    [user saveEventually];
    
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation addUniqueObjectsFromArray:channelNames forKey:kChannelKey];
    [installation saveEventually];
}

+ (void)removeChannelWithName:(NSString *)channelName user:(PFUser *)user {
    [user removeObject:channelName forKey:kChannelKey];
    [user saveInBackground];
    
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation removeObject:channelName forKey:kChannelKey];
    [installation saveInBackground];
}

@end
