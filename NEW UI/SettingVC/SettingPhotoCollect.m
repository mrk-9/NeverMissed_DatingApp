//
//  SettingPhotoCollect.m
//  NeverMissed
//
//  Created by QTS Coder on 23/08/2018.
//  Copyright © 2018 William Emmanuel. All rights reserved.
//

#import "SettingPhotoCollect.h"

@implementation SettingPhotoCollect
- (void)registerCollection
{
    NSLog(@"--%f---%f",_imgCell.frame.size.width,_imgCell.frame.size.height);
    _imgCell.layer.cornerRadius = (([[UIScreen mainScreen] bounds].size.width - 44)/3)/2;
    _imgCell.layer.masksToBounds = true;
}
@end
