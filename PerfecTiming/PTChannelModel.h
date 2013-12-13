//
//  PTChannelModel.h
//  PerfecTiming
//
//  Created by Brian Golden on 12/12/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface PTChannelModel : NSObject

+ (void)addChannelWithName:(NSString *)channelName user:(PFUser *)user;
+ (void)addChannels:(NSArray *)channelNames user:(PFUser *)user;
+ (void)removeChannelWithName:(NSString *)channelName user:(PFUser *)user;
+ (void)updateInstallationChannelsWithUser:(PFUser *)user;

@end
