//
//  NMMakeConnectionPublicViewController.h
//  NeverMissed
//
//  Created by William Emmanuel on 5/26/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMConnection.h"

@interface NMMakeConnectionPublicViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;

@property (nonatomic, strong) NMConnection *connection;

@end
