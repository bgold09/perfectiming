//
//  NSDate+Compare.h
//  PerfecTiming
//
//  Created by MTSS User on 11/25/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Compare)

- (BOOL)isLessThanDate:(NSDate *)date;
- (BOOL)isLessThanOrEqualToDate:(NSDate *)date;
- (BOOL)isGreaterThanDate:(NSDate *)date;
- (BOOL)isGreaterThanOrEqualToDate:(NSDate *)date;

@end
