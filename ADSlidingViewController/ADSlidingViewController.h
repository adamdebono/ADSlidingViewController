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
	ADMainAnchorTypeSlide = 0,
	ADMainAnchorTypeResize = 1
} ADMainAnchorType;

/* Secondary Layout Type */
typedef enum {
	ADUnderAnchorTypeUnderneath = 0,
	ADUnderAnchorTypeSlide = 1
} ADUnderAnchorType;

/* Underside Persitency */
typedef enum {
	ADUndersidePersistencyTypeNone = 0,
	ADUndersidePersistencyTypeLandscape = 1,
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


/*
 Left and Right Anchor Widths
 Defines the distance of anchoring in points.
 
 See Anchor Width Type.
 */
@property (nonatomic) CGFloat leftViewAnchorWidth;
@property (nonatomic) CGFloat rightViewAnchorWidth;

/*
 Left and Right Anchor Layout
 Defines what the anchor width is relative to.
 
 ADAnchorWidthTypePeek: Width defines the amount of main view controller left on the screen.
 ADAnchorWidthTypeReveal: Width defines the amount of under view controller (right or left) shown on screen.
 */
@property (nonatomic) ADAnchorWidthType leftViewAnchorWidthType;
@property (nonatomic) ADAnchorWidthType rightViewAnchorWidthType;

/*
 Left and Right Main Anchor Type.
 Defines how the main view behaves when moved.
 
 ADMainAnchorTypeSlide: The main view slides across, so part of it is on screen.
 ADMainAnchorTypeResize: The main view resizes, with the left or right edge staying aligned to the screen edge.
 */
@property (nonatomic) ADMainAnchorType leftMainAnchorType;
@property (nonatomic) ADMainAnchorType rightMainAnchorType;

/*
 Left and Right Under Anchor Type.
 Defines how the left and right views behave when moved.
 
 ADUnderAnchorTypeUnderneath: The view is aligned to its side of the screen, and the main view moves above it.
 ADUnderAnchorTypeSlide: The view is aligned to one side of the main view, and slides along with it when moved.
 */
@property (nonatomic) ADUnderAnchorType leftUnderAnchorType;
@property (nonatomic) ADUnderAnchorType rightUnderAnchorType;

/*
 Underside Persistency Type.
 Defines whether an under view should always be shown.
 
 At least one under view must exist.
 
 ADUndersidePersistencyTypeNone: The under views are only shown when the main view is moved (or resized) aside.
 ADUndersidePersistencyTypeLandscape: An under view is always shown in landscape, but behaves normally in portrait.
 ADUndersidePersistencyTypeAlways: An under view is always shown.
 */
@property (nonatomic) ADUndersidePersistencyType undersidePersistencyType;

/*
 NOT USED
 */
@property (nonatomic) BOOL mainViewShouldAllowInteractionsWhenAnchored;

/*
 Returns the side that the main view is currently anchored to
 */
@property (nonatomic, readonly) ADAnchorSide anchoredToSide;

/*
 Set to YES to add a shadow under the main view.
 */
@property (nonatomic) BOOL showTopViewShadow;

/* Gestures */
@property (nonatomic, readonly) UITapGestureRecognizer *resetTapGesture;
@property (nonatomic, readonly) UIPanGestureRecognizer *panGesture;


/*
 Returns YES if the view is visible
 */
- (BOOL)leftViewShowing;
- (BOOL)rightViewShowing;

/*
 Anchor the top view to a given side.
 
 @param ADAnchorSide side		The side you wish to anchor to
 @param BOOL animated			Whether or not to animate the movement.
 @param void(^)() completion	A block to run on completion. Can be NULL.
 */
- (void)anchorTopViewTo:(ADAnchorSide)side;
- (void)anchorTopViewTo:(ADAnchorSide)side animated:(BOOL)animated;
- (void)anchorTopViewTo:(ADAnchorSide)side animated:(BOOL)animated completion:(void(^)())completion;

@end

@interface UIViewController (ADSlidingViewController)
- (ADSlidingViewController *)slidingViewController;
@end