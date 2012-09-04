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
typedef enum {
	ADAnchorSideLeft = 0,
	ADAnchorSideCenter = 1,
	ADAnchorSideRight = 2
} ADAnchorSide;

/* Anchor Width Type */
typedef enum {
	ADAnchorWidthTypePeek = 0,
	ADAnchorWidthTypeReveal = 1
} ADAnchorWidthType;

/* Anchor Layout Type */
typedef enum {
	ADAnchorLayoutTypeSlide = 0,
	ADAnchorLayoutTypeResize = 1
} ADAnchorLayoutType;

/* Secondary Layout Type */
typedef enum {
	ADSecondaryLayoutTypeUnderneath = 0,
	ADSecondaryLayoutTypeSlide = 1
} ADSecondaryLayoutType;

/* Underside Persitency */
typedef enum {
	ADUndersidePersistencyTypeNone = 0,
	ADUndersidePersistencyTypeLandscapeOnly = 1,
	ADUndersidePersistencyTypeAlways = 2
} ADUndersidePersistencyType;

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
@property CGFloat leftViewAnchorWidth;
@property CGFloat rightViewAnchorWidth;
@property ADAnchorWidthType leftViewAnchorWidthType;
@property ADAnchorWidthType rightViewAnchorWidthType;
@property ADAnchorLayoutType leftViewAnchorLayoutType;
@property ADAnchorLayoutType rightViewAnchorLayoutType;
@property ADSecondaryLayoutType leftViewSecondaryLayoutType;
@property ADSecondaryLayoutType rightViewSecondaryLayoutType;

@property ADUndersidePersistencyType undersidePersistencyType;

@property BOOL mainViewShouldAllowInteractionsWhenAnchored;

@property (readonly) ADAnchorSide anchoredToSide;

/* UI Properties */
@property (nonatomic) BOOL showTopViewShadow;

/* Gestures */
@property (readonly) UITapGestureRecognizer *resetTapGesture;
@property (readonly) UIPanGestureRecognizer *panGesture;

/* Methods */

#pragma mark - View Information
- (BOOL)leftViewShowing;
- (BOOL)rightViewShowing;

#pragma mark - Getters
- (ADAnchorSide)anchoredToSide;

#pragma mark - Anchoring Functions
- (void)anchorTopViewTo:(ADAnchorSide)side;
- (void)anchorTopViewTo:(ADAnchorSide)side animated:(BOOL)animated;
- (void)anchorTopViewTo:(ADAnchorSide)side animated:(BOOL)animated completion:(void(^)())completion;

@end

@interface UIViewController (ADSlidingViewController)
- (ADSlidingViewController *)slidingViewController;
@end