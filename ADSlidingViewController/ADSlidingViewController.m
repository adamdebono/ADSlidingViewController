//
//  ADSlidingViewController.m
//  ADSlidingViewController
//
//  Created by Adam Debono on 2/08/12.
//  Copyright (c) 2012 Adam Debono. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ADSlidingViewController.h"

#pragma mark - UIViewController Extension
@implementation UIViewController (ADSlidingViewController)
- (ADSlidingViewController *)slidingViewController {
	UIViewController *viewController = [self parentViewController];
	while (viewController != nil) {
		if ([viewController isKindOfClass:[ADSlidingViewController class]]) {
			return (ADSlidingViewController *)viewController;
		}
		viewController = [viewController parentViewController];
	}
	
	return nil;
}
@end

#pragma mark - Private Interface
@interface ADSlidingViewController () {
	CGFloat initialViewCenterX;
	CGFloat currentMainViewCenterX;
}

@end

/* Default Values */
static const CGFloat kADDefaultAnchorAmount = 300.0f;

static const BOOL kADDefaultMainViewAllowsInteraction = NO;

static const ADAnchorWidthType kADDefaultAnchorWidthType = ADAnchorWidthTypePeek;
static const ADMainAnchorType kADDefaultMainAnchorType = ADMainAnchorTypeSlide;
static const ADUndersidePersistencyType kADDefaultUndersidePersistencyType = ADUndersidePersistencyTypeNone;
static const ADUnderAnchorType kADDefaultUnderAnchorType = ADUnderAnchorTypeUnderneath;

/* Constants */
static const CGFloat kADViewAnimationTime = 0.3f;
static const UIViewAutoresizing kFullScreenAutoResizing = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
static const UIViewAutoresizing kLeftSideAutoResizing = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
static const UIViewAutoresizing kRightSideAutoResizing = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;

#pragma mark - Main Implementation
@implementation ADSlidingViewController

#pragma mark - View Lifecycle

- (id)init {
	if (self = [super init]) {
		[self load];
	}
	
	return self;
}

- (void)awakeFromNib {
	[self load];
}

- (void)load {
	NSLog();
	
	/* Setup Default Values */
	_leftViewAnchorWidth = kADDefaultAnchorAmount;
	_rightViewAnchorWidth = kADDefaultAnchorAmount;
	
	_leftViewAnchorWidthType = kADDefaultAnchorWidthType;
	_rightViewAnchorWidthType = kADDefaultAnchorWidthType;
	
	_leftMainAnchorType = kADDefaultMainAnchorType;
	_rightMainAnchorType = kADDefaultMainAnchorType;
	
	_leftUnderAnchorType = kADDefaultUnderAnchorType;
	_rightUnderAnchorType = kADDefaultUnderAnchorType;
	
	_undersidePersistencyType = kADDefaultUndersidePersistencyType;	
	
	_anchoredToSide = ADAnchorSideCenter;
}

