//
//  ADSlidingViewController.m
//  ADSlidingViewController
//
//  Created by Adam Debono on 2/08/12.
//  Copyright (c) 2012 Adam Debono. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ADSlidingViewController.h"

#pragma mark  UIViewController Extension
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
}

/* Gestures */
@property (nonatomic) UITapGestureRecognizer *resetTapGesture;
@property (nonatomic) UIPanGestureRecognizer *panGesture;

/* Layout Properties */
@property (nonatomic) ADAnchorSide anchoredToSide;

@end

/* Default Values */
static const CGFloat kADDefaultAnchorAmount = 300.0f;
static const CGFloat kADDegaultElasticityAmount = 0.25;

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
	_resetStrategy = ADResetStrategyTapping | ADResetStrategyPanning;
	
	
	_elasticityAmount = kADDegaultElasticityAmount;
	_mainViewShouldAllowInteractionsWhenAnchored = kADDefaultMainViewAllowsInteraction;
	_anchoredToSide = ADAnchorSideCenter;
}

- (void)viewDidLoad {
	NSLog();
	
	[super viewDidLoad];
	
	//Gestures
	_resetTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureActivated:)];
	_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureActivated:)];
	
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
	
	//Shadow
	[[[[self mainViewController] view] layer] setShadowOffset:CGSizeZero];
	[[[[self mainViewController] view] layer] setShadowPath:[UIBezierPath bezierPathWithRect:[[[self view] layer] bounds]].CGPath];
	[[[[self mainViewController] view] layer] setShadowRadius:10];
	[[[[self mainViewController] view] layer] setShadowColor:[[UIColor blackColor] CGColor]];
	if ([self showTopViewShadow]) {
		[[[[self mainViewController] view] layer] setShadowOpacity:0.75f];
	} else {
		[[[[self mainViewController] view] layer] setShadowOpacity:0.0f];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	[self updateLayout];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
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
		
		CGRect mainViewFrame;
		UIViewAutoresizing mainViewAutoResizing;
		
		switch ([self undersidePersistencyType]) {
			case ADUndersidePersistencyTypeNone:
				mainViewFrame = [[self view] bounds];
				mainViewAutoResizing = kFullScreenAutoResizing;
				break;
			case ADUndersidePersistencyTypeLandscapeOnly:
				break;
			case ADUndersidePersistencyTypeAlways:
				break;
		}
		
		[[[self mainViewController] view] setFrame:mainViewFrame];
		[[[self mainViewController] view] setAutoresizingMask:mainViewAutoResizing];
		
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

- (void)setResetStrategy:(ADResetStrategy)resetStrategy {
	NSLog();
	_resetStrategy = resetStrategy;
	
	if ([self resetStrategy] & ADResetStrategyTapping) {
		[[self resetTapGesture] setEnabled:YES];
	} else {
		[[self resetTapGesture] setEnabled:NO];
	}
}

- (void)setShowTopViewShadow:(BOOL)showTopViewShadow {
	NSLog(@"%d", showTopViewShadow);
	_showTopViewShadow = showTopViewShadow;
	if ([self showTopViewShadow]) {
		[[[[self mainViewController] view] layer] setShadowOpacity:0.75f];
	} else {
		[[[[self mainViewController] view] layer] setShadowOpacity:0.0f];
	}
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

#pragma mark - Getters

- (UIPanGestureRecognizer *)panGesture {
	return _panGesture;
}

- (ADAnchorSide)anchoredToSide {
	return _anchoredToSide;
}

#pragma mark - Gestures

- (void)tapGestureActivated:(UITapGestureRecognizer *)sender {
	NSLog();
	[self anchorTopViewTo:ADAnchorSideCenter];
}

- (void)panGestureActivated:(UIPanGestureRecognizer *)sender {
	CGFloat currentTouchX = [sender locationInView:[self view]].x;
	
	if ([sender state] == UIGestureRecognizerStateBegan) {
		NSLog(@"Began");
		initialTouchX = currentTouchX;
		initialViewCenterX = [[[self mainViewController] view] center].x;
	} else if ([sender state] == UIGestureRecognizerStateChanged) {
		//Calculate movement
		CGFloat panAmount = initialTouchX - currentTouchX;
		CGFloat newCenter = initialViewCenterX - panAmount;
		
		//Calculate Elastic
		CGFloat viewCenter = CGRectGetMidX([[self view] bounds]);
		CGFloat viewWidth;
		CGFloat extra;
		int multiple = 1;
		extra = abs(newCenter - viewCenter);
		if (newCenter > viewCenter) {
			extra -= (viewWidth = [[[self leftViewController] view] frame].size.width);
			multiple = -1;
		} else {
			extra -= (viewWidth = [[[self rightViewController] view] frame].size.width);
		}
		if (extra > 0) {
			newCenter += extra * (1 - [self elasticityAmount]) * multiple;
			//newCenter += log(extra) * multiple;
			//newCenter += extra
			//newCenter = initialViewCenterX + (viewWidth + 2/extra) * multiple;
		}
		
		//Check the view we are panning to exists
		if ((newCenter > viewCenter && ![self leftViewController]) || (newCenter < viewCenter && ![self rightViewController])) {
			newCenter = viewCenter;
		}
		
		NSLog(@"Changed: newCenter = %f", newCenter);
		
		[self moveMainViewToHorizontalCenter:newCenter];
	} else if ([sender state] == UIGestureRecognizerStateEnded || [sender state] == UIGestureRecognizerStateCancelled) {
		CGFloat velocity = [sender velocityInView:[self view]].x;
		
		ADAnchorSide side;
		
		if ([self leftViewShowing] && velocity > 100) {
			side = ADAnchorSideRight;
		} else if ([self rightViewShowing] && velocity < 100) {
			side = ADAnchorSideLeft;
		} else {
			side = ADAnchorSideCenter;
		}
		
		CGFloat newCenter = [self calculateMainViewCenterWhenAnchoredToSide:side];
		CGFloat viewCenter = CGRectGetMidX([[self view] bounds]);
		CGFloat distance = fabsf(newCenter - viewCenter);
		NSTimeInterval duration = (double)distance / fabs(velocity);
		
		NSLog(@"Finished: velocity = %f, duration %f", velocity, duration);
		
		//[self anchorTopViewTo:side animated:YES duration:duration completion:NULL];
		[self anchorTopViewTo:side];
	}
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
	CGFloat newCenter = [self calculateMainViewCenterWhenAnchoredToSide:[self anchoredToSide]];
	
	BOOL resetTapEnabled;
	if ([self anchoredToSide] == ADAnchorSideCenter) {
		resetTapEnabled = NO;
	} else {
		resetTapEnabled = YES;
	}
	
	//Do the stuff
	[self moveMainViewToHorizontalCenter:newCenter];
	[[self resetTapGesture] setEnabled:resetTapEnabled];
	
	//Shadow
	[[[[self mainViewController] view] layer] setShadowOffset:CGSizeZero];
	[[[[self mainViewController] view] layer] setShadowPath:[UIBezierPath bezierPathWithRect:[[[self view] layer] bounds]].CGPath];
}

- (CGFloat)calculateMainViewCenterWhenAnchoredToSide:(ADAnchorSide)side {
	//Calculations
	CGFloat horizontalCenter = CGRectGetMidX([[self view] bounds]);
	CGFloat newCenter = [[[self mainViewController] view] center].x;
	
	if (side == ADAnchorSideCenter) {
		newCenter = horizontalCenter;
	} else if ([self anchoredToSide] == ADAnchorSideLeft) {//showing the left side
		CGFloat distance = 0;
		switch ([self rightViewAnchorWidthType]) {
			case ADAnchorWidthTypePeek:
				distance = [[[self mainViewController] view] frame].size.width - [self rightViewAnchorWidth];
				break;
			case ADAnchorWidthTypeReveal:
				distance = [self rightViewAnchorWidth];
				break;
		}
		newCenter = horizontalCenter - distance;
	} else if (side == ADAnchorSideRight) {//showing the right side
		CGFloat distance = 0;
		switch ([self leftViewAnchorWidthType]) {
			case ADAnchorWidthTypePeek:
				distance = [[[self mainViewController] view] frame].size.width - [self leftViewAnchorWidth];
				break;
			case ADAnchorWidthTypeReveal:
				distance = [self leftViewAnchorWidth];
				break;
		}
		newCenter = horizontalCenter + distance;
	}
	
	return newCenter;
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

#pragma mark - Movement

- (void)moveMainViewToHorizontalCenter:(CGFloat)newCenter {
	NSLog(@"%f", newCenter);
	
	CGFloat viewCenter = CGRectGetMidX([[self view] bounds]);
	
	CGRect mainFrame = [[self view] bounds];
	
	mainFrame.origin.x = newCenter - viewCenter;
	if (newCenter < viewCenter) {
		[self rightViewWillAppear];
		
		if ([self rightViewAnchorLayoutType] == ADAnchorLayoutTypeResize) {
			
		}
	} else if (newCenter > viewCenter) {
		[self leftViewWillAppear];
		
		if ([self leftViewAnchorLayoutType] == ADAnchorLayoutTypeResize) {
			mainFrame.size.width -= mainFrame.origin.x;
		}
	}
	
	[[[self mainViewController] view] setFrame:mainFrame];
	
	if ([self leftViewSecondaryLayoutType] == ADSecondaryLayoutTypeSlide) {
		CGRect leftFrame = [[[self leftViewController] view] frame];
		leftFrame.origin.x = leftFrame.size.width;
		leftFrame.origin.x *= -1;
		leftFrame.origin.x -= viewCenter - newCenter;
		[[[self leftViewController] view] setFrame:leftFrame];
	}
	
	if ([self rightViewSecondaryLayoutType] == ADSecondaryLayoutTypeSlide) {
		CGRect rightFrame = [[[self rightViewController] view] frame];
		rightFrame.origin.x = [[self view] bounds].size.width;
		rightFrame.origin.x -= viewCenter - newCenter;
		[[[self rightViewController] view] setFrame:rightFrame];
	}
}

- (void)leftViewWillAppear {
	NSLog();
	
	[[self view] sendSubviewToBack:[[self rightViewController] view]];
	
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(ADSlidingViewControllerWillShowLeftView:)]) {
		[[self delegate] ADSlidingViewControllerWillShowLeftView:self];
	}
}

- (void)rightViewWillAppear {
	NSLog();
	
	[[self view] sendSubviewToBack:[[self leftViewController] view]];
	
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
	
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(ADSlidingViewController:shouldAnchorToSide:)] && ![[self delegate] ADSlidingViewController:self shouldAnchorToSide:side]) {
		return;
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
		[self updateMainViewLayout];
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
		[UIView animateWithDuration:duration delay:0 options:UIViewAnimationCurveEaseOut animations:animations completion:acompletion];
	} else {
		animations();
		acompletion(YES);
	}
}

@end
