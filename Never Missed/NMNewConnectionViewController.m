//
//  NMNewConnectionViewController.m
//  NeverMissed
//
//  Created by Tom Mignone on 12/17/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "NMLoginViewController.h"
#import "NMNewConnectionViewController.h"

@interface NMNewConnectionViewController ()

@end

@implementation NMNewConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([PFUser currentUser] && // Check if user is cached
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:[NSString stringWithFormat:@"user_%@", [PFUser currentUser].objectId] forKey:@"channels"];
        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        }];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (![PFUser currentUser] && // Check if user is cached
        ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) { // Check if user
        //show the login view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NMLoginViewController *privacy = (NMLoginViewController*)[storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
        
        // present
        [self.navigationController presentViewController:privacy animated:YES completion:nil];
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

@end