- (void)viewDidLoad {
	NSLog();
	
	[super viewDidLoad];
	
	[[self view] setAutoresizingMask:kFullScreenAutoResizing];
	
	//Gestures
	_resetTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureActivated:)];
	//[_resetTapGesture setCancelsTouchesInView:YES];
	//[_resetTapGesture setDelaysTouchesBegan:YES];
	[_resetTapGesture setDelegate:self];
	
	_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureActivated:)];
	//[_panGesture setCancelsTouchesInView:YES];
	//[_panGesture setDelaysTouchesBegan:YES];
	[_panGesture setDelegate:self];
	
	/* Key-Value Observation */
	[self addObserver:self forKeyPath:@"leftViewAnchorWidth" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"rightViewAnchorWidth" options:NSKeyValueObservingOptionNew context:nil];
	
	[self addObserver:self forKeyPath:@"leftViewAnchorWidthType" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"rightViewAnchorWidthType" options:NSKeyValueObservingOptionNew context:nil];
	
	[self addObserver:self forKeyPath:@"leftMainAnchorType" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"rightMainAnchorType" options:NSKeyValueObservingOptionNew context:nil];
	
	[self addObserver:self forKeyPath:@"leftUnderAnchorType" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"rightUnderAnchorType" options:NSKeyValueObservingOptionNew context:nil];
	
	[self addObserver:self forKeyPath:@"undersidePersistencyType" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog();
	
	[super viewWillAppear:animated];
	
	[self updateLayout];
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog();
	
	[super viewDidAppear:animated];
	
	[self updateLayout];
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"leftViewAnchorWidth"];
	[self removeObserver:self forKeyPath:@"rightViewAnchorWidth"];
	
	[self removeObserver:self forKeyPath:@"leftViewAnchorWidthType"];
	[self removeObserver:self forKeyPath:@"rightViewAnchorWidthType"];
	
	[self removeObserver:self forKeyPath:@"leftMainAnchorType"];
	[self removeObserver:self forKeyPath:@"rightMainAnchorType"];
	
	[self removeObserver:self forKeyPath:@"leftUnderAnchorType"];
	[self removeObserver:self forKeyPath:@"rightUnderAnchorType"];
	
	[self removeObserver:self forKeyPath:@"undersidePersistencyType"];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	NSLog();
	
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		if ([self undersidePersistencyType] >= ADUndersidePersistencyTypeLandscape) {
			if ([self anchoredToSide] == ADAnchorSideCenter) {
				[self anchorTopViewTo:[self whatSideForUndersidePersistencyOnSide:ADAnchorSideCenter] animated:NO];
			} else {
				[self updateLayout];
			}
		} else {
			[self updateLayout];
		}
	} else {
		if ([self undersidePersistencyType] == ADUndersidePersistencyTypeAlways) {
			if ([self anchoredToSide] == ADAnchorSideCenter) {
				[self anchorTopViewTo:[self whatSideForUndersidePersistencyOnSide:ADAnchorSideCenter] animated:NO];
			} else {
				[self updateLayout];
			}
		} else if ([self undersidePersistencyType] == ADUndersidePersistencyTypeLandscape && [self anchoredToSide] != ADAnchorSideCenter) {
			[self anchorTopViewTo:ADAnchorSideCenter animated:NO];
		} else {
			[self updateLayout];
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

#ifdef __IPHONE_6_0
- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}
#endif

#pragma mark - View Controller Setters

- (void)setMainViewController:(UIViewController *)mainViewController {
	NSLog();
	
	if ([self mainViewController]) {
		[[[self mainViewController] view] removeFromSuperview];
		[[self mainViewController] willMoveToParentViewController:nil];
		[[self mainViewController] removeFromParentViewController];
	}
	
	_mainViewController = mainViewController;
	
	if ([self mainViewController]) {
		[self addChildViewController:[self mainViewController]];
		[[self mainViewController] didMoveToParentViewController:self];
		
		[[[self mainViewController] view] setAutoresizingMask:kFullScreenAutoResizing];
		
		[self updateMainViewLayout];
		
		[[self view] addSubview:[[self mainViewController] view]];
	}
}

- (void)setLeftViewController:(UIViewController *)leftViewController {
	NSLog();
	
	if ([self leftViewController]) {
		[[[self leftViewController] view] removeFromSuperview];
		[[self leftViewController] willMoveToParentViewController:nil];
		[[self leftViewController] removeFromParentViewController];
	}
	
	_leftViewController = leftViewController;
	
	if ([self leftViewController]) {
		[self addChildViewController:[self leftViewController]];
		[[self leftViewController] didMoveToParentViewController:self];
		
		[self updateLeftViewLayout];
		
		[[self view] insertSubview:[[self leftViewController] view] atIndex:0];
	}
}

- (void)setRightViewController:(UIViewController *)rightViewController {
	NSLog();
	
	if ([self rightViewController]) {
		[[[self rightViewController] view] removeFromSuperview];
		[[self rightViewController] willMoveToParentViewController:nil];
		[[self rightViewController] removeFromParentViewController];
	}
	
	_rightViewController = rightViewController;
	
	if ([self rightViewController]) {
		[self addChildViewController:[self rightViewController]];
		[[self rightViewController] didMoveToParentViewController:self];
		
		[self updateRightViewLayout];
		
		[[self view] insertSubview:[[self rightViewController] view] atIndex:0];
	}
}

#pragma mark - Layout Setters

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSLog(@"%@", keyPath);
	
	[self updateLayout];
}

