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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * @abstract Specifies the position of the mainViewController.
 * @const ADAnchorSideLeft Where the mainViewController is to the left of the
 * screen, showing the rightViewController.
 * @const ADAnchorSideCenter Where the mainViewController is in the center.
 * Neither the left or right view controllers will be visible
 * @const ADAnchorSideRight Where teh mainViewController is to the right of the
 * screen, showing the leftViewController.
 */
typedef NS_ENUM(NSInteger, ADAnchorSide) {
	ADAnchorSideLeft = 0,
	ADAnchorSideCenter = 1,
	ADAnchorSideRight = 2
};

/**
 * @abstract Specifies how the width of an under view controller is calculated.
 * @const ADAnchorWidthTypePeek The anchor width would specify how far the
 * mainViewController 'peeks' onto the screen, and the under view width is the
 * remaining Space.
 * @const ADAnchorWidthTypeReveal The anchor width specifies how wide the under
 * view controller is.
 */
typedef NS_ENUM(NSInteger, ADAnchorWidthType) {
	ADAnchorWidthTypePeek = 0,
	ADAnchorWidthTypeReveal = 1
};

/**
 * @abstract Specifies how the mainViewController reacts when panning/anchoring
 * @const ADMainAnchorTypeSlide The mainViewController slides across the screen.
 * @const ADMainAnchorTypeResize The mainViewController resizes to fit, so that
 * it is pinned to an underViewController on one side, and the opposite side of
 * the screen.
 */
typedef NS_ENUM(NSInteger, ADMainAnchorType) {
	ADMainAnchorTypeSlide = 0,
	ADMainAnchorTypeResize = 1
};

/**
 * @abstract Specifies how an under view controller reacts when
 * panning/anchoring.
 * @const ADUnderAnchorTypeUnderneath The under view remains pinned to the side
 * of the screen.
 * @const ADUnderAnchorTypeSlide The under view remains pinned to the
 * mainViewController.
 */
typedef NS_ENUM(NSInteger, ADUnderAnchorType) {
	ADUnderAnchorTypeUnderneath = 0,
	ADUnderAnchorTypeSlide = 1
};

/**
 * @abstract Specifies whether to leave one under view controller always visble
 * in either landscape or both orientations.
 * @const ADUndersidePersistencyTypeNone The mainViewController takes up the
 * whole screen when anchored to the center.
 * @const ADUndersidePersistencyTypeLandscape An under view controller can
 * always be seen in landscape.
 * @const ADUndersidePersistencyTypeAlways An under view controller can always
 * be seen.
 */
typedef NS_ENUM(NSInteger, ADUndersidePersistencyType) {
	ADUndersidePersistencyTypeNone = 0,
	ADUndersidePersistencyTypeLandscape = 1,
	ADUndersidePersistencyTypeAlways = 2
};

/**
 * @abstract Specifies which reset gestures to use.
 * @discussion Reset gestures are used to re-anchor the main view to the center.
 * 
 * Having either of these set will automatically disable user
 * interaction on the main view (except for these gestures) when the
 * mainViewController is anchored to either side.
 *
 * You may specify both reset gestures by using setting this to
 * ADRestGestureTap|ADResetGesturePan
 * @const ADResetGestureTap Allow the mainViewController to be reset by tapping
 * on it.
 * @const ADResetGesturePan Allow the mainViewController to be reset by panning
 * (dragging) it.
 */
typedef NS_OPTIONS(NSInteger, ADResetGesture) {
	ADResetGestureTap = 1 << 0,
	ADResetGesturePan = 1 << 1
};

/**
 * @abstract Provides a listener interface for events triggered by an
 * ADSlidingViewController
 */
@class ADSlidingViewController;
@protocol ADSlidingViewControllerDelegate <NSObject>
@optional

/**
 * @abstract Called just before the mainViewController begins sliding.
 * @discussion If the anchoring is performed through the pan gesture, this will
 * be called when the pan gesture completes (when the user lifts their finger)
 * @param slidingViewController The controller that sent the message.
 * @param side The side about to anchor to.
 * @param duration The duration of the pending animation, in seconds.
 */
- (void)ADSlidingViewController:(ADSlidingViewController *)slidingViewController willAnchorToSide:(ADAnchorSide)side duration:(NSTimeInterval)duration;

