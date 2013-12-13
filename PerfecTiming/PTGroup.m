//
//  PTGroup.m
//  PerfecTiming
//
//  Created by BRIAN J GOLDEN on 11/12/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "PTGroup.h"
#import <Parse/PFObject+Subclass.h>

@implementation PTGroup

@dynamic name;
@dynamic manager;
@dynamic pin;

+ (NSString *)parseClassName {
    return @"Group";
}

+ (BOOL)groupExistsWithName:(NSString *)name {
    PFQuery *query = [PFQuery queryWithClassName:[self parseClassName]];
    [query whereKey:@"name" equalTo:name];
    
    NSError *error;
    NSInteger count = [query countObjects:&error];
    
    if (error) {
        NSLog(@"%@", error);
        return NO;
    }
    
    if (count > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (id)initWithName:(NSString *)name manager:(PFUser *)manager pin:(NSInteger)pin {
    self = [PTGroup object];
    
    if (self) {
        self.name = name;
        self.manager = manager;
        self.pin = pin;
        
        PFACL *ACL = [PFACL ACL];
        ACL.publicReadAccess = YES;
        ACL.publicWriteAccess = YES;
        self.ACL = ACL;
    }
    
    return self;
}

- (NSComparisonResult)compareToGroup:(PTGroup *)group {
    return [self.name compare:group.name];
}

- (NSString *)channelName {
    return [self.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
}

@end
