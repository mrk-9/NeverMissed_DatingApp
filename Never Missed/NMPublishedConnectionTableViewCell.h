//
//  NMPublishedConnectionTableViewCell.h
//  NeverMissed
//
//  Created by Tom Mignone on 12/23/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NMPublishedConnectionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *connectionTypeIcon;
@property (weak, nonatomic) IBOutlet UILabel *connectionTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectionDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *hatLabel;

@end
