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
	ADAnchorSideLeft = 0,
	ADAnchorSideCenter = 1,
	ADAnchorSideRight = 2
};

/* Anchor Width Type */
typedef NS_ENUM(NSInteger, ADAnchorWidthType) {
	ADAnchorWidthTypePeek = 0,
	ADAnchorWidthTypeReveal = 1
};

/* Anchor Layout Type */
typedef NS_ENUM(NSInteger, ADAnchorLayoutType) {
	ADAnchorLayoutTypeSlide = 0,
	ADAnchorLayoutTypeResize = 1
};

/* Secondary Layout Type */
typedef NS_ENUM(NSInteger, ADSecondaryLayoutType) {
	ADSecondaryLayoutTypeUnderneath = 0,
	ADSecondaryLayoutTypeSlide = 1
};

/* Underside Persitency */
typedef NS_ENUM(NSInteger, ADUndersidePersistencyType) {
	ADUndersidePersistencyTypeNone = 0,
	ADUndersidePersistencyTypeLandscapeOnly = 1,
	ADUndersidePersistencyTypeAlways = 2
};

/* Reset Strategies */
typedef NS_ENUM(NSInteger, ADResetStrategy) {
	ADResetStrategyNone = 0,
	ADResetStrategyTapping = 1 << 0,
	ADResetStrategyPanning = 1 << 1
};

/* Delegate */
@class ADSlidingViewController;
@protocol ADSlidingViewControllerDelegate <NSObject>
@optional

//Anchoring
- (void)ADSlidingViewController:(ADSlidingViewController *)slidingViewController didAnchorToSide:(ADAnchorSide)side;

- (void)ADSlidingViewControllerWillShowLeftView:(ADSlidingViewController *)slidingViewController;
- (void)ADSlidingViewControllerWillShowRightView:(ADSlidingViewController *)slidingViewController;
@end


@interface ADSlidingViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<ADSlidingViewControllerDelegate> delegate;

/* The View Controllers */
@property (nonatomic) UIViewController *mainViewController;
@property (nonatomic) UIViewController *leftViewController;
@property (nonatomic) UIViewController *rightViewController;

/* Layout Properties */
@property (nonatomic) CGFloat leftViewAnchorWidth;
@property (nonatomic) CGFloat rightViewAnchorWidth;
@property (nonatomic) ADAnchorWidthType leftViewAnchorWidthType;
@property (nonatomic) ADAnchorWidthType rightViewAnchorWidthType;
@property (nonatomic) ADAnchorLayoutType leftViewAnchorLayoutType;
@property (nonatomic) ADAnchorLayoutType rightViewAnchorLayoutType;
@property (nonatomic) ADSecondaryLayoutType leftViewSecondaryLayoutType;
@property (nonatomic) ADSecondaryLayoutType rightViewSecondaryLayoutType;

@property (nonatomic) ADUndersidePersistencyType undersidePersistencyType;
@property (nonatomic) ADResetStrategy resetStrategy;

@property CGFloat elasticityAmount;

@property BOOL mainViewShouldAllowInteractionsWhenAnchored;

/* UI Properties */
@property (nonatomic) BOOL showTopViewShadow;

/* Gestures */
@property (readonly) UITapGestureRecognizer *resetTapGesture;

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