- (void)setUndersidePersistencyType:(ADUndersidePersistencyType)undersidePersistencyType {
	_undersidePersistencyType = undersidePersistencyType;
	
	if ([self anchoredToSide] == ADAnchorSideCenter && [self checkUndersidePersistency]) {
		if ([self leftViewController]) {
			[self anchorTopViewTo:ADAnchorSideRight animated:YES];
		} else {
			[self anchorTopViewTo:ADAnchorSideLeft animated:YES];
		}
	}
}

- (void)setShowTopViewShadow:(BOOL)showTopViewShadow {
	NSLog(@"%d", showTopViewShadow);
	_showTopViewShadow = showTopViewShadow;
	[self updateMainViewShadow];
}

#pragma mark - View Information

- (BOOL)leftViewShowing {
	CGFloat mainMid = CGRectGetMidX([[[self mainViewController] view] frame]);
	CGFloat selfMid = CGRectGetMidX([[self view] bounds]);
	BOOL leftViewShowing = mainMid > selfMid;
	NSLog(@"%d", leftViewShowing);
	return leftViewShowing;
}

- (BOOL)rightViewShowing {
	CGFloat mainMid = CGRectGetMidX([[[self mainViewController] view] frame]);
	CGFloat selfMid = CGRectGetMidX([[self view] bounds]);
	BOOL rightViewShowing = mainMid < selfMid;
	NSLog(@"%d", rightViewShowing);
	return rightViewShowing;
}

#pragma mark - Gestures

- (void)tapGestureActivated:(UITapGestureRecognizer *)sender {
	NSLog();
	[self anchorTopViewTo:ADAnchorSideCenter];
}

