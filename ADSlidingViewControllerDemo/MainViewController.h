//
//  MainViewController.h
//  ADSlidingViewControllerDemo
//
//  Created by Adam Debono on 2/08/12.
//  Copyright (c) 2012 Adam Debono. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIStepper *leftAnchorAmountStepper;
@property (strong, nonatomic) IBOutlet UIStepper *rightAnchorAmountStepper;
@property (strong, nonatomic) IBOutlet UILabel *leftAnchorAmountLabel;
@property (strong, nonatomic) IBOutlet UILabel *rightAnchorAmountLabel;

@property (strong, nonatomic) IBOutlet UISegmentedControl *leftAnchorWidthType;
@property (strong, nonatomic) IBOutlet UISegmentedControl *rightAnchorWidthType;

@property (strong, nonatomic) IBOutlet UISegmentedControl *leftAnchorLayoutType;
@property (strong, nonatomic) IBOutlet UISegmentedControl *rightAnchorLayoutType;

@property (strong, nonatomic) IBOutlet UISegmentedControl *leftSecondaryLayoutType;
@property (strong, nonatomic) IBOutlet UISegmentedControl *rightSecondaryLayoutType;

@property (strong, nonatomic) IBOutlet UISegmentedControl *undersidePersistencyControl;


- (IBAction)leftBarButton:(UIBarButtonItem *)sender;
- (IBAction)rightBarButton:(UIBarButtonItem *)sender;
- (IBAction)updatePressed:(UIButton *)sender;

- (IBAction)leftAnchorValueChanged:(UIStepper *)sender;
- (IBAction)rightAnchorValueChanged:(UIStepper *)sender;
@end
