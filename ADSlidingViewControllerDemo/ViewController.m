//
//  ViewController.m
//  ADSlidingViewControllerDemo
//
//  Created by Adam Debono on 2/08/12.
//  Copyright (c) 2012 Adam Debono. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	UIViewController *mainvc = [[UIStoryboard storyboardWithName:@"SlidingViews" bundle:nil] instantiateViewControllerWithIdentifier:@"mainViewController"];
	[[mainvc view] addGestureRecognizer:[self panGesture]];
	[[mainvc view] addGestureRecognizer:[self resetTapGesture]];
	
	[self setMainViewController:mainvc];
	[self setLeftViewController:[[UIStoryboard storyboardWithName:@"SlidingViews" bundle:nil] instantiateViewControllerWithIdentifier:@"leftViewController"]];
	[self setRightViewController:[[UIStoryboard storyboardWithName:@"SlidingViews" bundle:nil] instantiateViewControllerWithIdentifier:@"rightViewController"]];
	
	[self setShowTopViewShadow:YES];
	[self setMainViewShouldAllowInteractionsWhenAnchored:NO];
	[self setRightViewAnchorLayoutType:ADAnchorLayoutTypeResize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
