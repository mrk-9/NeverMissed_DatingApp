//
//  NMEditConnectionAttributesViewController.h
//  Never Missed
//
//  Created by William Emmanuel on 9/29/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMConnection.h"

@interface NMEditConnectionAttributesViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

- (IBAction)saveBtnPressed:(id)sender;
@property (nonatomic, strong) NMConnection* connection;
- (IBAction)deleteBtnPressed:(id)sender;


@property (weak, nonatomic) IBOutlet UITextField *height;
@property (weak, nonatomic) IBOutlet UITextField *hairColor;
@property (weak, nonatomic) IBOutlet UITextField *hairLength;
@property (weak, nonatomic) IBOutlet UITextField *clothingColor;
@property (weak, nonatomic) IBOutlet UISwitch *patterned;
@property (weak, nonatomic) IBOutlet UISwitch *hat;
@property (weak, nonatomic) IBOutlet UISwitch *publicConnection;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (strong, nonatomic) UIPickerView *hairColorPicker;
@property (strong, nonatomic) UIPickerView *hairLengthPicker;
@property (strong, nonatomic) UIPickerView *clothingPicker;
@property (strong, nonatomic) UIPickerView *heightPicker;

@property (strong, nonatomic) NSMutableDictionary *pickerData;

@end
