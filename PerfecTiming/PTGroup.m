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

+ (PTGroup *)groupWithName:(NSString *)name {
    PFQuery *query = [PFQuery queryWithClassName:[self parseClassName]];
    [query whereKey:@"name" equalTo:name];
    
    NSError *error;
    PTGroup *group = (PTGroup *) [query getFirstObject:&error];
    
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    
    return group;
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

@end
