//
//  MainViewController.m
//  ADSlidingViewController
//
//  Created by Adam Debono on 2/08/12.
//  Copyright (c) 2012 Adam Debono. All rights reserved.
//

#import "MainViewController.h"

#import "ViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (IBAction)leftBarButton:(UIBarButtonItem *)sender {
	[[self slidingViewController] anchorTopViewTo:ADAnchorSideRight];
}

- (IBAction)rightBarButton:(UIBarButtonItem *)sender {
	[[self slidingViewController] anchorTopViewTo:ADAnchorSideLeft];
}

@end
