//
//  PTMeeting.h
//  PerfecTiming
//
//  Created by MTSS User on 11/18/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Parse/Parse.h>
#import "PTGroup.h"

@interface PTMeeting : PFObject <PFSubclassing>

@property (retain) NSString *name;
@property (retain) NSString *location;
@property (retain) PTGroup *group;

+ (NSString *)parseClassName;
+ (PTMeeting *)meetingWithName:(NSString *)name group:(PTGroup *)group location:(NSString *)location;

@end
