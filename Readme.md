# ADSlidingViewController #

## Features ##

- Easy use!
- Universal – iPhone & iPad, including 4 inch screens
- Utilises Child View Controllers – Supports UINavigationControllers, etc.
- Correct physics – tracks your finger and calculates the animation properly
- Peek or Reveal modes
- Resize or Slide Top view – Note that the animations for shadows and navigation bars don't work properly with resizing.
- Under view controllers can slide with top view or be static underneath
- Can force one side to always be shown in Landscape or both orientations

## Requirements ##

- Objective-C ARC
- Xcode 4.4 or above
- iOS 5 or above

## Installation ##

Once you have got the source, you can install the component in two ways.

### As a dependency ###

1. Drag the ADSlidingViewController.xcodeproj file into your xcode project. *Make sure that it is not open in another window*
2. Click on the project settings and navigate to the target you wish to install for. Click build phases. Add ADSlidingViewController to your 'Target Dependencies'.
3. Add the following to 'Link Binary With Libraries': (If not already)
	- libADSlidingViewController
	- QuartzCore
4. Go to the 'Build Setting' tab. Add '-ObjC' and '-all_load' to 'Other Linker Flags'
5. Add the repository's file directory to 'User Header Search Paths'


### Import the files ###

1. Drag ADSlidingViewController.h and .m into your project.
2. Add QuartzCore to 'Link Binary With Libraries' in your target's 'Build Phases' (If not already)
3. If you're not using ARC, add -f-objc-arc to ADSlidingViewController.m's compiler flags. (In 'Build Phases' -> 'Compile Sources'

## Using ADSlidingViewController ##

1. Create an instance of an ADSlidingViewController (can be a subclass if you wish), from a XIB, Storyboard or just using initWithFrame
2. Set the main/left/right view controllers. Note that the left/right views are not both required.
3. Customise the component to your liking, and add the pan gesture to whichever view you wish.
4. Make sure the component is added to the screen

For sample code, check out the demo, included with the repository
