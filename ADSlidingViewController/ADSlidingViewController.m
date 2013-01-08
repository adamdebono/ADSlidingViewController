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
@interface ADSlidingViewController () <UIViewControllerRestoration> {
	CGFloat initialViewCenterX;
	CGFloat currentMainViewCenterX;
}

@property (nonatomic) BOOL leftViewHasAppeared;
@property (nonatomic) BOOL rightViewHasAppeared;

@end

/* Default Values */
static const CGFloat kADDefaultAnchorAmount = 280.0f;

static const BOOL kADDefaultMainViewAllowsInteraction = NO;

static const ADAnchorWidthType kADDefaultAnchorWidthType = ADAnchorWidthTypeReveal;
static const ADMainAnchorType kADDefaultMainAnchorType = ADMainAnchorTypeSlide;
static const ADUndersidePersistencyType kADDefaultUndersidePersistencyType = ADUndersidePersistencyTypeNone;
static const ADUnderAnchorType kADDefaultUnderAnchorType = ADUnderAnchorTypeUnderneath;

/* Constants */
static NSString *const kADStateRestorationIdentifier = @"ADSlidingViewControllerRestorationIdentifier";

static const CGFloat kADViewAnimationTime = 0.3f;

static const UIViewAutoresizing kFullScreenAutoResizing = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
static const UIViewAutoresizing kLeftSideAutoResizing = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
static const UIViewAutoresizing kRightSideAutoResizing = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;

#pragma mark - Main Implementation
@implementation ADSlidingViewController

#pragma mark - Initialisation

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
	
	//state restoration
	[self setRestorationIdentifier:kADStateRestorationIdentifier];
	[self setRestorationClass:[self class]];
	
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
	
	_showTopViewShadow = NO;
	
	_leftViewHasAppeared = NO;
	_rightViewHasAppeared = NO;
}

#pragma mark - State Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
	[super encodeRestorableStateWithCoder:coder];
	
	if ([self mainViewController]) {
		[coder encodeObject:[self mainViewController] forKey:@"mainViewController"];
	}
	if ([self leftViewController]) {
		[coder encodeObject:[self leftViewController] forKey:@"leftViewController"];
	}
	if ([self rightViewController]) {
		[coder encodeObject:[self rightViewController] forKey:@"rightViewController"];
	}
	
	[coder encodeFloat:[self leftViewAnchorWidth] forKey:@"leftViewAnchorWidth"];
	[coder encodeFloat:[self rightViewAnchorWidth] forKey:@"rightViewAnchorWidth"];
	
	[coder encodeInteger:[self leftViewAnchorWidthType] forKey:@"leftViewAnchorWidthType"];
	[coder encodeInteger:[self rightViewAnchorWidthType] forKey:@"rightViewAnchorWidthType"];
	
	[coder encodeInteger:[self leftMainAnchorType] forKey:@"leftMainAnchorType"];
	[coder encodeInteger:[self rightMainAnchorType] forKey:@"rightMainAnchorType"];
	
	[coder encodeInteger:[self leftUnderAnchorType] forKey:@"leftUnderAnchorType"];
	[coder encodeInteger:[self rightUnderAnchorType] forKey:@"rightUnderAnchorType"];
	
	[coder encodeInteger:[self undersidePersistencyType] forKey:@"undersidePersistencyType"];
	
	[coder encodeInteger:[self anchoredToSide] forKey:@"anchoredToSide"];
	
	[coder encodeBool:[self showTopViewShadow] forKey:@"showTopViewShadow"];
	
	[coder encodeBool:[self leftViewHasAppeared] forKey:@"leftViewHasAppeared"];
	[coder encodeBool:[self rightViewHasAppeared] forKey:@"rightViewHasAppeared"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
	[super decodeRestorableStateWithCoder:coder];
	
	//Does not matter if these are nil
	[self setMainViewController:[coder decodeObjectForKey:@"mainViewController"]];
	[self setLeftViewController:[coder decodeObjectForKey:@"leftViewController"]];
	[self setRightViewController:[coder decodeObjectForKey:@"rightViewController"]];
	
	_leftViewAnchorWidth = [coder decodeIntegerForKey:@"leftViewAnchorWidth"];
	_rightViewAnchorWidth = [coder decodeIntegerForKey:@"rightViewAnchorWidth"];
	
	_leftViewAnchorWidthType = [coder decodeIntegerForKey:@"leftViewAnchorWidthType"];
	_rightViewAnchorWidthType = [coder decodeIntegerForKey:@"rightViewAnchorWidthType"];
	
	_leftMainAnchorType = [coder decodeIntegerForKey:@"leftMainAnchorType"];
	_rightMainAnchorType = [coder decodeIntegerForKey:@"rightMainAnchortype"];
	
	_leftUnderAnchorType = [coder decodeIntegerForKey:@"leftUnderAnchorType"];
	_rightUnderAnchorType = [coder decodeIntegerForKey:@"rightUnderAnchorType"];
	
	_undersidePersistencyType = [coder decodeIntegerForKey:@"undersidePersistencyType"];
	
	_anchoredToSide = [coder decodeIntegerForKey:@"anchoredToSide"];
	
	_showTopViewShadow = [coder decodeBoolForKey:@"showTopViewShadow"];
	
	_leftViewHasAppeared = [coder decodeBoolForKey:@"leftViewHasAppeared"];
	_rightViewHasAppeared = [coder decodeBoolForKey:@"rightViewHasAppeared"];
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder {
	ADSlidingViewController *controller = [[self alloc] init];
	return controller;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
	NSLog();
	
	[super viewDidLoad];
	
	[[self view] setAutoresizingMask:kFullScreenAutoResizing];
	
	//Gestures
	_resetTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureActivated:)];
	[_resetTapGesture setCancelsTouchesInView:YES];
	[_resetTapGesture setDelegate:self];
	
	_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureActivated:)];
	[_panGesture setCancelsTouchesInView:YES];
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

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
	return YES;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
	return YES;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

