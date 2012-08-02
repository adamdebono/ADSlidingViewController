//
//  ADSlidingViewController.h
//  ADSlidingViewController
//
//  Created by Adam Debono on 2/08/12.
//  Copyright (c) 2012 Adam Debono. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/* Anchor Side */
typedef NS_ENUM(NSInteger, ADAnchorSide) {
	ADAnchorSideLeft,
	ADAnchorSideCenter,
	ADAnchorSideRight
};

/* Anchor Width Type */
typedef NS_ENUM(NSInteger, ADAnchorWidthType) {
	ADAnchorWidthTypePeek,
	ADAnchorWidthTypeReveal
};

/* Anchor Layout Type */
typedef NS_ENUM(NSInteger, ADAnchorLayoutType) {
	ADAnchorLayoutTypeSlide,
	ADAnchorLayoutTypeResize
};

/* Secondary Layout Type */
typedef NS_ENUM(NSInteger, ADSecondaryLayoutType) {
	ADSecondaryLayoutTypeUnderneath,
	ADSecondaryLayoutTypeSlide
};

/* Underside Persitency */
typedef NS_ENUM(NSInteger, ADUndersidePersistencyType) {
	ADUndersidePersistencyTypeNone,
	ADUndersidePersistencyTypeLandscapeOnly,
	ADUndersidePersistencyTypeAlways
};

/* Reset Methods */
typedef NS_ENUM(NSInteger, ADResetStrategy) {
	ADResetStrategyNone = 0,
	ADResetStrategyTapping = 1 << 0,
	ADResetStrategyPanning = 1 << 1
};

/* Delegate */
@class ADSlidingViewController;
@protocol ADSlidingViewControllerDelegate <NSObject>
//Anchoring
- (BOOL)ADSlidingViewController:(ADSlidingViewController *)slidingViewController shouldAnchorToSide:(ADAnchorSide)side;
- (void)ADSlidingViewController:(ADSlidingViewController *)slidingViewController didAnchorToSide:(ADAnchorSide)side;

- (void)ADSlidingViewControllerWillShowLeftView:(ADSlidingViewController *)slidingViewController;
- (void)ADSlidingViewControllerWillShowRightView:(ADSlidingViewController *)slidingViewController;
@end


@interface ADSlidingViewController : UIViewController

@property (nonatomic, weak) id<ADSlidingViewControllerDelegate> delegate;

/* The View Controllers */
@property (nonatomic) UIViewController *mainViewController;
@property (nonatomic) UIViewController *leftViewController;
@property (nonatomic) UIViewController *rightViewController;

/* Layout Properties */
@property CGFloat leftAnchorAmount;
@property CGFloat rightAnchorAmount;
@property ADAnchorWidthType leftAnchorWidthType;
@property ADAnchorWidthType rightAnchorWidthType;
@property ADAnchorLayoutType leftAnchorLayoutType;
@property ADAnchorLayoutType rightAnchorLayoutType;

@property ADUndersidePersistencyType undersidePersistencyType;
@property (nonatomic) ADResetStrategy resetStrategy;

@property BOOL shouldAllowInteractionsWhenAnchored;

/* Methods */

#pragma mark - View Information
- (BOOL)leftViewShowing;
- (BOOL)rightViewShowing;

#pragma mark - Getters
- (UIPanGestureRecognizer *)panGesture;
- (ADAnchorSide)anchoredToSide;

#pragma mark - Anchoring Functions
- (void)anchorTopViewTo:(ADAnchorSide)side;
- (void)anchorTopViewTo:(ADAnchorSide)side animated:(BOOL)animated;
- (void)anchorTopViewTo:(ADAnchorSide)side animated:(BOOL)animated completion:(void(^)())completion;

@end

@interface UIViewController (ADSlidingViewController)
- (ADSlidingViewController *)slidingViewController;
@end