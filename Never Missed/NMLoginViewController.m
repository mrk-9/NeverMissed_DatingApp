//
//  NMLoginViewController.m
//  NeverMissed
//
//  Created by Tom Mignone on 11/29/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "NMLoginViewController.h"
#import "NMSettingsViewController.h"
#import "NMPickConnectionTypeViewController.h"
#import "NMFirstRunSettingsViewController.h"
#import "NMAppDelegate.h"
@interface NMLoginViewController ()
{
    NSString *fbToken;
}
@end

@implementation NMLoginViewController

- (void)viewDidLoad {
   
    [super viewDidLoad];
/*    [self setNeedsStatusBarAppearanceUpdate];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 0.0f/255.0f
                                                                           green:81.0f/255.0f
                                                                            blue:81.0f/255.0f
                                                                           alpha:1.0f];;
 */
    
   // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 0.0f/255.0f
                                                                           green:81.0f/255.0f
                                                                            blue:81.0f/255.0f
                                                                           alpha:1.0f];;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor]; // change this color
    self.navigationItem.titleView = label;
    label.text = @"New Connection";
    [label sizeToFit];
    
    
    //[self setDelegate:self];
    //[self setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
    //[logInViewController setFields: PFLogInFieldsFacebook];
    //[logInViewController setSignUpController:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([PFUser currentUser] && // Check if user is cached
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) { // Check if user is linked to Facebook
        // Present the next view controller without animation
        [self presentConnectionsViewController:NO];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginPressed:(id)sender {
    // Set permissions required from the facebook user account
   // NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile", @"user_education_history",@"user_likes"] block:^(PFUser *user, NSError *error) {
        // [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            NSLog(@"--->%@",FBSDKAccessToken.currentAccessToken.tokenString);
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation addUniqueObject:[NSString stringWithFormat:@"user_%@", user.objectId] forKey:@"channels"];
            [currentInstallation saveInBackground];
            [PFQuery clearAllCachedResults];
            
           if (user.isNew) {
                NMAppDelegate *app = (NMAppDelegate *)[UIApplication sharedApplication].delegate;
                app.fbToken =  FBSDKAccessToken.currentAccessToken.tokenString;
                NSLog(@"User with facebook signed up and logged in!");
                [self performSegueWithIdentifier:@"FirstRun" sender:self];
                //[self presentConnectionsViewController:YES];
            } else {
                NSLog(@"User with facebook logged in!");
                [self presentConnectionsViewController:YES];
                [self dismissViewControllerAnimated:YES completion:nil];

            }
        }
    }];
    
    // [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

- (void)presentConnectionsViewController:(BOOL)animated {

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    NMPickConnectionTypeViewController *connections = (NMPickConnectionTypeViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"NeverMissedHomeScreen"];
    [self.navigationController pushViewController:connections animated:animated];
}
- (void)presentFirstRunViewController {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    NMFirstRunSettingsViewController *firstRun = (NMFirstRunSettingsViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"FirstRunView"];
    firstRun.facebookToken = fbToken;
    [self.navigationController presentViewController:firstRun animated:YES completion:nil];
}


@end
