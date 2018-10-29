//
//  NMNotPaidForModalViewController.h
//  NeverMissed
//
//  Created by William Emmanuel on 12/26/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <StoreKit/StoreKit.h>

@interface NMNotPaidForModalViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsOrPayButton;
@property (nonatomic, strong) PFObject *connection;
@property (nonatomic, strong) PFUser *connectedUser; 

@end
