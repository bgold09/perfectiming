//
//  NSString+Email.m
//  PerfecTiming
//
//  Created by Brian Golden on 11/26/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "NSString+Email.h"

@implementation NSString (Email)

- (BOOL)isValidEmail {
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

@end
