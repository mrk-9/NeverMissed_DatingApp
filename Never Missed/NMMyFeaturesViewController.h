//
//  NMMyFeaturesViewController.h
//  Never Missed
//
//  Created by William Emmanuel on 11/11/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface NMMyFeaturesViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *gender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *interested;
@property (weak, nonatomic) IBOutlet UITextField *hairColor;
@property (weak, nonatomic) IBOutlet UITextField *hairLength;
@property (weak, nonatomic) IBOutlet UITextField *height;

@property (strong, nonatomic) UIPickerView *hairColorPicker;
@property (strong, nonatomic) UIPickerView *hairLengthPicker;
@property (strong, nonatomic) UIPickerView *heightPicker;

@property (strong, nonatomic) NSMutableDictionary *pickerData;

@property (strong, nonatomic) UITapGestureRecognizer *dismissKeyboard;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;


@end
