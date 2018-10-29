//
//  NMLikeToConnectViewController.m
//  NeverMissed
//
//  Created by William Emmanuel on 4/24/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import "NMLikeToConnectViewController.h"

@interface NMLikeToConnectViewController ()

@end

@implementation NMLikeToConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_yesButton addTarget:self action:@selector(yesButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [_noButton addTarget:self action:@selector(noButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
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
    // send push notif to the other user to get confirmation.
    // other user will launch two modal
    PFObject *notifObject = [PFObject objectWithClassName:@"Notification"];
    [notifObject setObject:[PFUser currentUser] forKey:@"from"];
    [notifObject setObject:@"always_on" forKey:@"type"];
    [notifObject setObject:_connection.pfobject forKey:@"posting"];
    [notifObject setObject:_connectedUser forKey:@"for"];
    [notifObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        /*PFPush *push = [[PFPush alloc] init];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"always_on", @"type",
                              _connection.pfobject.objectId, @"connection",
                              @"Possible Connection", @"alert",
                              notifObject.objectId, @"notification",
                              @"Increment", @"badge",
                              nil];
        [push setChannel:[NSString stringWithFormat:@"user_%@", _connectedUser.objectId]];
        [push setData:data];
        [push sendPushInBackgroundWithTarget:self selector:@selector(pushSent)];*/
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void) pushSent {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Sent!" message:@"The possible match has been contacted. Hang tight to see if you get a response!" delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
    [alert show];
}

-(void) noButtonWasPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
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
