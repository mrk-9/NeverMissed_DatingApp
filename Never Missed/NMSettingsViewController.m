//
//  NMSettingsViewController.m
//  Never Missed
//
//  Created by William Emmanuel on 8/9/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMSettingsViewController.h"
#import "NMLoginViewController.h"
#import "MBProgressHUD.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface NMSettingsViewController () {
    NSDictionary *_userData;
    NSString *_name;
    NSURL *_pictureURL;
    NSString *_facebookID;
}

@end

@implementation NMSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
   // hud.labelText = @"Loading";
    //hud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 0.0f/255.0f
                                                                           green:81.0f/255.0f
                                                                            blue:81.0f/255.0f
                                                                           alpha:1.0f];;
    

   // MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
   // hud.labelText = @"Loading";
   // hud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0];
    [self.homeButton addTarget:self action:@selector(didPressHome) forControlEvents:UIControlEventTouchUpInside];
    self.profilePicture.contentMode = UIViewContentModeScaleAspectFill;
    
    FBSDKGraphRequest* request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            _userData = (NSDictionary *)result;
            _facebookID = _userData[@"id"];
            _name = _userData[@"first_name"];
            _pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=300&height=300&return_ssl_resources=1", _facebookID]];
            
            NSData * data = [NSData dataWithContentsOfURL:_pictureURL];
            PFFile *imageFile = [PFFile fileWithName:@"profilePic.jpg" data:data];
            
            self.profilePicture.image = [UIImage imageWithData:data];
            if(NSClassFromString(@"UISearchController")) {
                self.profilePictureBackground.image = [UIImage imageWithData:data];
            }
            self.nameLabel.text = _name;
            
            PFUser *currentUser = [PFUser currentUser];
            PFQuery *query = [PFUser query];
            
            [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            
            [query getObjectInBackgroundWithId:currentUser.objectId block:^(PFObject *foundUser, NSError *error) {
                if(!error){
                    NSArray *names = [_name componentsSeparatedByString:@" "];
                    foundUser[@"name"] = [names firstObject];
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:[names firstObject] forKey:@"name"];
                    [defaults synchronize];
                    foundUser[@"profilePicture"] = imageFile;
                    [foundUser saveInBackground];
                    [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                }
            }];
        }
    }];
    

}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self applyBlurEffect];
    CALayer *imageLayer = self.profilePicture.layer;
    [imageLayer setCornerRadius:50];
    [imageLayer setBorderWidth:0];
    [imageLayer setMasksToBounds:YES];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0];
    label.textAlignment = NSTextAlignmentCenter;
    // ^-Use UITextAlignmentCenter for older SDKs.
    label.textColor = [UIColor whiteColor]; // change this color
    self.navigationItem.titleView = label;
    label.text = @"Settings";
    self.homeButton.tintColor = [UIColor whiteColor];
    [self.homeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [label sizeToFit];
}

-(void) applyBlurEffect{
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = _profilePictureBackground.bounds;
    [_profilePictureBackground addSubview:visualEffectView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationItem.leftBarButtonItem=nil;
    self.navigationItem.hidesBackButton=YES;
    
}

-(void)didPressHome {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutPressed:(id)sender {
    [PFUser logOut]; // Log out
  /*  if (![PFUser currentUser]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self];
        [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
        [logInViewController setFields: PFLogInFieldsFacebook];
        [logInViewController setSignUpController:nil];
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }*/
    if (![PFUser currentUser]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"loginView"];
        [self presentViewController:vc animated:YES completion:nil];
        
    }
    
}

- (IBAction)closePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)howItWorksPressed:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.nmtheapp.com/#how-does-it-work"]];
}


@end
