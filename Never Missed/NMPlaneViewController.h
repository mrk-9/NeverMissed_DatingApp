//
//  NMPlaneViewController.h
//  Never Missed
//
//  Created by William Emmanuel on 10/6/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NMPlaneViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *carrierField;
@property (weak, nonatomic) IBOutlet UITextField *flightNoField;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) UIPickerView *carrierPicker;
@property (strong, nonatomic) NSMutableArray *carriers;

@end