- (void)panGestureActivated:(UIPanGestureRecognizer *)sender {
	if ([sender state] == UIGestureRecognizerStateBegan) {
		NSLog(@"Began Pan Gesture");
		initialViewCenterX = currentMainViewCenterX;
	} else if ([sender state] == UIGestureRecognizerStateChanged) {
		//Calculate movement
		CGFloat panAmount = [sender translationInView:[sender view]].x;
		CGFloat newCenter = initialViewCenterX + panAmount;
		CGFloat viewCenter = CGRectGetMidX([[self view] bounds]);
		
		BOOL calculate = YES;;
		
		//Check the view we are panning to exists
		if (![self leftViewController] && newCenter > viewCenter) {
			newCenter = viewCenter;
			calculate = NO;
		} else if (![self rightViewController]) {
			if ([self checkUndersidePersistency]) {
				CGFloat max = [self calculateMainViewHorizontalCenterWhenAnchoredToSide:ADAnchorSideRight];
				if (newCenter < max) {
					newCenter = max;
					calculate = NO;
				}
			} else {
				if (newCenter < viewCenter) {
					newCenter = viewCenter;
					calculate = NO;
				}
			}
		}
		
		if (calculate) {
			//Calculate Elastic
			CGFloat maxCenter;
			int multiple = 1;
			if (newCenter > viewCenter) {
				maxCenter = [self calculateMainViewHorizontalCenterWhenAnchoredToSide:ADAnchorSideRight];
			} else {
				maxCenter = [self calculateMainViewHorizontalCenterWhenAnchoredToSide:ADAnchorSideLeft];
				multiple = -1;
			}
			CGFloat delta = abs(viewCenter - newCenter);
			CGFloat maxDelta = abs(viewCenter - maxCenter);
			CGFloat extra = delta - maxDelta;
			if (extra > 0) {
				extra = tanh(extra / 100) * 100;
				//extra /= 2;
				newCenter = viewCenter + (maxDelta + extra) * multiple;
			} else {
				//newCenter = newCenter
			}
		}
		
		[self moveMainViewToHorizontalCenter:newCenter];
	} else if ([sender state] == UIGestureRecognizerStateEnded || [sender state] == UIGestureRecognizerStateCancelled) {
		CGFloat velocity = [sender velocityInView:[self view]].x;
		
		ADAnchorSide side;
		
		NSTimeInterval duration;
		if (velocity > 100) {//moving -> this way
			if ([self anchoredToSide] == ADAnchorSideLeft) {
				side = ADAnchorSideCenter;
			} else if ([self leftViewController]) {
				side = ADAnchorSideRight;
			} else {
				side = ADAnchorSideCenter;
			}
		} else if (velocity < -100) {//moving <- that way
			if ([self anchoredToSide] == ADAnchorSideRight) {
				side = ADAnchorSideCenter;
			} else if ([self rightViewController]) {
				side = ADAnchorSideLeft;
			} else {
				side = ADAnchorSideCenter;
			}
		} else {//not moving fast enough, move to the closest side
			CGFloat width = [self calculateMainViewHorizontalCenterWhenAnchoredToSide:ADAnchorSideRight] - [self calculateMainViewHorizontalCenterWhenAnchoredToSide:ADAnchorSideLeft];
			CGFloat center = currentMainViewCenterX - ([[self view] bounds].size.width - width) / 2;
			double percentage = center / width;
			if ([self checkUndersidePersistency]) {
				if (percentage < 1) {
					side = ADAnchorSideLeft;
				} else {
					side = ADAnchorSideRight;
				}
			} else {
				if (percentage < 0.25) {
					side = ADAnchorSideLeft;
				} else if (percentage > 0.75) {
					side = ADAnchorSideRight;
				} else {
					side = ADAnchorSideCenter;
				}
			}
		}
		side = [self whatSideForUndersidePersistencyOnSide:side];
		if ([self anchoredToSide] == side) {
			duration = kADViewAnimationTime;
		} else {
			CGFloat newCenter = [self calculateMainViewHorizontalCenterWhenAnchoredToSide:side];
			double distance = fabs(newCenter - currentMainViewCenterX);
			duration = distance / fabs(velocity);
			if (duration > 0.4) {
				duration = 0.4;
			}
		}
		
		NSLog(@"Finished Pan Gesture: velocity = %f, duration %f", velocity, duration);
		[self anchorTopViewTo:side animated:YES duration:duration completion:NULL];
	}
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer == [self resetTapGesture]) {
		if ([self anchoredToSide] == ADAnchorSideCenter || [self checkUndersidePersistency]) {
			return NO;
		}
	} else if (gestureRecognizer == [self panGesture]) {
		
	}
	
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if (gestureRecognizer == [self resetTapGesture]) {
		
	} else if (gestureRecognizer == [self panGesture]) {
		if ([[touch view] isKindOfClass:[UISlider class]]) {
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	if (gestureRecognizer == [self resetTapGesture]) {
		if (otherGestureRecognizer == [self panGesture]) {
			return NO;
		}
	} else if (gestureRecognizer == [self panGesture]) {
		return NO;
	}
	
	return YES;
}

#pragma mark - Laying out
- (void)updateLayout {
	NSLog();
	[self updateLeftViewLayout];
	[self updateRightViewLayout];
	[self updateMainViewLayout];
}

- (void)updateMainViewLayout {
	NSLog();
	
	//Calculations
	CGFloat newCenter = [self calculateMainViewHorizontalCenterWhenAnchoredToSide:[self anchoredToSide]];
	
	//Do the stuff
	[self moveMainViewToHorizontalCenter:newCenter];
}

- (void)updateLeftViewLayout {
	NSLog();
	
	//Calculations
	CGRect leftViewFrame;
	UIViewAutoresizing leftViewAutoResizing;
	
	leftViewFrame = [[self view] bounds];
	switch ([self leftViewAnchorWidthType]) {
		case ADAnchorWidthTypePeek:
			leftViewFrame.size.width = [[self view] bounds].size.width - [self leftViewAnchorWidth];
			leftViewAutoResizing = kFullScreenAutoResizing;
			break;
		case ADAnchorWidthTypeReveal:
			leftViewFrame.size.width = [self leftViewAnchorWidth];
			leftViewAutoResizing = kLeftSideAutoResizing;
			break;
	}
	
	//Do the stuff
	[[[self leftViewController] view] setFrame:leftViewFrame];
	[[[self leftViewController] view] setAutoresizingMask:leftViewAutoResizing];
}

- (void)updateRightViewLayout {
	NSLog();
	
	//Calculations
	CGRect rightViewFrame;
	UIViewAutoresizing rightViewAutoResizing;
	
	rightViewFrame = [[self view] bounds];
	switch ([self rightViewAnchorWidthType]) {
		case ADAnchorWidthTypePeek:
			rightViewFrame.origin.x = [self rightViewAnchorWidth];
			rightViewFrame.size.width -= [self rightViewAnchorWidth];
			rightViewAutoResizing = kRightSideAutoResizing;
			break;
		case ADAnchorWidthTypeReveal:
			rightViewFrame.origin.x = rightViewFrame.size.width - [self rightViewAnchorWidth];
			rightViewFrame.size.width = [self rightViewAnchorWidth];
			rightViewAutoResizing = kRightSideAutoResizing;
			break;
	}
	
	//Do the stuff
	[[[self rightViewController] view] setFrame:rightViewFrame];
	[[[self rightViewController] view] setAutoresizingMask:rightViewAutoResizing];
}

- (CGFloat)calculateMainViewHorizontalCenterWhenAnchoredToSide:(ADAnchorSide)side {
	//Calculations
	CGFloat horizontalCenter = CGRectGetMidX([[self view] bounds]);
	CGFloat viewWidth = [[self view] bounds].size.width;
	CGFloat newCenter = 0;//[[[self mainViewController] view] center].x;
	
	if ([self checkUndersidePersistency]) {
		if (side == ADAnchorSideLeft) {
			newCenter = horizontalCenter;
		} else if (side == ADAnchorSideRight) {
			CGFloat width = 0;
			switch ([self leftViewAnchorWidthType]) {
				case ADAnchorWidthTypePeek:
					width = viewWidth - [self leftViewAnchorWidth];
					break;
				case ADAnchorWidthTypeReveal:
					width = [self leftViewAnchorWidth];
					break;
			}
			newCenter = horizontalCenter + width;
		}
	} else {
		if (side == ADAnchorSideCenter) {
			newCenter = horizontalCenter;
		} else if (side == ADAnchorSideLeft) {//showing the right side
			CGFloat distance = 0;
			switch ([self rightViewAnchorWidthType]) {
				case ADAnchorWidthTypePeek:
					distance = viewWidth - [self rightViewAnchorWidth];
					break;
				case ADAnchorWidthTypeReveal:
					distance = [self rightViewAnchorWidth];
					break;
			}
			newCenter = horizontalCenter - distance;
		} else if (side == ADAnchorSideRight) {//showing the left side
			CGFloat distance = 0;
			switch ([self leftViewAnchorWidthType]) {
				case ADAnchorWidthTypePeek:
					distance = viewWidth - [self leftViewAnchorWidth];
					break;
				case ADAnchorWidthTypeReveal:
					distance = [self leftViewAnchorWidth];
					break;
			}
			newCenter = horizontalCenter + distance;
		}
	}
	
	return newCenter;
}

- (CGRect)calculateMainViewFrameForHorizontalCenter:(CGFloat)horizontalCenter {
	__block CGRect mainViewFrame = [[self view] bounds];
	CGFloat viewCenter = CGRectGetMidX(mainViewFrame);
	
	mainViewFrame.origin.x = horizontalCenter - viewCenter;
	
	void (^rightView)(void) = ^{
		[self rightViewWillAppear];
		
		if ([self checkUndersidePersistency]) {
			mainViewFrame.size.width -= [[[self rightViewController] view] frame].size.width;
		} else if ([self rightMainAnchorType] == ADMainAnchorTypeResize) {
			mainViewFrame.size.width += mainViewFrame.origin.x;
			mainViewFrame.origin.x = 0;
		}
	};
	
	void (^leftView)(void) = ^{
		[self leftViewWillAppear];
		
		if ([self checkUndersidePersistency]) {
			mainViewFrame.size.width -= [[[self leftViewController] view] frame].size.width;
		} else if ([self leftMainAnchorType] == ADMainAnchorTypeResize) {
			mainViewFrame.size.width -= mainViewFrame.origin.x;
		}
	};
	
	if (horizontalCenter < viewCenter) {
		rightView();
	} else if (horizontalCenter > viewCenter) {
		leftView();
	} else {
		if ([self leftViewController]) {
			leftView();
		} else {
			rightView();
		}
	}
	
	return mainViewFrame;
}

- (void)updateMainViewShadow {
	//Shadow
	[[[[self mainViewController] view] layer] setShadowOffset:CGSizeZero];
	[[[[self mainViewController] view] layer] setShadowRadius:10];
	[[[[self mainViewController] view] layer] setShadowColor:[[UIColor blackColor] CGColor]];
	if ([self showTopViewShadow]) {
		[[[[self mainViewController] view] layer] setShadowOpacity:0.75f];
	} else {
		[[[[self mainViewController] view] layer] setShadowOpacity:0.0f];
	}
	
	[self updateMainViewShadowPath];
}

- (void)updateMainViewShadowPath {
	[[[[self mainViewController] view] layer] setShadowPath:[UIBezierPath bezierPathWithRect:[[[self mainViewController] view] bounds]].CGPath];
}

- (BOOL)checkUndersidePersistency {
	if ([self undersidePersistencyType] == ADUndersidePersistencyTypeNone) {
		return NO;
	}
	
	switch ([[UIApplication sharedApplication] statusBarOrientation]) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
			if ([self undersidePersistencyType] == ADUndersidePersistencyTypeAlways) {
				return YES;
			}
			break;
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			if ([self undersidePersistencyType] >= ADUndersidePersistencyTypeLandscape) {
				return YES;
			}
			break;
	}
	
	return NO;
}

