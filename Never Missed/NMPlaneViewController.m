//
//  NMPlaneViewController.m
//  Never Missed
//
//  Created by William Emmanuel on 10/6/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMPlaneViewController.h"
#import "NMPlaneConnection.h"
#import "NMConnectionAttributesViewController.h"

@interface NMPlaneViewController ()

@end

@implementation NMPlaneViewController {
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
    _carrierPicker = [[UIPickerView alloc] init];
    _carrierField.inputView = _carrierPicker;
    _carrierPicker.dataSource = self;
    _carrierPicker.delegate = self;
    
    [_flightNoField setKeyboardType:UIKeyboardTypeNumberPad];
    
    // load data from plist
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"pickerData" ofType:@"plist"];
    NSDictionary *pickerData = [[NSDictionary alloc] initWithContentsOfFile:path];
    _carriers = [pickerData objectForKey:@"carriers"];
}

-(void)didTapContinue {
    if([_carrierField.text length] == 0 || [_flightNoField.text length] == 0) {
        return [self incompleteInfoSubmitted];
    }
    NMPlaneConnection *connection = [[NMPlaneConnection alloc] init];
    connection.postedBy = [PFUser currentUser];
    connection.carrier = _carrierField.text;
    connection.flightNo = _flightNoField.text.intValue;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NMConnectionAttributesViewController *myVC = (NMConnectionAttributesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ConnectionAttributesViewController"];
    myVC.connection = connection;
    [self.navigationController pushViewController:myVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) didTapToDismissKeyboard {
    [self.view endEditing:YES];
    [self resignFirstResponder]; 
}

-(void) incompleteInfoSubmitted {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete info" message:@"Incomplete information submitted. Please enter connection info again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

# pragma mark - UIPickerView Methods

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_carriers count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [_carriers objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _carrierField.text = [_carriers objectAtIndex:row];
    //[_carrierField resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}
@end
