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
	CGFloat initialTouchX;
	CGFloat initialViewCenterX;
	CGFloat currentMainViewCenterX;
}

@end

/* Default Values */
static const CGFloat kADDefaultAnchorAmount = 300.0f;

static const BOOL kADDefaultMainViewAllowsInteraction = NO;

static const ADAnchorWidthType kADDefaultAnchorWidthType = ADAnchorWidthTypePeek;
static const ADAnchorLayoutType kADDefaultAnchorLayoutType = ADAnchorLayoutTypeSlide;
static const ADUndersidePersistencyType kADDefaultUndersidePersistencyType = ADUndersidePersistencyTypeNone;
static const ADSecondaryLayoutType kADDefaultSecondaryLayoutType = ADSecondaryLayoutTypeUnderneath;

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
	
	_leftViewAnchorLayoutType = kADDefaultAnchorLayoutType;
	_rightViewAnchorLayoutType = kADDefaultAnchorLayoutType;
	
	_leftViewSecondaryLayoutType = kADDefaultSecondaryLayoutType;
	_rightViewSecondaryLayoutType = kADDefaultSecondaryLayoutType;
	
	_undersidePersistencyType = kADDefaultUndersidePersistencyType;	
	
	_mainViewShouldAllowInteractionsWhenAnchored = kADDefaultMainViewAllowsInteraction;
	_anchoredToSide = ADAnchorSideCenter;
}

