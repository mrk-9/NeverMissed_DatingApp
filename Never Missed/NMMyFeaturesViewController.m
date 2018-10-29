//
//  NMMyFeaturesViewController.m
//  Never Missed
//
//  Created by William Emmanuel on 11/11/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMMyFeaturesViewController.h"

@interface NMMyFeaturesViewController ()

@end

@implementation NMMyFeaturesViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    
    _dismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapToDismissKeyboard)];
    [self.view addGestureRecognizer:_dismissKeyboard];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor]; // change this color
    self.navigationItem.titleView = label;
    label.text = @"My Features";
    [label sizeToFit];
    
    _hairColorPicker = [[UIPickerView alloc] init];
    _hairLengthPicker = [[UIPickerView alloc] init];
    _heightPicker = [[UIPickerView alloc] init];
    
    _heightPicker.delegate = self;
    _hairColorPicker.delegate = self;
    _hairLengthPicker.delegate = self;
    
    _hairColorPicker.dataSource = self;
    _hairLengthPicker.dataSource = self;
    _heightPicker.dataSource = self;
    
    _heightPicker.showsSelectionIndicator = YES;
    _hairLengthPicker.showsSelectionIndicator = YES;
    _hairColorPicker.showsSelectionIndicator = YES;
    
    _hairLength.inputView = _hairLengthPicker;
    _hairColor.inputView = _hairColorPicker;
    _height.inputView = _heightPicker;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"pickerData" ofType:@"plist"];
    _pickerData = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    PFUser *current = [PFUser currentUser];
    if([[current objectForKey:@"interestedIn"] isEqualToString:@"male"]) {
        NSLog(@"You are interested in males");
        [_interested setSelectedSegmentIndex:0];
    } else {
        NSLog(@"You are interested in females");
        [_interested setSelectedSegmentIndex:1];
    }
    if([[current objectForKey:@"gender"] isEqualToString:@"male"]) {
        NSLog(@"You are are a male");
        [_gender setSelectedSegmentIndex:0];
    } else if ([[current objectForKey:@"gender"] isEqualToString:@"female"]) {
        NSLog(@"You are are a female");
        [_gender setSelectedSegmentIndex:1];
    }
    
    _hairColor.text = [current objectForKey:@"hairColor"];
    //[_hairColorPicker selectRow:[[_pickerData objectForKey:@"hairColors"] indexOfObject:_hairColor.text] inComponent:0 animated:NO];
    _hairLength.text = [current objectForKey:@"hairLength"];
    //[_hairLengthPicker selectRow:[[_pickerData objectForKey:@"hairLengths"] indexOfObject:_hairLength.text] inComponent:0 animated:NO];
    int heightInInches = [[current objectForKey:@"heightInInches"] intValue];
    if(heightInInches > 0) {
        int feet = heightInInches / 12;
        int inches = heightInInches % 12;
        _height.text = [NSString stringWithFormat:@"%i' %i''", feet, inches];
        [_heightPicker selectRow:feet-4 inComponent:0 animated:NO];
        [_heightPicker selectRow:inches inComponent:1 animated:NO];
    }
    //_saveButton.target = self;
    //_saveButton.action = @selector(saveWasPressed:);
    _backButton.target = self;
    _backButton.action = @selector(backButtonPressed);
}

-(void)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)saveWasPressed:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    if([_gender selectedSegmentIndex] == 0)
        [currentUser setObject:@"male" forKey:@"gender"];
    else
        [currentUser setObject:@"female" forKey: @"gender"];
    
    if([_interested selectedSegmentIndex] == 0)
        [currentUser setObject:@"male" forKey:@"interestedIn"];
    else
        [currentUser setObject:@"female" forKey: @"interestedIn"];
    
    if([_height.text length] == 0 || [_hairColor.text length] == 0 || [_hairColor.text length] == 0 )
        return [self incompleteInfoSubmitted];
    
    long feet = [_heightPicker selectedRowInComponent:0] + 4;
    long inches = [_heightPicker selectedRowInComponent:1];
    long totalInches = feet * 12 + inches;
    
    [currentUser setObject:@(totalInches) forKey:@"heightInInches"];
    [currentUser setObject:_hairLength.text forKey:@"hairLength"];
    [currentUser setObject:_hairColor.text forKey:@"hairColor"];
    
    [currentUser saveInBackgroundWithTarget:self selector:@selector(justSaved)];
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void) incompleteInfoSubmitted {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete info" message:@"Incomplete information submitted. Please enter connection info again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void) didTapToDismissKeyboard {
    [self.view endEditing:YES];
    [self resignFirstResponder];
}

# pragma mark - UIPickerView Methods

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(pickerView == _hairLengthPicker) {
        return [[_pickerData objectForKey:@"hairLengths"] count];
    } else if(pickerView == _hairColorPicker){
        return [[_pickerData objectForKey:@"hairColors"] count];
    } else {
        if(component == 0) {
            return 4;
        } else {
            return 12;
        }
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if(pickerView == _heightPicker) return 2;
    return  1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(pickerView == _hairLengthPicker) {
        return [[_pickerData objectForKey:@"hairLengths"] objectAtIndex:row];
    } else if(pickerView == _hairColorPicker){
        return [[_pickerData objectForKey:@"hairColors"] objectAtIndex:row];
    } else {
        if(component == 0) {
            return [NSString stringWithFormat:@"%i'", row+4];
        } else {
            return [NSString stringWithFormat:@"%li''", (long)row];
        }
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(pickerView == _hairLengthPicker) {
        _hairLength.text = [[_pickerData objectForKey:@"hairLengths"] objectAtIndex:row];
       // [_hairLength resignFirstResponder];
    } else if(pickerView == _hairColorPicker){
        _hairColor.text = [[_pickerData objectForKey:@"hairColors"] objectAtIndex:row];
       // [_hairColor resignFirstResponder];
    } else {
        long feet = [_heightPicker selectedRowInComponent:0] + 4;
        long inches = [_heightPicker selectedRowInComponent:1];
        _height.text = [NSString stringWithFormat:@"%ld' %ld''", feet, inches];
    }
}

-(void)donePicking:(id)sender
{
    if( sender==_hairLengthPicker ) {
        [_hairLength resignFirstResponder];
    } else if (sender == _hairColorPicker) {
        [_hairColor resignFirstResponder];
    } else {
        [_height resignFirstResponder];
    }
}

-(void) justSaved {
    UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Attributes saved" message:@"Your attributes were saved." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [saveAlert show];
}



@end
