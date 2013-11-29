//
//  PFUser+Compare.h
//  PerfecTiming
//
//  Created by Brian Golden on 11/29/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFUser (Compare)

- (NSComparisonResult)compareToUser:(PFUser *)user;

@end
