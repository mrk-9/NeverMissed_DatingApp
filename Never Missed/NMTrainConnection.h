//
//  NMTrainConnection.h
//  NeverMissed
//
//  Created by Tom Mignone on 11/28/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMConnection.h"

@interface NMTrainConnection : NMConnection

@property (nonatomic, strong) NSString *railway;
@property (nonatomic) NSString *trainNo;

@end
