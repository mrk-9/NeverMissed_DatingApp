//
//  NMHomeViewController.m
//  NeverMissed
//
//  Created by William Emmanuel on 12/18/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMHomeViewController.h"
#import "NMCheckForNotificationsSingleton.h"
#import "NMPickConnectionTypeViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "NMCheckinViewController.h"
#import "SettingVC.h"
#import "NMAppDelegate.h"
@interface NMHomeViewController ()
-(void)checkinTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *labelContainerTop;
@property (weak, nonatomic) IBOutlet UIView *labelContainerBottom;

@end

@implementation NMHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 0.0f/255.0f
                                                                           green:81.0f/255.0f
                                                                            blue:81.0f/255.0f
                                                                           alpha:1.0f];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor]; // change this color
    self.navigationItem.titleView = label;
    label.text = @"NeverMissed";
    [label sizeToFit];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkinTapped:)];
    [self.labelContainerTop addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer* fleetingMomentTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fleetingMomentTapped:)];
    [self.labelContainerBottom addGestureRecognizer:fleetingMomentTapGesture];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (![PFUser currentUser]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"loginView"];
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        NMAppDelegate *app = (NMAppDelegate *)[UIApplication sharedApplication].delegate;
        [app registerLocation];
        [[NMCheckForNotificationsSingleton shared] checkForNotifications];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)settingsPressed:(id)sender {
   // NSLog(@"settingsPressed");
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingVC* settingsViewController = (SettingVC *)[storyboard instantiateViewControllerWithIdentifier:@"SettingVC"];
    [self.navigationController pushViewController:settingsViewController animated:true];
}

- (void)fleetingMomentTapped:(id)sender {
    NSLog(@"fleetingMomentPressed");
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NMPickConnectionTypeViewController* fleetingMomentsViewController = (NMPickConnectionTypeViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NeverMissedHomeScreen"];
    [self.navigationController pushViewController:fleetingMomentsViewController animated:YES];
}

- (IBAction)navigationBarSettingsPressed:(id)sender {
    NSLog(@"navigationBarSettingsPressed");
//    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UINavigationController* settingsViewController = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"SettingsNav"];
//    [self presentViewController:settingsViewController animated:YES completion:nil];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingVC* settingsViewController = (SettingVC *)[storyboard instantiateViewControllerWithIdentifier:@"SettingVC"];
    [self.navigationController pushViewController:settingsViewController animated:true];
}

-(void)checkinTapped:(id)sender {
    NSLog(@"checkinTapped");
    NSLog(@"--->%@",[[PFUser currentUser] objectId]);
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NMCheckinViewController* checkinViewController = (NMCheckinViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CheckinViewController"];
    [self.navigationController pushViewController:checkinViewController animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
