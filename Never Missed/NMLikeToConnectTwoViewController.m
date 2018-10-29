//
//  NMLikeToConnectTwoViewController.m
//  NeverMissed
//
//  Created by William Emmanuel on 4/24/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import "NMLikeToConnectTwoViewController.h"

@interface NMLikeToConnectTwoViewController ()

@end

@implementation NMLikeToConnectTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_yesButton addTarget:self action:@selector(yesButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [_noButton addTarget:self action:@selector(noButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [_connectedUser fetchIfNeeded];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) yesButtonWasPressed {
    // send push notif to the other user and create connection.
    // other user will launch two modal
    PFObject *newConnection = [PFObject objectWithClassName:@"Connection"];
    [newConnection setObject:[PFUser currentUser] forKey:@"user1"];
    [newConnection setObject:_connectedUser forKey:@"user2"];
    [newConnection setObject:_connection.pfobject.objectId forKey:@"deletedId"];
    [newConnection save];
    [_connection.pfobject deleteEventually];
    _connection = nil;
    
    // send push
    /*PFPush *push = [[PFPush alloc] init];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"connection", @"type",
                          newConnection.objectId, @"connection",
                          @"New Connection", @"alert",
                          @"Increment", @"badge",
                          nil];
    
    PFUser *otherUser = [_connectedUser objectForKey:@"postedBy"];
    [push setChannel:[NSString stringWithFormat:@"user_%@", otherUser.objectId]];
    [push setData:data];
    [push sendPushInBackgroundWithTarget:self selector:@selector(pushSent)];*/
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)pushSent {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Made!" message:@"Go to matches to start chatting" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void) noButtonWasPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
