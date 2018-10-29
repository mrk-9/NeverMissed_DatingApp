//
//  DataLocal.m
//  NeverMissed
//
//  Created by QTS Coder on 20/08/2018.
//  Copyright © 2018 William Emmanuel. All rights reserved.
//

#import "DataLocal.h"
#import "ProfileObj.h"
@implementation DataLocal
+  (NSMutableArray *)arrProfile
{
    NSMutableArray *arrs = [[NSMutableArray alloc] init];
    ProfileObj *obj = [[ProfileObj alloc] init];
    obj.name = @"Michael";
    obj.image = @"profile";
    obj.numberImage = 2;
    [arrs addObject:obj];
    
    obj = [[ProfileObj alloc] init];
    obj.name = @"Maria";
    obj.image = @"profile2";
    obj.numberImage = 4;
    [arrs addObject:obj];
    
    obj = [[ProfileObj alloc] init];
    obj.name = @"Michael";
    obj.image = @"profile";
     obj.numberImage = 2;
    [arrs addObject:obj];
    
    obj = [[ProfileObj alloc] init];
    obj.name = @"Maria";
    obj.image = @"profile2";
     obj.numberImage = 4;
    [arrs addObject:obj];
    
    obj = [[ProfileObj alloc] init];
    obj.name = @"Michael";
    obj.image = @"profile";
    obj.numberImage = 2;
    [arrs addObject:obj];
    
    obj = [[ProfileObj alloc] init];
    obj.name = @"Maria";
    obj.image = @"profile2";
     obj.numberImage = 4;
    [arrs addObject:obj];
    
    obj = [[ProfileObj alloc] init];
    obj.name = @"Michael";
    obj.image = @"profile";
     obj.numberImage = 2;
    [arrs addObject:obj];
    
    obj = [[ProfileObj alloc] init];
    obj.name = @"Maria";
    obj.image = @"profile2";
     obj.numberImage = 4;
    [arrs addObject:obj];
    
    obj = [[ProfileObj alloc] init];
    obj.name = @"Michael";
    obj.image = @"profile";
     obj.numberImage = 2;
    [arrs addObject:obj];
    return  arrs;
}
@end
