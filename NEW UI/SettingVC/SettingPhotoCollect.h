//
//  SettingPhotoCollect.h
//  NeverMissed
//
//  Created by QTS Coder on 23/08/2018.
//  Copyright © 2018 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoObj.h"
@interface SettingPhotoCollect : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgCell;
@property (weak, nonatomic) IBOutlet UIButton *btnDel;
@property (weak, nonatomic) IBOutlet UILabel *lblAdd;
@property (nonatomic,retain) PhotoObj *photoObj;
- (void)registerCollection;
@end
