//
//  NMConnectionAttributesViewController.m
//  Never Missed
//
//  Created by William Emmanuel on 9/29/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMConnectionAttributesViewController.h"
#import "NMConnectionYourAttributesViewController.h"

@interface NMConnectionAttributesViewController ()

@end

@implementation NMConnectionAttributesViewController {
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
    
	// Do any additional setup after loading the view.
    [_continueButton addTarget:self action:@selector(didPressContinue) forControlEvents:UIControlEventTouchUpInside];
    _dismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapToDismissKeyboard)];
    [self.view addGestureRecognizer:_dismissKeyboard];
    
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
    
    _hat.on = NO;
    _patterned.on = NO;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"pickerData" ofType:@"plist"];
    _pickerData = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didPressContinue {
    if([_height.text length] == 0 || [_hairColor.text length] == 0 || [_hairColor.text length] == 0 || [_clothingColor.text length] == 0)
        return [self incompleteInfoSubmitted];
    
    int feet = (int)[_heightPicker selectedRowInComponent:0] + 4;
    int inches = (int)[_heightPicker selectedRowInComponent:1];
    int totalInches = feet * 12 + inches;
    
    _connection.heightInInches = totalInches;
    
    _connection.clothingColor = _clothingColor.text;
    _connection.hairLength = _hairLength.text;
    _connection.hairColor = _hairColor.text;
    
    if(_patterned.isOn){
        NSLog(@"BLah Blah On");
        _connection.patterned = YES;
    }
    else {
        NSLog(@"BLah Blah OFF");
        _connection.patterned = NO;
    }
    if(_hat.isOn){
        _connection.hat = YES;
    }
    else _connection.hat = NO;
    
    //_connection.patterned = _patterned.isOn;
    //_connection.hat = _hat.isOn;
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NMConnectionYourAttributesViewController *myVC = (NMConnectionYourAttributesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ConnectionYourAttributesViewController"];
    myVC.connection = _connection;
    [self.navigationController pushViewController:myVC animated:YES];
    
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
        //[_clothingColor resignFirstResponder];
    } else if(pickerView == _hairLengthPicker) {
        _hairLength.text = [[_pickerData objectForKey:@"hairLengths"] objectAtIndex:row];
       // [_hairLength resignFirstResponder];
    } else if(pickerView == _hairColorPicker){
        _hairColor.text = [[_pickerData objectForKey:@"hairColors"] objectAtIndex:row];
        //[_hairColor resignFirstResponder];
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end
