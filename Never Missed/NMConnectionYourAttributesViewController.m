//
//  NMConnetionYourAttributesViewController.m
//  Never Missed
//
//  Created by William Emmanuel on 9/30/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMConnectionYourAttributesViewController.h"

@interface NMConnectionYourAttributesViewController ()

@end

@implementation NMConnectionYourAttributesViewController {
    UITapGestureRecognizer *_dismissKeyboard;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_continueButton addTarget:self action:@selector(didTapContinue) forControlEvents:UIControlEventTouchUpInside];
    _dismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapToDismissKeyboard)];
    [self.view addGestureRecognizer:_dismissKeyboard];
    
    _clothingPicker = [[UIPickerView alloc] init];
    _clothingPicker.delegate = self;
    _clothingPicker.dataSource = self;
    _clothingPicker.showsSelectionIndicator = YES;
    _myClothingColor.inputView = _clothingPicker;
    
    _shoeHeightPicker = [[UIPickerView alloc] init];
    _shoeHeightPicker.delegate = self;
    _shoeHeightPicker.dataSource = self;
    _shoeHeightPicker.showsSelectionIndicator = YES;
    _myShoeHeight.inputView = _shoeHeightPicker;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"pickerData" ofType:@"plist"];
    _pickerData = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didTapContinue {
    if([_myClothingColor.text length] == 0) {
        return [self incompleteInfoSubmitted];
    }
    if([_myShoeHeight.text length] == 0) {
        return [self incompleteInfoSubmitted];
    }
    _connection.myClothingColor = _myClothingColor.text;
    _connection.postedBy = [PFUser currentUser];
    
    if(_myPattern.isOn){
        _connection.myPatterned = YES;
    }
    else {
        _connection.myPatterned = NO;
    }
    if(_myHat.isOn){
        _connection.myHat = YES;
    }
    else _connection.myHat = NO;
    _connection.publicConnection = NO;
    _connection.myShoeHeight = [_myShoeHeight.text intValue];

    NSLog(@"Saving Eventually hat = %@",_connection.hat ? @"YES" : @"NO");
    //[_connection saveToParseEventuallyWithTarget:self andSelector:@selector(justSaved:error:)];

    [_connection saveToParseEventually];
    [self justSaved];
}

-(void) incompleteInfoSubmitted {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete info" message:@"Incomplete information submitted. Please enter connection info again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

//-(void)justSaved:(NSNumber *)result error:(NSError *)error {
-(void)justSaved{
   // if (error != nil) {
        // error checking
   // }
    UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Connection is saving" message:@"The connection is saving. You will be notified if a match is present. You can update the connection under the Pending section of the your messages after it has been saved." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    // Call the query function. Will either be a geo query or otherwise based on connection type
    [saveAlert show];
}

-(void) didTapToDismissKeyboard {
    [self.view endEditing:YES];
    [self resignFirstResponder];
}

# pragma mark - UIAlertViewDelegate methods

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [_connection searchForMatches];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

# pragma mark - UIPickerView methods

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(pickerView == _clothingPicker) {
        return [[_pickerData objectForKey:@"clothingColors"] count];
    }
    else if(pickerView == _shoeHeightPicker){
        return [[_pickerData objectForKey:@"shoeHeight"] count];
    }
    else {
        return 0;
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(pickerView == _clothingPicker) {
        return [[_pickerData objectForKey:@"clothingColors"] objectAtIndex:row];
    }
    else if(pickerView == _shoeHeightPicker){
        return [[_pickerData objectForKey:@"shoeHeight"] objectAtIndex:row];
    }
    else {
        return nil;
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(pickerView == _clothingPicker) {
        _myClothingColor.text = [[_pickerData objectForKey:@"clothingColors"] objectAtIndex:row];
        [_myClothingColor resignFirstResponder];
    }
    else if(pickerView == _shoeHeightPicker){
        _myShoeHeight.text = [[_pickerData objectForKey:@"shoeHeight"] objectAtIndex:row];
        [_myShoeHeight resignFirstResponder];
    }
}

@end
