//
//  PinMapCus.m
//  NeverMissed
//
//  Created by QTS Coder on 17/08/2018.
//  Copyright © 2018 William Emmanuel. All rights reserved.
//

#import "PinMapCus.h"
#import "UIView+RoundedCorners.h"
@implementation PinMapCus


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    _imgBadge.layer.cornerRadius = _imgBadge.frame.size.width/2;
    _imgBadge.layer.masksToBounds = true;
    [_imgPin setRoundedCorners:UIRectCornerAllCorners radius:5.0];
}

@end
