//
//  CheckInUserVC.h
//  NeverMissed
//
//  Created by QTS Coder on 17/08/2018.
//  Copyright © 2018 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckInUserVC : UIViewController
@property (strong, nonatomic) NSString* venueId;
@property (strong, nonatomic) NSString* venueName;
@property (strong, nonatomic) NSString* genderInterest;
@property (strong, nonatomic) NSMutableSet* currentConnections;
@end
