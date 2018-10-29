//
//  NMFirstRunSettingsViewController.h
//  NeverMissed
//
//  Created by Tom Mignone on 1/2/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NMFirstRunSettingsViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIScrollViewDelegate, UITextFieldDelegate>



@property (weak, nonatomic) IBOutlet UISegmentedControl *gender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *interested;
@property (weak, nonatomic) IBOutlet UITextField *hairColor;
@property (weak, nonatomic) IBOutlet UITextField *hairLength;
@property (weak, nonatomic) IBOutlet UITextField *height;

@property (strong, nonatomic) UIPickerView *hairColorPicker;
@property (strong, nonatomic) UIPickerView *hairLengthPicker;
@property (strong, nonatomic) UIPickerView *heightPicker;
@property (nonatomic,retain)  NSString *facebookToken;
@property (strong, nonatomic) NSMutableDictionary *pickerData;

@property (strong, nonatomic) UITapGestureRecognizer *dismissKeyboard;
- (IBAction)saveWasPressed:(id)sender;



@end