- (ADAnchorSide)whatSideForUndersidePersistencyOnSide:(ADAnchorSide)side {
	if (side == ADAnchorSideCenter && [self checkUndersidePersistency]) {
		if ([self anchoredToSide] == ADAnchorSideLeft) {
			return ADAnchorSideRight;
		} else if ([self anchoredToSide] == ADAnchorSideRight) {
			return ADAnchorSideLeft;
		} else {
			if ([self leftViewController]) {
				return ADAnchorSideRight;
			} else {
				return ADAnchorSideLeft;
			}
		}
	}
	return side;
}

#pragma mark - Movement

- (void)moveMainViewToHorizontalCenter:(CGFloat)newCenter {
	NSLog(@"%f", newCenter);
	
	currentMainViewCenterX = newCenter;
	
	/*CGRect mainViewFrame = [[self view] bounds];
	CGFloat viewCenter = CGRectGetMidX(mainViewFrame);
	
	mainViewFrame.origin.x = newCenter - viewCenter;
	if (newCenter < viewCenter) {
		[self rightViewWillAppear];
		
		if ([self rightViewAnchorLayoutType] == ADAnchorLayoutTypeResize) {
			mainViewFrame.size.width += mainViewFrame.origin.x;
			mainViewFrame.origin.x = 0;
		}
	} else if (newCenter > viewCenter) {
		[self leftViewWillAppear];
		
		if ([self leftViewAnchorLayoutType] == ADAnchorLayoutTypeResize) {
			mainViewFrame.size.width -= mainViewFrame.origin.x;
		}
	}*/
	CGRect mainViewFrame = [self calculateMainViewFrameForHorizontalCenter:newCenter];
	CGFloat viewCenter = CGRectGetMidX([[self view] bounds]);
	
	//CGRect mainViewBounds = CGRectZero;
	//mainViewBounds.size = mainViewFrame.size;
	//CGPoint theCenter = CGPointMake(CGRectGetMidX(mainViewFrame), CGRectGetMidY(mainViewFrame));
	
	[[[self mainViewController] view] setFrame:mainViewFrame];
	//[[[self mainViewController] view] setBounds:mainViewBounds];
	//[[[self mainViewController] view] setCenter:theCenter];
	//[[[[self mainViewController] view] layer] setShadowPath:CGPathCreateWithRect(mainViewFrame, NULL)];
	
	//[[[[self mainViewController] view] layer] setFrame:mainViewFrame];
	//[[[[self mainViewController] view] layer] setBounds:mainViewBounds];
	//[[[self mainViewController] view] setBounds:mainViewBounds];
	
	if ([self leftUnderAnchorType] == ADUnderAnchorTypeSlide) {
		CGRect leftFrame = [[[self leftViewController] view] frame];
		leftFrame.origin.x = leftFrame.size.width;
		leftFrame.origin.x *= -1;
		leftFrame.origin.x -= viewCenter - newCenter;
		CGPoint leftCenter = CGPointMake(CGRectGetMidX(leftFrame), CGRectGetMidY(leftFrame));
		[[[self leftViewController] view] setCenter:leftCenter];
	}
	
	if ([self rightUnderAnchorType] == ADUnderAnchorTypeSlide) {
		CGRect rightFrame = [[[self rightViewController] view] frame];
		rightFrame.origin.x = [[self view] bounds].size.width;
		rightFrame.origin.x -= viewCenter - newCenter;
		//CGPoint rightCenter = CGPointMake(CGRectGetMidX(rightFrame), CGRectGetMidY(rightFrame));
		//[[[self rightViewController] view] setCenter:rightCenter];
		[[[self rightViewController] view] setFrame:rightFrame];
	}
	
	[self updateMainViewShadowPath];
}