#ifdef __IPHONE_6_0
- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
	return YES;
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
		
		[[[[self mainViewController] view] layer] setShouldRasterize:YES];
		[[[[self mainViewController] view] layer] setRasterizationScale:[[UIScreen mainScreen] scale]];
		
		[[[[self mainViewController] view] layer] setMasksToBounds:NO];
		[[[[self mainViewController] view] layer] setShadowColor:[[UIColor blackColor] CGColor]];
		[[[[self mainViewController] view] layer] setShadowOffset:CGSizeZero];
		[[[[self mainViewController] view] layer] setShadowRadius:5];
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
	
	if (_showTopViewShadow) {
		[[[[self mainViewController] view] layer] setShadowOpacity:1.0f];
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
				//extra = tanh(extra / 100) * 100;
				extra /= 2;
				newCenter = viewCenter + (maxDelta + extra) * multiple;
			} else {
				//newCenter = newCenter
			}
		}
		
		[self moveMainViewToHorizontalCenter:newCenter];
	} else if ([sender state] == UIGestureRecognizerStateEnded || [sender state] == UIGestureRecognizerStateCancelled) {
		CGFloat velocity = [sender velocityInView:[self view]].x;
		
		ADAnchorSide side;
		
		if ([sender state] == UIGestureRecognizerStateCancelled) {
			side = _anchoredToSide;
		} else if (velocity > 100) {//moving -> this way
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
		
		NSTimeInterval duration;
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
		if (otherGestureRecognizer != [self panGesture]) {
			return YES;
		}
	} else if (gestureRecognizer == [self panGesture]) {
		
	}
	
	return NO;
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
	CGFloat newCenter = 0;
	
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
		//[self rightViewWillAppear];
		
		if ([self checkUndersidePersistency]) {
			mainViewFrame.size.width -= [[[self rightViewController] view] frame].size.width;
		} else if ([self rightMainAnchorType] == ADMainAnchorTypeResize) {
			mainViewFrame.size.width += mainViewFrame.origin.x;
			mainViewFrame.origin.x = 0;
		}
	};
	
	void (^leftView)(void) = ^{
		//[self leftViewWillAppear];
		
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
	[self moveMainViewToHorizontalCenter:newCenter hidingViews:YES];
}

- (void)moveMainViewToHorizontalCenter:(CGFloat)newCenter hidingViews:(BOOL)hideViews {
	currentMainViewCenterX = newCenter;
	CGRect mainViewFrame = [self calculateMainViewFrameForHorizontalCenter:newCenter];
	CGFloat viewCenter = CGRectGetMidX([[self view] bounds]);
	
	if (hideViews) {
		if (mainViewFrame.origin.x > 0) {
			[self leftViewWillAppear];
			[self leftViewDidAppear];
		} else {
			[self leftViewWillDisappear];
			[self leftViewDidDisappear];
		}
		
		if (mainViewFrame.origin.x + mainViewFrame.size.width < [[self view] bounds].size.width) {
			[self rightViewWillAppear];
			[self rightViewDidAppear];
		} else {
			[self rightViewWillDisappear];
			[self rightViewDidDisappear];
		}
	}
	
	[[[self mainViewController] view] setFrame:mainViewFrame];
	
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
		[[[self rightViewController] view] setFrame:rightFrame];
	}
}

