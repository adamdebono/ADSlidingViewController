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

/* Main Anchor Type */
typedef NS_ENUM(NSInteger, ADMainAnchorType) {
	ADMainAnchorTypeSlide = 0,
	ADMainAnchorTypeResize = 1
};

/* Under Layout Type */
typedef NS_ENUM(NSInteger, ADUnderAnchorType) {
	ADUnderAnchorTypeUnderneath = 0,
	ADUnderAnchorTypeSlide = 1
};

/* Underside Persitency */
typedef NS_ENUM(NSInteger, ADUndersidePersistencyType) {
	ADUndersidePersistencyTypeNone = 0,
	ADUndersidePersistencyTypeLandscape = 1,
	ADUndersidePersistencyTypeAlways = 2
};

/* Delegate */
@class ADSlidingViewController;
@protocol ADSlidingViewControllerDelegate <NSObject>
@optional

/*
 Sent to the delegate just before the mainViewController begins sliding.
 
 NOTE: this is called AFTER the pan gesture is complete.
 
 @param ADSlidingViewController	slidingViewController	The controller that sent the message.
 @param ADAnchorSide			side					The side about to anchor to.
 @param NSTimeInterval			duration				The duration of the pending animation, in seconds.
 */
- (void)ADSlidingViewController:(ADSlidingViewController *)slidingViewController willAnchorToSide:(ADAnchorSide)side duration:(NSTimeInterval)duration;
/*
 Sent to the delegate just before performing the slide animation.
 
 This is called from within the animation block used to slide the view. By the time this method has been called, the view manipulation has been calculated and set.
 
 @param ADSlidingViewController	slidingViewController	The controller that sent the message.
 @param ADAnchorSide			side					The side about to anchor to.
 @param NSTimeInterval			duration				The duration of the pending animation, in seconds.
 */
- (void)ADSlidingViewController:(ADSlidingViewController *)slidingViewController willAnimateAnchorToSide:(ADAnchorSide)side duration:(NSTimeInterval)duration;
/*
 Sent to the delegate after the mainViewController has finished sliding.
 
 @param ADSlidingViewController	slidingViewController	The controller that sent the message.
 @param ADAnchorSide			side					The side just anchored to.
 */
- (void)ADSlidingViewController:(ADSlidingViewController *)slidingViewController didAnchorToSide:(ADAnchorSide)side;

- (void)slidingViewControllerPanGestureDidActivate:(ADSlidingViewController *)slidingViewController;

- (void)slidingViewControllerWillShowLeftView:(ADSlidingViewController *)slidingViewController;
- (void)slidingViewControllerDidShowLeftView:(ADSlidingViewController *)slidingViewController;
- (void)slidingViewControllerWillHideLeftView:(ADSlidingViewController *)slidingViewController;
- (void)slidingViewControllerDidHideLeftView:(ADSlidingViewController *)slidingViewController;

- (void)slidingViewControllerWillShowRightView:(ADSlidingViewController *)slidingViewController;
- (void)slidingViewControllerDidShowRightView:(ADSlidingViewController *)slidingViewController;
- (void)slidingViewControllerWillHideRightView:(ADSlidingViewController *)slidingViewController;
- (void)slidingViewControllerDidHideRightView:(ADSlidingViewController *)slidingViewController;

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
 Using ADMainAnchorTypeResize behaves unpredictably and is not supported.
 
 ADUndersidePersistencyTypeNone: The under views are only shown when the main view is moved (or resized) aside.
 ADUndersidePersistencyTypeLandscape: An under view is always shown in landscape, but behaves normally in portrait.
 ADUndersidePersistencyTypeAlways: An under view is always shown.
 */
@property (nonatomic) ADUndersidePersistencyType undersidePersistencyType;

/*
 Returns the side that the main view is currently anchored to
 */
@property (nonatomic, readonly) ADAnchorSide anchoredToSide;

/*
 Set to YES to add a shadow under the main view.
 */
@property (nonatomic) BOOL showTopViewShadow;

/*
 Gestures
 
 NOTE that the resetTapGesture and panGesture will not override everything, such as scroll views. If you wish to have the main view interaction disabled when anchored, you will need to do it manually using the delegate functions.
 */
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
 @param void(^)() animations	A block which is run inside the animation block. Any view manipulation that can cause implicit animations will be animated.
 @param void(^)() completion	A block to run on completion. Can be NULL.
 */
- (void)anchorTopViewTo:(ADAnchorSide)side;
- (void)anchorTopViewTo:(ADAnchorSide)side animated:(BOOL)animated;
- (void)anchorTopViewTo:(ADAnchorSide)side animated:(BOOL)animated animations:(void (^)())animations completion:(void(^)())completion;

+ (void)setLoggingEnabled:(BOOL)enabled;
+ (BOOL)isLoggingEnabled;

@end

@interface UIViewController (ADSlidingViewController)
- (ADSlidingViewController *)slidingViewController;
@end