- (void)leftViewWillAppear {
	NSLog();
	
	if ([self checkUndersidePersistency]) {
		[[self view] sendSubviewToBack:[[self rightViewController] view]];
		[[[self rightViewController] view] setHidden:NO];
	} else {
		[[[self rightViewController] view] setHidden:YES];
	}
	[[[self leftViewController] view] setHidden:NO];
	
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(ADSlidingViewControllerWillShowLeftView:)]) {
		[[self delegate] ADSlidingViewControllerWillShowLeftView:self];
	}
}

- (void)rightViewWillAppear {
	NSLog();
	
	if ([self checkUndersidePersistency]) {
		[[self view] sendSubviewToBack:[[self leftViewController] view]];
		[[[self leftViewController] view] setHidden:NO];
	} else {
		[[[self leftViewController] view] setHidden:YES];
	}
	[[[self rightViewController] view] setHidden:NO];
	
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(ADSlidingViewControllerWillShowRightView:)]) {
		[[self delegate] ADSlidingViewControllerWillShowRightView:self];
	}
}

#pragma mark - Anchoring Functions

- (void)anchorTopViewTo:(ADAnchorSide)side {
	[self anchorTopViewTo:side animated:YES];
}

- (void)anchorTopViewTo:(ADAnchorSide)side animated:(BOOL)animated {
	[self anchorTopViewTo:side animated:animated completion:NULL];
}