/**
 * @abstract Called just before performing the slide animation.
 * @discussion This is called from within the animation block used to slide the
 * view, so any view manipulation that causes implicit animations performed
 * within the delegate function will be animated using UIView animation.
 * 
 * By the time this method has been called, the view manipulation has been
 * calculated and set.
 * @param slidingViewController The controller that sent the message.
 * @param side The side about to anchor to.
 * @param duration The duration of the pending animation, in seconds.
 */
- (void)ADSlidingViewController:(ADSlidingViewController *)slidingViewController willAnimateAnchorToSide:(ADAnchorSide)side duration:(NSTimeInterval)duration;

/**
 * @abstract Called delegate after the mainViewController has finished it's 
 * sliding animations.
 * @param slidingViewController The controller that sent the message.
 * @param side The side just anchored to.
 */
- (void)ADSlidingViewController:(ADSlidingViewController *)slidingViewController didAnchorToSide:(ADAnchorSide)side;

/**
 * @abstract Called as the pan gesture begins.
 * @param slidingViewController The controller that sent the message.
 */
- (void)slidingViewControllerPanGestureDidActivate:(ADSlidingViewController *)slidingViewController;

/**
 * @abstract Called as the left under view is about to show.
 * @param slidingViewController The controller that sent the message.
 */
- (void)slidingViewControllerWillShowLeftView:(ADSlidingViewController *)slidingViewController;
/**
 * @abstract Called as the left under view has shown.
 * @param slidingViewController The controller that sent the message.
 */
- (void)slidingViewControllerDidShowLeftView:(ADSlidingViewController *)slidingViewController;
/**
 * @abstract Called as the left under view is about to hide.
 * @param slidingViewController The controller that sent the message.
 */
- (void)slidingViewControllerWillHideLeftView:(ADSlidingViewController *)slidingViewController;
/**
 * @abstract Called as the left under view has hidden.
 * @param slidingViewController The controller that sent the message.
 */
- (void)slidingViewControllerDidHideLeftView:(ADSlidingViewController *)slidingViewController;

/**
 * @abstract Called as the right under view is about to show.
 * @param slidingViewController The controller that sent the message.
 */
- (void)slidingViewControllerWillShowRightView:(ADSlidingViewController *)slidingViewController;
/**
 * @abstract Called as the right under view has shown.
 * @param slidingViewController The controller that sent the message.
 */
- (void)slidingViewControllerDidShowRightView:(ADSlidingViewController *)slidingViewController;
/**
 * @abstract Called as the right under view is about to hide.
 * @param slidingViewController The controller that sent the message.
 */
- (void)slidingViewControllerWillHideRightView:(ADSlidingViewController *)slidingViewController;
/**
 * @abstract Called as the right under view has hidden.
 * @param slidingViewController The controller that sent the message.
 */
- (void)slidingViewControllerDidHideRightView:(ADSlidingViewController *)slidingViewController;

@end

/**
 * @abstract An iOS component used to display a main view controller, and two
 * view controllers hidden underneath it.
 */
@interface ADSlidingViewController : UIViewController <UIGestureRecognizerDelegate>

/**
 * @abstract The delegate to receive events sent from an instance.
 */
@property (nonatomic, weak) id<ADSlidingViewControllerDelegate> delegate;

/**
 * @abstract The view controller in the center of the screen.
 */
@property (nonatomic) UIViewController *mainViewController;
/**
 * @abstract The under view controller on the left of the screen.
 */
@property (nonatomic) UIViewController *leftViewController;
/**
 * @abstract The under view controller on the right of the screen.
 */
@property (nonatomic) UIViewController *rightViewController;


/**
 * @abstract Specifies the anchor width for the leftViewController.
 * @discussion See ADAnchorWidthType.
 */
@property (nonatomic) CGFloat leftViewAnchorWidth;
/**
 * @abstract Specifies the anchor width for the rightViewController.
 * @discussion See ADAnchorWidthType.
 */
@property (nonatomic) CGFloat rightViewAnchorWidth;

/**
 * @abstract Specifies the anchor width type for the leftViewController.
 * @discussion See ADAnchorWidthType.
 */
