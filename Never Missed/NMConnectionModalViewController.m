//
//  NMConnectionModalViewController.m
//  NeverMissed
//
//  Created by William Emmanuel on 12/19/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMConnectionModalViewController.h"
#import "NMConnectionsTableViewController.h"
#import "NMNotPaidForModalViewController.h"
#import "NMChatViewController.h"
#import <Parse/Parse.h>

@interface NMConnectionModalViewController ()

@end

@implementation NMConnectionModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_backButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [_chatButton addTarget:self action:@selector(chatButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    _nameLabel.text = [_connectedUser objectForKey:@"name"];
    _profilePicture.contentMode = UIViewContentModeScaleAspectFill;
    PFFile *imageFile = [_connectedUser objectForKey:@"profilePicture"];
    NSData *data = [imageFile getData];
    _profilePicture.image = [UIImage imageWithData:data];
    CALayer *imageLayer = _profilePicture.layer;
    [imageLayer setCornerRadius:50];
    [imageLayer setBorderWidth:0];
    [imageLayer setMasksToBounds:YES];
}

-(void)backButtonWasPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)chatButtonWasPressed {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NMConnectionsTableViewController *tvc = (NMConnectionsTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ConnectionTableViewController"];
    NMChatViewController *viewController = (NMChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    viewController.connection = _connection;
    viewController.connectionUser = _connectedUser;
    
    //TODO: Reminder to look into testing this across the board to make sure it doesn the right thing - ABP
    [self dismissViewControllerAnimated:YES completion:nil];
    [(UINavigationController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController] popToRootViewControllerAnimated:YES];
    [(UINavigationController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController] pushViewController:tvc animated:NO];
    
    PFUser *current = [PFUser currentUser];
    [current fetchIfNeeded];
    
    NSLog(@"connectedUser:%d",[[_connectedUser objectForKey:@"subscribed"] boolValue]);
    NSLog(@"connectedUser:%d",[[current objectForKey:@"subscribed"] boolValue]);
    
    if([[_connectedUser objectForKey:@"subscribed"] intValue] == 1) {
        [_connection setObject:@YES forKey:@"paidFor"];
        [_connection saveEventually];
    }
    else if ([[current objectForKey:@"subscribed"] intValue] == 1) {
        [_connection setObject:@YES forKey:@"paidFor"];
        [_connection saveEventually];
    }
    if([[_connection objectForKey:@"paidFor"] intValue] == 1) {
        [(UINavigationController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController] pushViewController:viewController animated:YES];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NMNotPaidForModalViewController *npvc = (NMNotPaidForModalViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NotPaidForViewController"];
        npvc.connection = _connection;
        npvc.connectedUser = _connectedUser;
        [(UINavigationController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:npvc animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
