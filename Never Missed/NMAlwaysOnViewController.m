//
//  NMAlwaysOnViewController.m
//  NeverMissed
//
//  Created by William Emmanuel on 4/24/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import "NMAlwaysOnViewController.h"
#import "NMGPSSingleton.h"


@interface NMAlwaysOnViewController ()

@end

@implementation NMAlwaysOnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFUser *current = [PFUser currentUser];
    if([[current objectForKey:@"always_on"] intValue] == 1) {
        [_alwaysOnToggle setOn:YES];
    } else {
        [_alwaysOnToggle setOn:NO];
    }
    [_saveButton addTarget:self action:@selector(didTapSave) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didTapSave {
    PFUser *current = [PFUser currentUser];
    // flipping from off to on
    NMGPSSingleton *shared = [NMGPSSingleton shared];
    if ([[current objectForKey:@"always_on"] intValue] == 0 && _alwaysOnToggle.on) {
        NMGPSSingleton *shared = [NMGPSSingleton shared];
        [shared startGettingLocation];
    }
    // flipping from on to off
    else if ([[current objectForKey:@"always_on"] intValue] == 1 && !_alwaysOnToggle.on) {
        [shared stopGettingLocation];
    }
    NSNumber* alwaysOn = (_alwaysOnToggle.on == YES)?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [current setObject:alwaysOn forKey:@"always_on"];
    [current saveInBackgroundWithTarget:self selector:@selector(justSaved)];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)justSaved {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Always on prefrence saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
