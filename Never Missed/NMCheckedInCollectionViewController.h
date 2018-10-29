//
//  NMCheckedInCollectionViewController.h
//  NeverMissed
//
//  Created by Aaron Preston on 5/7/16.
//  Copyright © 2016 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NMCheckedInCollectionViewController : UICollectionViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *checkinButton;

@property (strong, nonatomic) NSString* venueId;
@property (strong, nonatomic) NSString* venueName;
@property (strong, nonatomic) NSString* genderInterest;
@property (strong, nonatomic) NSMutableSet* currentConnections;
- (IBAction)checkinPressed:(id)sender;

@end
