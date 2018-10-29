//
//  NMConnetionYourAttributesViewController.h
//  Never Missed
//
//  Created by William Emmanuel on 9/30/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "NMConnection.h"

@interface NMConnectionYourAttributesViewController : UIViewController <UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *myShoeHeight;

@property (weak, nonatomic) IBOutlet UITextField *myClothingColor;
@property (weak, nonatomic) IBOutlet UISwitch *myPattern;
@property (weak, nonatomic) IBOutlet UISwitch *myHat;

@property (strong, nonatomic) NMConnection *connection;

@property (strong, nonatomic) UIPickerView *clothingPicker;
@property (strong, nonatomic) UIPickerView *shoeHeightPicker;

@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) NSMutableDictionary *pickerData;



@end
