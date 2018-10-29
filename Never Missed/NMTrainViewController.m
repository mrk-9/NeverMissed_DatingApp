//
//  NMTrainViewController.m
//  Never Missed
//
//  Created by William Emmanuel on 10/6/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMTrainViewController.h"
#import "NMTrainConnection.h"
#import "NMConnectionAttributesViewController.h"

@interface NMTrainViewController ()


@end

@implementation NMTrainViewController {
    UITapGestureRecognizer *_dismissKeyboard;
    NSString *currentRailway;
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
    currentRailway = @"";
    [_continueButton addTarget:self action:@selector(didTapContinue) forControlEvents:UIControlEventTouchUpInside];
    _dismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapToDismissKeyboard)];
    [self.view addGestureRecognizer:_dismissKeyboard];
    _railwayPicker = [[UIPickerView alloc] init];
    _railwayField.inputView = _railwayPicker;
    _railwayPicker.dataSource = self;
    _railwayPicker.delegate = self;
    
    
    _routePicker = [[UIPickerView alloc] init];
    _trainNoField.inputView = _routePicker;
    _routePicker.dataSource = self;
    _routePicker.delegate = self;
    
    [_trainNoField setKeyboardType:UIKeyboardTypeNumberPad];
    
    // load data from plist
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"pickerData" ofType:@"plist"];
    NSDictionary *pickerData = [[NSDictionary alloc] initWithContentsOfFile:path];
    _railways = [pickerData objectForKey:@"railways"];
}

-(void)didTapContinue {
    if([_railwayField.text length] == 0 || [_railwayField.text length] == 0) {
        return [self incompleteInfoSubmitted];
    }
    NMTrainConnection *connection = [[NMTrainConnection alloc] init];
    connection.postedBy = [PFUser currentUser];
    connection.railway = _railwayField.text;
    connection.trainNo = _trainNoField.text;
    
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
    if(pickerView == _routePicker){
        return [_routes count];
    }
    return [_railways count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(pickerView == _routePicker){

        return [_routes objectAtIndex:row];
    }

    return [_railways objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(pickerView == _routePicker){
        _trainNoField.text = [_routes objectAtIndex:row];
        
    }
    else{
        _railwayField.text = [_railways objectAtIndex:row];
        //reload the routes array based on the selection
        if([_railwayField.text isEqualToString:@""]){
            [_trainNoField setKeyboardType:UIKeyboardTypeNumberPad];
            _trainNoField.inputView = NULL;
        }
        else if([_railwayField.text isEqualToString:@"Amtrak"]){
            [_trainNoField setKeyboardType:UIKeyboardTypeNumberPad];
            _trainNoField.inputView = NULL;
        }
        else{
            _trainNoField.inputView = _routePicker;
            NSString *path = [[NSBundle mainBundle] pathForResource:
                              @"pickerData" ofType:@"plist"];
            NSDictionary *pickerData = [[NSDictionary alloc] initWithContentsOfFile:path];
           
            _routes = [pickerData objectForKey:_railwayField.text];
        }
        [_routePicker reloadAllComponents];
    }
    //[_railwayField resignFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}
@end
