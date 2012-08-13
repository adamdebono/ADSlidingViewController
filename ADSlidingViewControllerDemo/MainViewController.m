//
//  MainViewController.m
//  ADSlidingViewControllerDemo
//
//  Created by Adam Debono on 2/08/12.
//  Copyright (c) 2012 Adam Debono. All rights reserved.
//

#import "MainViewController.h"

#import "ViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize leftSecondaryLayoutType;
@synthesize rightSecondaryLayoutType;

- (IBAction)leftBarButton:(UIBarButtonItem *)sender {
	[[self slidingViewController] anchorTopViewTo:ADAnchorSideRight];
}

- (IBAction)rightBarButton:(UIBarButtonItem *)sender {
	[[self slidingViewController] anchorTopViewTo:ADAnchorSideLeft];
}

- (IBAction)updatePressed:(UIButton *)sender {
	ADSlidingViewController *slidingViewController = [self slidingViewController];
	
	[slidingViewController setLeftViewAnchorWidth:[[self leftAnchorAmountStepper] value]];
	[slidingViewController setRightViewAnchorWidth:[[self rightAnchorAmountStepper] value]];
	
	[slidingViewController setLeftViewAnchorWidthType:[[self leftAnchorWidthType] selectedSegmentIndex]];
	[slidingViewController setRightViewAnchorWidthType:[[self rightAnchorWidthType] selectedSegmentIndex]];
	
	[slidingViewController setLeftViewAnchorLayoutType:[[self leftAnchorLayoutType] selectedSegmentIndex]];
	[slidingViewController setRightViewAnchorLayoutType:[[self rightAnchorLayoutType] selectedSegmentIndex]];
	
	[slidingViewController setLeftViewSecondaryLayoutType:[[self leftSecondaryLayoutType] selectedSegmentIndex]];
	[slidingViewController setRightViewSecondaryLayoutType:[[self rightSecondaryLayoutType] selectedSegmentIndex]];
	
	[slidingViewController setUndersidePersistencyType:[[self undersidePersistencyControl] selectedSegmentIndex]];
}

- (IBAction)leftAnchorValueChanged:(UIStepper *)sender {
	[[self leftAnchorAmountLabel] setText:[NSString stringWithFormat:@"%@", @( [sender value] )]];
}

- (IBAction)rightAnchorValueChanged:(UIStepper *)sender {
	[[self rightAnchorAmountLabel] setText:[NSString stringWithFormat:@"%@", @( [sender value] )]];
}

- (void)viewDidUnload {
	[self setLeftSecondaryLayoutType:nil];
	[self setRightSecondaryLayoutType:nil];
	[super viewDidUnload];
}
@end
