//
//  NMMatchTableViewController.h
//  Never Missed
//
//  Created by William Emmanuel on 11/18/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "NMGPSConnection.h"
#import "NMPlaneConnection.h"
#import "NMConnection.h"


@interface NMMatchTableViewController : UITableViewController

@property (nonatomic) BOOL unmatchedRequestsAreLoading;
@property (nonatomic) BOOL connectionsAreLoading;
@property (nonatomic, strong) NSMutableArray *unmatchedRequests;
@property (nonatomic, strong) NSMutableArray *connections;

@end
