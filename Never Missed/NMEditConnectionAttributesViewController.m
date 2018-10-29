//
//  NMConnectionAttributesViewController.m
//  Never Missed
//
//  Created by William Emmanuel on 9/29/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMEditConnectionAttributesViewController.h"
#import "MBProgressHUD.h"

@interface NMEditConnectionAttributesViewController () <UIAlertViewDelegate>

@end

@implementation NMEditConnectionAttributesViewController {
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
    // Do any additional setup after loading the view.continue
    
    _dismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapToDismissKeyboard)];
    [self.view addGestureRecognizer:_dismissKeyboard];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = label;
    label.text = @"Edit Connection";
    [label sizeToFit];
    
    
    _hairColorPicker = [[UIPickerView alloc] init];
    _hairLengthPicker = [[UIPickerView alloc] init];
    _clothingPicker = [[UIPickerView alloc] init];
    _heightPicker = [[UIPickerView alloc] init];
    
    _heightPicker.delegate = self;
    _hairColorPicker.delegate = self;
    _hairLengthPicker.delegate = self;
    _clothingPicker.delegate = self;
    
    _hairColorPicker.dataSource = self;
    _hairLengthPicker.dataSource = self;
    _clothingPicker.dataSource = self;
    _heightPicker.dataSource = self;
    
    _heightPicker.showsSelectionIndicator = YES;
    _clothingPicker.showsSelectionIndicator = YES;
    _hairLengthPicker.showsSelectionIndicator = YES;
    _hairColorPicker.showsSelectionIndicator = YES;
    
    _hairLength.inputView = _hairLengthPicker;
    _hairColor.inputView = _hairColorPicker;
    _clothingColor.inputView = _clothingPicker;
    _height.inputView = _heightPicker;
    
    int feet = self.connection.heightInInches/12;
    int inches = self.connection.heightInInches%12;
    NSString *heightString = [NSString stringWithFormat:@" %d'%d''", feet, inches];
    
    [_heightPicker selectRow:feet inComponent:0 animated:NO];
    [_heightPicker selectRow:inches inComponent:1 animated:NO];
    
    
    _height.text = heightString;
    _hairColor.text = _connection.hairColor;
    _hairLength.text = _connection.hairLength;
    _clothingColor.text = _connection.clothingColor;
    
    _patterned.on = _connection.patterned;
    _hat.on = _connection.hat;
    _publicConnection.on = _connection.publicConnection;

    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"pickerData" ofType:@"plist"];
    _pickerData = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if(pickerView == _clothingPicker) {
        return [[_pickerData objectForKey:@"clothingColors"] count];
    } else if(pickerView == _hairLengthPicker) {
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
    if(pickerView == _clothingPicker) {
        return [[_pickerData objectForKey:@"clothingColors"] objectAtIndex:row]; ;
    } else if(pickerView == _hairLengthPicker) {
        return [[_pickerData objectForKey:@"hairLengths"] objectAtIndex:row];
    } else if(pickerView == _hairColorPicker){
        return [[_pickerData objectForKey:@"hairColors"] objectAtIndex:row];
    } else {
        if(component == 0) {
            return [NSString stringWithFormat:@"%i'", (int)row+4];
        } else {
            return [NSString stringWithFormat:@"%i''", (int)row];
        }
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(pickerView == _clothingPicker) {
        _clothingColor.text = [[_pickerData objectForKey:@"clothingColors"] objectAtIndex:row];
        [_clothingColor resignFirstResponder];
    } else if(pickerView == _hairLengthPicker) {
        _hairLength.text = [[_pickerData objectForKey:@"hairLengths"] objectAtIndex:row];
        [_hairLength resignFirstResponder];
    } else if(pickerView == _hairColorPicker){
        _hairColor.text = [[_pickerData objectForKey:@"hairColors"] objectAtIndex:row];
        [_hairColor resignFirstResponder];
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
    } else if (sender == _clothingPicker) {
        [_clothingColor resignFirstResponder];
    } else {
        [_height resignFirstResponder];
    }
}

- (IBAction)saveBtnPressed:(id)sender {
    if([_height.text length] == 0 || [_hairColor.text length] == 0 || [_hairColor.text length] == 0 || [_clothingColor.text length] == 0)
        return [self incompleteInfoSubmitted];
    
    int feet = (int)[_heightPicker selectedRowInComponent:0] + 4;
    int inches = (int)[_heightPicker selectedRowInComponent:1];
    int totalInches = feet * 12 + inches;
    
    _connection.pfobject[@"heightInInches"] = @(totalInches);

    _connection.pfobject[@"clothingColor"] = _clothingColor.text;
    _connection.pfobject[@"hairLength"] = _hairLength.text;
    _connection.pfobject[@"hairColor"] = _hairColor.text;
    if(_patterned.isOn){
    _connection.pfobject[@"patterned"] = @YES;
    }
    else _connection.pfobject[@"patterned"] = @NO;
    if(_hat.isOn){
        _connection.pfobject[@"hat"] = @YES;
    }
    else _connection.pfobject[@"hat"] = @NO;
    if(_publicConnection.isOn){
        _connection.pfobject[@"public"] = @YES;
    }
    else _connection.pfobject[@"public"] = @NO;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    hud.labelText = @"Loading";
    hud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0];
    [_connection.pfobject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    
}
- (IBAction)deleteBtnPressed:(id)sender {
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Warning"
                                                     message:@"You are about to delete this connection, are you sure you wish to remove it?"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles: @"Delete", nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button Index =%ld",(long)buttonIndex);
    if (buttonIndex == 0)
    {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
    else if(buttonIndex == 1)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
        hud.labelText = @"Loading";
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0];
        [_connection.pfobject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
             [self.navigationController popViewControllerAnimated:YES];
        }];
        [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }
}

@end
