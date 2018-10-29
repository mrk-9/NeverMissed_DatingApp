//
//  NMConnectionsTableViewController.h
//  Never Missed
//
//  Created by Tom Mignone on 11/19/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMConnection.h"
#import "NMGPSConnection.h"
#import "NMPlaneConnection.h"
#import "NMTrainConnection.h"

@interface NMConnectionsTableViewController : UITableViewController


@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) NSMutableArray *connectionUserArray;
@property (nonatomic, strong) NSMutableArray *connectionArray;

@property (nonatomic) BOOL unmatchedRequestsAreLoading;
@property (nonatomic) BOOL connectionsAreLoading;
@property (nonatomic, strong) NSMutableArray *unmatchedRequests;
@property (nonatomic, strong) NSMutableArray *connections;
@property (weak, nonatomic) IBOutlet UILabel *pendingConnectionLabel;

@end
