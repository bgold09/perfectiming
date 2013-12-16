//
//  UIViewController+FrontRevealSetup.m
//  PerfecTiming
//
//  Created by Brian Golden on 12/16/13.
//  Copyright (c) 2013 BRIAN J GOLDEN. All rights reserved.
//

#import "UIViewController+FrontRevealSetup.h"
#import "PTRevealViewController.h"
#import "Constants.h"

@implementation UIViewController (FrontRevealSetup)

- (void)setUpForFrontReveal {
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setTintColor: [Constants tintColor]];
    
    [self placeMenuButton];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)placeMenuButton {
    UIImage *menuImage = [UIImage imageNamed:@"menu.png"];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:menuImage style:UIBarButtonItemStyleBordered target:self.revealViewController action:@selector(revealToggle:)];
    [self.navigationItem setLeftBarButtonItems:@[menuButton] animated:YES];
}

@end
