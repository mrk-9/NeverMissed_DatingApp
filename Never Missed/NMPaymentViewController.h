//
//  NMPaymentViewController.h
//  Never Missed
//
//  Created by William Emmanuel on 11/27/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface NMPaymentViewController : UIViewController <SKProductsRequestDelegate>
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UIButton *subscribeButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


@end
