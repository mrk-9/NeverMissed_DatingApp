//
//  NMFirstRunSettingsViewController.m
//  NeverMissed
//
//  Created by Tom Mignone on 1/2/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//


#import "NMFirstRunSettingsViewController.h"
#import <Parse/Parse.h>
#import "NMPickConnectionTypeViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "NMAppDelegate.h"
#import "DeviceHelper.h"
#import "AFHTTPRequestOperationManager.h"
@interface NMFirstRunSettingsViewController () {
    NSDictionary *_userData;
    NSString *_name;
    NSURL *_pictureURL;
    NSString *_facebookID;
    NSMutableDictionary *dictRegister;
   
}

@end

@implementation NMFirstRunSettingsViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
   // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    _dismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapToDismissKeyboard)];
    [self.view addGestureRecognizer:_dismissKeyboard];
    
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
    dictRegister = [[NSMutableDictionary alloc] init];
    
    NMAppDelegate *app = (NMAppDelegate *)[UIApplication sharedApplication].delegate;
    if (app.deviceToken.length > 0)
    {
        [dictRegister setObject:app.deviceToken forKey:@"devicetoken"];
    }
    else{
         [dictRegister setObject:@" " forKey:@"devicetoken"];
    }
    [dictRegister setObject :app.fbToken forKey:@"fbtoken"];
    [dictRegister setObject:[DeviceHelper deviceName] forKey:@"devicetype"];
}

- (void)didReceiveMemoryWarning {
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


- (IBAction)saveWasPressed:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    if([_gender selectedSegmentIndex] == 0)
    {
        [currentUser setObject:@"male" forKey:@"gender"];
        [dictRegister setObject:@"male" forKey:@"gender"];
    }
    else
    {
        [currentUser setObject:@"female" forKey: @"gender"];
        [dictRegister setObject:@"female" forKey:@"gender"];
    }
    if([_interested selectedSegmentIndex] == 0)
    {
        [currentUser setObject:@"male" forKey:@"interestedIn"];
        [dictRegister setObject:@"male" forKey:@"interestedIn".lowercaseString];
    }
    else
    {
        [currentUser setObject:@"female" forKey: @"interestedIn"];
        [dictRegister setObject:@"female" forKey:@"interestedIn".lowercaseString];
    }
    
    if([_height.text length] == 0 || [_hairColor.text length] == 0 || [_hairColor.text length] == 0 )
        return [self incompleteInfoSubmitted];
    
    long feet = [_heightPicker selectedRowInComponent:0] + 4;
    long inches = [_heightPicker selectedRowInComponent:1];
    long totalInches = feet * 12 + inches;
    
    [currentUser setObject:@(totalInches) forKey:@"heightInInches"];
    [currentUser setObject:_hairLength.text forKey:@"hairLength"];
    [currentUser setObject:_hairColor.text forKey:@"hairColor"];
    
    [dictRegister setObject:@(totalInches) forKey:@"heightInInches".lowercaseString];
    [dictRegister setObject:_hairLength.text forKey:@"hairLength".lowercaseString];
    [dictRegister setObject:_hairColor.text forKey:@"hairColor".lowercaseString];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:@"name,education,likes.limit(100)" forKey:@"fields"];
    FBSDKGraphRequest* request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:params];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            _userData = (NSDictionary *)result;
            NSLog(@"_userData:%@",_userData);
            _facebookID = _userData[@"id"];
            // just get the first name
            NSArray *names = [_userData[@"name"] componentsSeparatedByString:@" "];
            
            NSString *school = @"";
            for (NSDictionary *item in _userData[@"education"]) {
                if ([item[@"type"] isEqualToString:@"College"]) {
                    school = item[@"school"][@"name"];
                }
            }
            if ([school isEqualToString:@""]) {
                for (NSDictionary *item in _userData[@"education"]) {
                    if ([item[@"type"] isEqualToString:@"High School"]) {
                        school = item[@"school"][@"name"];
                    }
                }
            }
            if ([school isEqualToString:@""]) {
                school = @"No school data";
            }
            
            _name = [names firstObject];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:_name forKey:@"name"];
            [defaults synchronize];
            [dictRegister setObject:_name forKey:@"name"];
             [dictRegister setObject:school forKey:@"school"];
            [dictRegister setObject:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", _facebookID] forKey:@"photo"];
            
            _pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", _facebookID]];
            
            NSData * data = [NSData dataWithContentsOfURL:_pictureURL];
            PFFile *imageFile = [PFFile fileWithName:@"profilePic.jpg" data:data];
            
            PFUser *currentUser = [PFUser currentUser];
            PFQuery *query = [PFUser query];
            
            [currentUser setObject:school forKey:@"school"];
            
            NSMutableArray* likes = [[NSMutableArray alloc] init];
            if([_userData objectForKey:@"likes"] != nil){
                NSArray* userLikes = [[_userData objectForKey:@"likes"] objectForKey:@"data"];
                if(userLikes != nil){
                    for(NSDictionary* like in userLikes){
                        NSString* likeID = [like objectForKey:@"id"];
                        NSString* likeName = [like objectForKey:@"name"];
                        [likes addObject:[NSDictionary dictionaryWithObjectsAndKeys:likeID,@"likeID",likeName,@"likeName",nil]];
                    }
                }
            }
            
            [currentUser setObject:likes forKey:@"userLikes"];
             [dictRegister setObject:likes forKey:@"userLikes".lowercaseString];
            [self callAPIRegisterUser];
            [currentUser saveInBackground];
            
            [query getObjectInBackgroundWithId:currentUser.objectId block:^(PFObject *foundUser, NSError *error) {
                if(!error){
                    foundUser[@"name"] = _name;
                    foundUser[@"profilePicture"] = imageFile;
                    [foundUser saveInBackground];
                }
            }];
        }
    }];
    
    
    [currentUser saveInBackgroundWithTarget:self selector:@selector(justSaved)];
    
    /*
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    NMPickConnectionTypeViewController *connections = (NMPickConnectionTypeViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"NeverMissedHomeScreen"];*/
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    
    //    [(UINavigationController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController] popToRootViewControllerAnimated:YES];
}


- (void)callAPIRegisterUser
{
    NSLog(@"DICT -->%@",dictRegister);
    NSString *url = @"https://never-missed-dev.herokuapp.com/api/register";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:url parameters:dictRegister success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"responseObject --->%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation.responseString);
        NSLog(@"Error: %@", error);
    }];
}
-(void) justSaved {
    UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Attributes saved" message:@"Your attributes were saved. Welcome to Never Missed, you can now begin posting new connections! You can change your attributes at any time by going to the settings page." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [saveAlert show];
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
    } else if(pickerView == _hairColorPicker){
        _hairColor.text = [[_pickerData objectForKey:@"hairColors"] objectAtIndex:row];
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


@end
