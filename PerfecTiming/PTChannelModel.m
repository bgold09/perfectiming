//
//  PTChannelModel.m
//  PerfecTiming
//
//  Created by Brian Golden on 12/12/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTChannelModel.h"
#import "Constants.h"

//static NSString * const kPTUserChannelsKey = @"channels";

@implementation PTChannelModel

+ (void)addChannelWithName:(NSString *)channelName user:(PFUser *)user {
    // add channel to user's list of channels
    [user addUniqueObject:channelName forKey:kPTUserChannelsKey];
    [user saveInBackground];
    
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation addUniqueObject:channelName forKey:kPTUserChannelsKey];
    [installation saveInBackground];
}

+ (void)addChannels:(NSArray *)channelNames user:(PFUser *)user {
    [user addUniqueObjectsFromArray:channelNames forKey:kPTUserChannelsKey];
    [user saveEventually];
    
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation addUniqueObjectsFromArray:channelNames forKey:kPTUserChannelsKey];
    [installation saveEventually];
}

+ (void)removeChannelWithName:(NSString *)channelName user:(PFUser *)user {
    [user removeObject:channelName forKey:kPTUserChannelsKey];
    [user saveInBackground];
    
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation removeObject:channelName forKey:kPTUserChannelsKey];
    [installation saveInBackground];
}

@end