- (void)anchorTopViewTo:(ADAnchorSide)side animated:(BOOL)animated completion:(void (^)())completion {
	[self anchorTopViewTo:side animated:animated duration:kADViewAnimationTime completion:completion];
}

- (void)anchorTopViewTo:(ADAnchorSide)side animated:(BOOL)animated duration:(NSTimeInterval)duration completion:(void (^)())completion {
	NSLog();
	ADAnchorSide s = side;
	
	side = [self whatSideForUndersidePersistencyOnSide:side];
	
	if (side == ADAnchorSideRight && ![self leftViewController]) {
		side = [self anchoredToSide];
	} else if (side == ADAnchorSideLeft && ![self rightViewController]) {
		side = [self anchoredToSide];
	}
	
	if (side != s) {
		duration = kADViewAnimationTime;
	}
	
	//Pre-Animation
	if (side == ADAnchorSideLeft) {
		[self rightViewWillAppear];
	} else if (side == ADAnchorSideRight) {
		[self leftViewWillAppear];
	}
	
	_anchoredToSide = side;
	[[self view] setUserInteractionEnabled:NO];
	
	//Animation Block
	void (^animations)() = ^{
		[self updateLayout];
	};
	
	//Completion Block
	void (^acompletion)(BOOL finished) = ^(BOOL finished) {
		[[self view] setUserInteractionEnabled:YES];
		if (completion) {
			completion();
		}
		
		if ([self delegate] && [[self delegate] respondsToSelector:@selector(ADSlidingViewController:didAnchorToSide:)]) {
			[[self delegate] ADSlidingViewController:self didAnchorToSide:side];
		}
	};
	
	//Do the animation
	if (animated) {
		/*CGRect fromRect = [[[self mainViewController] view] frame];
		CGFloat toCenter = [self calculateMainViewHorizontalCenterWhenAnchoredToSide:side];
		CGRect toRect = [self calculateMainViewFrameForHorizontalCenter:toCenter];
		
		CGRect toBounds = CGRectZero;
		toBounds.size = toRect.size;
		CGPoint actualCenter = CGPointMake(CGRectGetMidX(toRect), CGRectGetMidY(toRect));
		
		CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
		[boundsAnimation setFromValue:[NSValue valueWithCGRect:fromRect]];
		[boundsAnimation setToValue:[NSValue valueWithCGRect:toRect]];
		[boundsAnimation setDuration:duration];
		*/
		
		//[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:animations completion:acompletion];
		[UIView transitionWithView:[self view] duration:duration options:UIViewAnimationOptionCurveEaseOut animations:animations completion:acompletion];
		
		/*[UIView beginAnimations:@"" context:nil];
		[UIView setAnimationDuration:duration];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		animations();
		[UIView commitAnimations];
		acompletion(YES);*/
		
		/*
		[[[[self mainViewController] view] layer] addAnimation:boundsAnimation forKey:@"bounds"];
		
		CABasicAnimation *centerAnimation = [CABasicAnimation animationWithKeyPath:@"center"];
		[centerAnimation setFromValue:[NSValue valueWithCGPoint:[[[self mainViewController] view] center]]];
		[centerAnimation setToValue:[NSValue valueWithCGPoint:actualCenter]];
		[centerAnimation setDuration:duration];
		[[[[self mainViewController] view] layer] addAnimation:centerAnimation forKey:@"center"];
		
		[[[self mainViewController] view] setBounds:toBounds];*/
		//[[[self mainViewController] view] setCenter:actualCenter];
		
		//acompletion(YES);
	} else {
		animations();
		acompletion(YES);
	}
	
	/*NSLog(@"duration > 0");
	CABasicAnimation *animation  = [CABasicAnimation animationWithKeyPath:@"bounds"];
	[animation setFromValue:[NSValue valueWithCGRect:[[[self mainViewController] view] frame]]];
	[animation setToValue:[NSValue valueWithCGRect:mainViewFrame]];
	[animation setDuration:duration];
	
	[[[[self mainViewController] view] layer] addAnimation:animation forKey:@"bounds"];*/
}

@end
