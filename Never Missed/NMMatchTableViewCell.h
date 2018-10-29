//
//  NMMatchTableViewCell.h
//  Never Missed
//
//  Created by William Emmanuel on 11/26/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NMMatchTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *matchDateLabel;


@end
