//
//  PersonCheckInCollect.m
//  NeverMissed
//
//  Created by QTS Coder on 17/08/2018.
//  Copyright © 2018 William Emmanuel. All rights reserved.
//

#import "PersonCheckInCollect.h"

@implementation PersonCheckInCollect

- (void)registerCollect
{
    _imgPerson.layer.cornerRadius = _imgPerson.frame.size.width/2;
    _imgPerson.layer.masksToBounds = true;
    _btnAvatar.layer.cornerRadius = _btnAvatar.frame.size.width/2;
    _btnAvatar.layer.masksToBounds = true;
}

@end
