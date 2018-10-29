//
//  NMConnectionDetailsViewController.m
//  NeverMissed
//
//  Created by Tom Mignone on 12/23/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMConnectionDetailsViewController.h"
#import "NMEditConnectionAttributesViewController.h"

@interface NMConnectionDetailsViewController ()

@end

@implementation NMConnectionDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDateFormatter *formatter;
    NSString *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yyyy"];
    
    dateString = [formatter stringFromDate:self.connection.createdAt];
    self.datePostedLabel.text = dateString;
    self.hairColorLabel.text = self.connection.hairColor;
    self.hairLengthLabel.text = self.connection.hairLength;
    self.clothingColorLabel.text = self.connection.clothingColor;
    if(self.connection.hat == 1){
        self.hatLabel.text = @"Yes";
    }
    else self.hatLabel.text = @"No";
    int feet = self.connection.heightInInches/12;
    int inches = self.connection.heightInInches%12;
    NSString *heightString = [NSString stringWithFormat:@" %d'%d''", feet, inches];
    self.heightLabel.text = heightString;
 
    
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Edit"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(editConnectionDetailsPressed)];
    self.navigationItem.rightBarButtonItem = editBtn;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)editConnectionDetailsPressed {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NMEditConnectionAttributesViewController *editDetailsVC = (NMEditConnectionAttributesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"EditConnectionAttributes"];
    editDetailsVC.connection = _connection;
    [self.navigationController pushViewController:editDetailsVC animated:YES];
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
