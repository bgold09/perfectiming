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
    NSArray *results = [query findObjects:&error];
    
    if (error) {
        NSLog(@"%@", error);
        return nil;
    } else if (results.count == 0) {
        return nil;
    }
    
    return results[0];
}

- (id)initWithName:(NSString *)name manager:(PFUser *)manager pin:(NSInteger)pin {
    self = [PTGroup object];
    
    if (self) {
        self.name = name;
        self.manager = manager;
        self.pin = pin;
    }
    
    return self;
}

@end
