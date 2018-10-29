//
//  PersonCheckInCollect.h
//  NeverMissed
//
//  Created by QTS Coder on 17/08/2018.
//  Copyright © 2018 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PersonCheckInCollectDelegate;
@interface PersonCheckInCollect : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgPerson;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnAvatar;
- (void)registerCollect;
@end



