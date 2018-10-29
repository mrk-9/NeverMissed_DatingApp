//
//  NMCheckedInUsersCell.h
//  NeverMissed
//
//  Created by Aaron Preston on 4/22/16.
//  Copyright © 2016 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface NMCheckedInUsersCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIButton *interestButton;

@end