#pragma mark -

- (void)leftViewWillAppear {
	if (!_leftViewHasAppeared) {
		NSLog();
		
		[[[self leftViewController] view] setHidden:NO];
		[[self view] sendSubviewToBack:[[self rightViewController] view]];
		
		if ([self delegate] && [[self delegate] respondsToSelector:@selector(slidingViewControllerWillShowLeftView:)]) {
			[[self delegate] slidingViewControllerWillShowLeftView:self];
		}
	}
}

- (void)leftViewDidAppear {
	if (!_leftViewHasAppeared) {
		NSLog();
		
		_leftViewHasAppeared = YES;
		
		if ([self delegate] && [[self delegate] respondsToSelector:@selector(slidingViewControllerDidShowLeftView:)]) {
			[[self delegate] slidingViewControllerDidShowLeftView:self];
		}
	}
}

- (void)leftViewWillDisappear {
	if (_leftViewHasAppeared) {
		NSLog();
		
		if ([self delegate] && [[self delegate] respondsToSelector:@selector(slidingViewControllerWillHideLeftView:)]) {
			[[self delegate] slidingViewControllerWillHideLeftView:self];
		}
	}
}

- (void)leftViewDidDisappear {
	if (_leftViewHasAppeared) {
		NSLog();
		
		_leftViewHasAppeared = NO;
		[[[self leftViewController] view] setHidden:YES];
		
		if ([self delegate] && [[self delegate] respondsToSelector:@selector(slidingViewControllerDidHideLeftView:)]) {
			[[self delegate] slidingViewControllerDidHideLeftView:self];
		}
	}
}

- (void)rightViewWillAppear {
	if (!_rightViewHasAppeared) {
		NSLog();
		
		[[[self rightViewController] view] setHidden:NO];
		[[self view] sendSubviewToBack:[[self leftViewController] view]];
		
		if ([self delegate] && [[self delegate] respondsToSelector:@selector(slidingViewControllerWillShowRightView:)]) {
			[[self delegate] slidingViewControllerWillShowRightView:self];
		}
	}
}

- (void)rightViewDidAppear {
	if (![self rightViewHasAppeared]) {
		NSLog();
		
		_rightViewHasAppeared = YES;
		
		if ([self delegate] && [[self delegate] respondsToSelector:@selector(slidingViewControllerDidShowRightView:)]) {
			[[self delegate] slidingViewControllerDidShowRightView:self];
		}
	}
}

- (void)rightViewWillDisappear {
	if (_rightViewHasAppeared) {
		NSLog();
		
		if ([self delegate] && [[self delegate] respondsToSelector:@selector(slidingViewControllerWillHideRightView:)]) {
			[[self delegate] slidingViewControllerWillHideRightView:self];
		}
	}
}

- (void)rightViewDidDisappear {
	if ([self rightViewHasAppeared]) {
		NSLog();
		
		_rightViewHasAppeared = NO;
		[[[self rightViewController] view] setHidden:YES];
		
		if ([self delegate] && [[self delegate] respondsToSelector:@selector(slidingViewControllerDidHideRightView:)]) {
			[[self delegate] slidingViewControllerDidHideRightView:self];
		}
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
	
	if (side == ADAnchorSideLeft) {
		[self rightViewWillAppear];
		[self leftViewWillDisappear];
	} else if (side == ADAnchorSideRight) {
		[self rightViewWillDisappear];
		[self leftViewWillAppear];
	} else {
		[self rightViewWillDisappear];
		[self leftViewWillDisappear];
	}
	
	_anchoredToSide = side;
	[[self view] setUserInteractionEnabled:NO];
	
	//Animation Block
	void (^animations)() = ^{
		CGFloat newCenter = [self calculateMainViewHorizontalCenterWhenAnchoredToSide:[self anchoredToSide]];
		[self moveMainViewToHorizontalCenter:newCenter hidingViews:NO];
	};
	
	//Completion Block
	void (^acompletion)(BOOL finished) = ^(BOOL finished) {
		[[self view] setUserInteractionEnabled:YES];
		
		if (side == ADAnchorSideLeft) {
			[self rightViewDidAppear];
			[self leftViewDidDisappear];
		} else if (side == ADAnchorSideRight) {
			[self rightViewDidDisappear];
			[self leftViewDidAppear];
		} else {
			[self rightViewDidDisappear];
			[self leftViewDidDisappear];
		}
		
		if (completion) {
			completion();
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
