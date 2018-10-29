//
//  NMMakeConnectionPublicViewController.m
//  NeverMissed
//
//  Created by William Emmanuel on 5/26/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import "NMMakeConnectionPublicViewController.h"

@interface NMMakeConnectionPublicViewController ()

@end

@implementation NMMakeConnectionPublicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_yesButton addTarget:self action:@selector(yesButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [_noButton addTarget:self action:@selector(noButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - button handlers

-(void) yesButtonWasPressed {
    [self.connection.pfobject setObject:@YES forKey:@"public"];
    [self.connection.pfobject saveInBackgroundWithTarget:self selector:@selector(madePublic)];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) noButtonWasPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)madePublic {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection saved!" message:@"Your connection has been posted to public boards." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
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
