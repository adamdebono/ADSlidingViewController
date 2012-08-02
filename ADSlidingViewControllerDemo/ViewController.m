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
	
	UIViewController *vc = [[UIStoryboard storyboardWithName:@"SlidingViews" bundle:nil] instantiateViewControllerWithIdentifier:@"mainViewController"];
	[[vc view] addGestureRecognizer:[self panGesture]];
	
	[self setMainViewController:vc];
	[self setLeftViewController:[[UIStoryboard storyboardWithName:@"SlidingViews" bundle:nil] instantiateViewControllerWithIdentifier:@"leftViewController"]];
	[self setRightViewController:[[UIStoryboard storyboardWithName:@"SlidingViews" bundle:nil] instantiateViewControllerWithIdentifier:@"rightViewController"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