@property (nonatomic) ADAnchorWidthType leftViewAnchorWidthType;
/**
 * @abstract Specifies the anchor width type for the rightViewController.
 * @discussion See ADAnchorWidthType.
 */
@property (nonatomic) ADAnchorWidthType rightViewAnchorWidthType;

/**
 * @abstract Specifies the anchoring type for the mainViewController when
 * the leftViewController is visible (i.e. when anchoring to the right)
 * @discussion See ADMainAnchorType.
 */
@property (nonatomic) ADMainAnchorType leftMainAnchorType;
/**
 * @abstract Specifies the anchoring type for the mainViewController when
 * the rightViewController is visible (i.e. when anchoring to the left)
 * @discussion See ADMainAnchorType.
 */
@property (nonatomic) ADMainAnchorType rightMainAnchorType;

/**
 * @abstract Specifies the anchoring type for the leftViewController
 * @discussion See ADUnderAnchorType.
 */
@property (nonatomic) ADUnderAnchorType leftUnderAnchorType;
/**
 * @abstract Specifies the anchoring type for the rightViewController
 * @discussion See ADUnderAnchorType.
 */
@property (nonatomic) ADUnderAnchorType rightUnderAnchorType;

/**
 * @abstract Specifies the underside persistency type.
 * @discussion See ADUndersidePersistencyType.
 */
@property (nonatomic) ADUndersidePersistencyType undersidePersistencyType;

/**
 * @abstract Set to the side that the mainViewController is currently anchored
 * to.
 * @discussion When a pan gesture is in use, this property will remain where the
 * mainViewController was before the gesture began.
 */
@property (nonatomic, readonly) ADAnchorSide anchoredToSide;

/**
 * @abstract Specifies whether a shadow will be shown underneath the top view.
 * @discussion Shadows usually cause a performance hit, and especially on older
 * devices can create considerable lag, lowering frame rates. If you are
 * experiencing lag, try turning off shadows.
 */
@property (nonatomic) BOOL showTopViewShadow;

/**
 * @abstract The gesture which controls the panning of the main view.
 * @discussion Add this to whatever view you want the gesture to be enabled on.
 * 
 * Note that a gesture can only be added to a single view.
 */
@property (nonatomic, readonly) UIPanGestureRecognizer *panGesture;

/**
 * @abstract Set the ways to reset the mainViewController from being anchored to
 * a side.
 * @discussion See ADResetGesture
 */
@property (nonatomic) ADResetGesture resetGestures;

/**
 * @abstract Determines whether the leftViewController is visible
 * @return
 *		YES if the leftViewController is visible
 */
- (BOOL)leftViewShowing;
/**
 * @abstract Determines whether the rightViewController is visible
 * @return
 *		YES if the rightViewController is visible
 */
- (BOOL)rightViewShowing;

/**
 * @abstract Anchor the top view to a given side.
 * @param side
 *		The side you wish to anchor to
 */
- (void)anchorTopViewTo:(ADAnchorSide)side;
/**
 * @abstract Anchor the top view to a given side.
 * @param side
 *		The side you wish to anchor to
 * @param animated
 *		Whether or not to animate the movement.
 */
- (void)anchorTopViewTo:(ADAnchorSide)side animated:(BOOL)animated;
/**
 * @abstract Anchor the top view to a given side.
 * @param side
 *		The side you wish to anchor to
 * @param animated
 *		Whether or not to animate the movement.
 * @param animations
 *		A block which is run inside the animation block. Any view
 * manipulation that causes implicit animations performed using UIView
 * animation. Can be NULL.
 * @param completion
 *		A block to run on completion. Can be NULL.
 */
- (void)anchorTopViewTo:(ADAnchorSide)side animated:(BOOL)animated animations:(void (^)())animations completion:(void(^)())completion;

/**
 * @abstract Enable or disable logging.
 * @discussion Logs are created using NSLog(), and are only performed in DEBUG
 * mode.
 * @param enabled
 *		Pass NO to disable logs.
 */
+ (void)setLoggingEnabled:(BOOL)enabled;
/**
 * @abstract Check if logging is enabled.
 * @return
 *		YES if logging is enabled.
 */
+ (BOOL)isLoggingEnabled;

@end

@interface UIViewController (ADSlidingViewController)
- (ADSlidingViewController *)slidingViewController;
@end