//
//  NMTrainViewController.h
//  Never Missed
//
//  Created by William Emmanuel on 10/6/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NMTrainViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *railwayField;
@property (weak, nonatomic) IBOutlet UITextField *trainNoField;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) UIPickerView *railwayPicker;
@property (strong, nonatomic) UIPickerView *routePicker;
@property (strong, nonatomic) NSMutableArray *railways;
@property (strong, nonatomic) NSMutableArray *routes;



@end
