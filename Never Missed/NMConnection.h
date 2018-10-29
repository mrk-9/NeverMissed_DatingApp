//
//  NMConnection.h
//  Never Missed
//
//  Created by William Emmanuel on 8/19/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface NMConnection : NSObject

@property (nonatomic, strong) PFUser *postedBy;

@property (nonatomic, strong) NSString *connectionType;

@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *hairColor;
@property (nonatomic, strong) NSString *hairLength;
@property (nonatomic) int heightInInches;
@property (nonatomic, strong) NSString *clothingColor;
@property (nonatomic) BOOL patterned;
@property (nonatomic) BOOL hat;
@property (nonatomic) BOOL publicConnection;

@property (nonatomic, strong) NSString *myClothingColor;
@property (nonatomic) BOOL myPatterned;
@property (nonatomic) BOOL myHat;
@property (nonatomic) int myShoeHeight;

@property (nonatomic, strong) PFObject *pfobject;

@property (nonatomic, strong) NSArray *queryReturn;
@property (nonatomic, strong) NSMutableArray *userArray; 

-(id) initWithParseObject:(PFObject*) object;
-(void) eventuallySaveToParse;
//-(void) saveToParseEventuallyWithTarget:(id)target andSelector:(SEL)selector;
-(void) saveToParseEventually;
-(void) searchForMatches ;
-(BOOL) isMatch:(NMConnection*)connection;
-(void)dealWithPossibleMatches:(id)result error:(NSError *)error;
-(BOOL) hasConnectivity;
-(void)scheduleNotification;

@end