/*
 * Copyright (c) 2012-2013 Adam Debono. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "MainViewController.h"

#import "ViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize leftSecondaryLayoutType;
@synthesize rightSecondaryLayoutType;

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self updatePressed:nil];
}

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
	
	[slidingViewController setLeftMainAnchorType:[[self leftAnchorLayoutType] selectedSegmentIndex]];
	[slidingViewController setRightMainAnchorType:[[self rightAnchorLayoutType] selectedSegmentIndex]];
	
	[slidingViewController setLeftUnderAnchorType:[[self leftSecondaryLayoutType] selectedSegmentIndex]];
	[slidingViewController setRightUnderAnchorType:[[self rightSecondaryLayoutType] selectedSegmentIndex]];
	
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
