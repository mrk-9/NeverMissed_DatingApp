//
//  NMPlaneConnection.h
//  Never Missed
//
//  Created by William Emmanuel on 10/6/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMConnection.h"

@interface NMPlaneConnection : NMConnection

@property (nonatomic, strong) NSString *carrier;
@property (nonatomic) int flightNo;

@end
