//
//  NMUserCollectionViewCell.h
//  NeverMissed
//
//  Created by Aaron Preston on 5/7/16.
//  Copyright © 2016 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface NMUserCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UIButton *interestButton;

@end
