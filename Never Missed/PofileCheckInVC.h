//
//  PofileCheckInVC.h
//  NeverMissed
//
//  Created by QTS Coder on 20/08/2018.
//  Copyright © 2018 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileObj.h"
@interface PofileCheckInVC : UIViewController
@property (strong, nonatomic) NSString* venueName;
@property (strong, nonatomic) ProfileObj* profileObj;
@property (nonatomic,assign) NSInteger indexSelected;
@end