- (void)viewDidLoad {
	NSLog();
	
	[super viewDidLoad];
	
	[[self view] setAutoresizingMask:kFullScreenAutoResizing];
	
	//Gestures
	_resetTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureActivated:)];
	[_resetTapGesture setCancelsTouchesInView:YES];
	[_resetTapGesture setDelaysTouchesBegan:YES];
	[_resetTapGesture setDelegate:self];
	
	_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureActivated:)];
	[_panGesture setDelegate:self];
	
	/* Key-Value Observation */
	[self addObserver:self forKeyPath:@"leftViewAnchorWidth" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"rightViewAnchorWidth" options:NSKeyValueObservingOptionNew context:nil];
	
	[self addObserver:self forKeyPath:@"leftViewAnchorWidthType" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"rightViewAnchorWidthType" options:NSKeyValueObservingOptionNew context:nil];
	
	[self addObserver:self forKeyPath:@"leftViewAnchorLayoutType" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"rightViewAnchorLayoutType" options:NSKeyValueObservingOptionNew context:nil];
	
	[self addObserver:self forKeyPath:@"leftViewSecondaryLayoutType" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"rightViewSecondaryLayoutType" options:NSKeyValueObservingOptionNew context:nil];
	
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	[UIView animateWithDuration:duration animations:^{
		[self updateLayout];
	}];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

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
		
		[[[self mainViewController] view] addGestureRecognizer:[self resetTapGesture]];
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
		[self addChildViewController:[self mainViewController]];
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
	CGFloat currentTouchX = [sender locationInView:[self view]].x;
	
	if ([sender state] == UIGestureRecognizerStateBegan) {
		NSLog(@"Began Pan Gesture");
		initialTouchX = currentTouchX;
		initialViewCenterX = currentMainViewCenterX;
	} else if ([sender state] == UIGestureRecognizerStateChanged) {
		//Calculate movement
		
		CGFloat panAmount = initialTouchX - currentTouchX;
		CGFloat newCenter = initialViewCenterX - panAmount;
		
		//Calculate Elastic
		CGFloat viewCenter = CGRectGetMidX([[self view] bounds]);
		CGFloat viewWidth;
		CGFloat extra;
		int multiple = 1;
		if (newCenter > viewCenter) {
			viewWidth = [[[self leftViewController] view] frame].size.width;
		} else {
			viewWidth = [[[self rightViewController] view] frame].size.width;
			multiple = -1;
		}
		CGFloat delta = abs(viewCenter - newCenter);
		if (delta > viewWidth) {
			CGFloat elasticity = 100;
			CGFloat proportion = (delta - viewWidth) / elasticity;
			
			CGFloat equation;
			equation = tanh(proportion/2) * elasticity;
			
			extra = viewWidth + equation;
			newCenter = viewCenter + extra * multiple;
		}
		
		//Check the view we are panning to exists
		if ((newCenter > viewCenter && ![self leftViewController]) || (newCenter < viewCenter && ![self rightViewController])) {
			newCenter = viewCenter;
		}
		
		[self moveMainViewToHorizontalCenter:newCenter];
	} else if ([sender state] == UIGestureRecognizerStateEnded || [sender state] == UIGestureRecognizerStateCancelled) {
		CGFloat velocity = [sender velocityInView:[self view]].x;
		
		ADAnchorSide side;
		NSTimeInterval duration;
		
		if (velocity > -100 && velocity < 100) {
			side = [self anchoredToSide];
			
			duration = kADViewAnimationTime;
		} else {
			if ([self leftViewShowing] && velocity > 0) {
				side = ADAnchorSideRight;
			} else if ([self rightViewShowing] && velocity < 0) {
				side = ADAnchorSideLeft;
			} else {
				side = ADAnchorSideCenter;
			}
			
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
		}
		
		NSLog(@"Finished: velocity = %f, duration %f", velocity, duration);
		
		[self anchorTopViewTo:side animated:YES duration:duration completion:NULL];
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	if (gestureRecognizer == [self panGesture]) {
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
	
	BOOL resetTapEnabled;
	if ([self anchoredToSide] != ADAnchorSideCenter) {
		resetTapEnabled = YES;
	} else {
		resetTapEnabled = NO;
	}
	
	//Do the stuff
	[self moveMainViewToHorizontalCenter:newCenter];
	[[self resetTapGesture] setEnabled:resetTapEnabled];
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
	CGFloat newCenter = 0;//[[[self mainViewController] view] center].x;
	
	if (side == ADAnchorSideCenter) {
		newCenter = horizontalCenter;
	} else if (side == ADAnchorSideLeft) {//showing the right side
		CGFloat distance = 0;
		switch ([self rightViewAnchorWidthType]) {
			case ADAnchorWidthTypePeek:
				distance = [[self view] bounds].size.width - [self rightViewAnchorWidth];
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
				distance = [[self view] bounds].size.width - [self leftViewAnchorWidth];
				break;
			case ADAnchorWidthTypeReveal:
				distance = [self leftViewAnchorWidth];
				break;
		}
		newCenter = horizontalCenter + distance;
	}
	
	return newCenter;
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

#pragma mark - Movement

- (void)moveMainViewToHorizontalCenter:(CGFloat)newCenter {
	NSLog(@"%f", newCenter);
	
	currentMainViewCenterX = newCenter;
	
	CGRect mainViewFrame = [[self view] bounds];
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
	}
	
	CGRect mainViewBounds = CGRectZero;
	mainViewBounds.size = mainViewFrame.size;
	
	[[[self mainViewController] view] setFrame:mainViewFrame];
	//[[[self mainViewController] view] setBounds:mainViewBounds];
	
	if ([self leftViewSecondaryLayoutType] == ADSecondaryLayoutTypeSlide) {
		CGRect leftFrame = [[[self leftViewController] view] frame];
		leftFrame.origin.x = leftFrame.size.width;
		leftFrame.origin.x *= -1;
		leftFrame.origin.x -= viewCenter - newCenter;
		CGPoint leftCenter = CGPointMake(CGRectGetMidX(leftFrame), CGRectGetMidY(leftFrame));
		[[[self leftViewController] view] setCenter:leftCenter];
	}
	
	if ([self rightViewSecondaryLayoutType] == ADSecondaryLayoutTypeSlide) {
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
	
	//[[self view] sendSubviewToBack:[[self rightViewController] view]];
	[[[self rightViewController] view] setHidden:YES];
	[[[self leftViewController] view] setHidden:NO];
	
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(ADSlidingViewControllerWillShowLeftView:)]) {
		[[self delegate] ADSlidingViewControllerWillShowLeftView:self];
	}
}

- (void)rightViewWillAppear {
	NSLog();
	
	//[[self view] sendSubviewToBack:[[self leftViewController] view]];
	[[[self leftViewController] view] setHidden:YES];
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
		[self updateMainViewLayout];
	};
	
	//Completion Block
	void (^acompletion)(BOOL finished) = ^(BOOL finished) {
		[[self view] setUserInteractionEnabled:YES];
		if (completion) {
			completion();
		}
		
		if (side != ADAnchorSideCenter) {
			[_resetTapGesture setEnabled:YES];
		} else {
			[_resetTapGesture setEnabled:NO];
		}
		
		if ([self delegate] && [[self delegate] respondsToSelector:@selector(ADSlidingViewController:didAnchorToSide:)]) {
			[[self delegate] ADSlidingViewController:self didAnchorToSide:side];
		}
	};
	
	//Do the animation
	if (animated) {
		[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:animations completion:acompletion];
	} else {
		animations();
		acompletion(YES);
	}
}

@end
