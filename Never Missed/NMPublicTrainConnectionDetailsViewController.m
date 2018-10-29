//
//  NMPublicTrainConnectionDetailsViewController.m
//  NeverMissed
//
//  Created by Tom Mignone on 5/31/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import "NMPublicTrainConnectionDetailsViewController.h"

@implementation NMPublicTrainConnectionDetailsViewController

- (void)viewDidLoad {
    [_postedByDescriptionLabel sizeToFit];
    [_lookingFordescriptionLabel sizeToFit];
    
    NSString *railway = [self.connection objectForKey:@"railway"];
    NSString *trainNo = [self.connection objectForKey:@"trainNo"];
    _trainLabel.text = [NSString stringWithFormat:@"%@ %@", railway, trainNo];
    
    PFUser *postedBy = [_connection objectForKey:@"postedBy"];
    NSString *postedByGender = [postedBy objectForKeyedSubscript:@"gender"];
    NSString *postedByGenderPreference = [postedBy objectForKey:@"interestedIn"];
    
    //Compile the details of the post creator =====================================================
    NSString *clothingColor_1 = [[self.connection objectForKey:@"myClothingColor"] lowercaseString];
    
    NSString *hairColor_1 = [[postedBy objectForKey:@"hairColor"]lowercaseString];
    
    
    NSString *hairLength_1 = [[postedBy objectForKey:@"hairLength"] lowercaseString];
    
    NSNumber *hatBoolNumVal_1 = [self.connection objectForKey: @"myHat"];
    bool hatBool_1 = [hatBoolNumVal_1 boolValue];
    NSString *hat_1;
    if(hatBool_1)
    {
        hat_1 = @" and a hat";
    }
    else{
        hat_1
        = @"";
    }
    NSNumber *patternedBoolNumVal_1 = [self.connection objectForKey:@"myPatterned"];
    bool patternedBool_1 = [patternedBoolNumVal_1 boolValue];
    NSString *patterned_1;
    if(patternedBool_1)
    {
        patterned_1 = @" patterned";
    }
    else{
        patterned_1 = @"";
    }
    
    NSString *heightInInches_1 = [postedBy objectForKey:@"heightInInches"];
    
    int heightIn_1 = [heightInInches_1 intValue];
    int feet_1 = heightIn_1 / 12;
    int inches_1 = heightIn_1 % 12;
    
    NSString *posterDescription = [NSString stringWithFormat:@"%d'%d'' %@ with %@ %@ hair wearing %@%@ clothing%@." ,feet_1, inches_1, postedByGender, hairLength_1, hairColor_1, clothingColor_1, patterned_1, hat_1];
    _postedByDescriptionLabel.text = posterDescription;
    
    //Compile the decription of the person they are seeking ======================================
    NSString *clothingColor_2 = [[self.connection objectForKey:@"clothingColor"] lowercaseString];
    
    NSString *hairColor_2 = [[self.connection objectForKey:@"hairColor"]lowercaseString];
    
    
    NSString *hairLength_2 = [[self.connection objectForKey:@"hairLength"] lowercaseString];
    
    
    NSNumber *hatBoolNumVal_2 = [self.connection objectForKey: @"hat"];
    bool hatBool_2 = [hatBoolNumVal_2 boolValue];
    NSString *hat_2;
    if(hatBool_2)
    {
        hat_2 = @" and a hat";
    }
    else{
        hat_2
        = @"";
    }
    
    
    NSNumber *patternedBoolNumVal_2 = [self.connection objectForKey:@"patterned"];
    bool patternedBool_2 = [patternedBoolNumVal_2 boolValue];
    NSString *patterned_2;
    if(patternedBool_2)
    {
        patterned_2 = @" patterned";
    }
    else{
        patterned_2 = @"";
    }
    
    NSString *heightInInches_2 = [self.connection objectForKey:@"heightInInches"];
    
    int heightIn_2 = [heightInInches_2 intValue];
    int feet_2 = heightIn_2 / 12;
    int inches_2 = heightIn_2 % 12;
    
    
    NSString *descriptionString = [NSString stringWithFormat:@"%d'%d'' %@ with %@ %@ hair wearing %@%@ clothing%@." , feet_2, inches_2, postedByGenderPreference, hairLength_2, hairColor_2, clothingColor_2, patterned_2, hat_2];
    _lookingFordescriptionLabel.text = descriptionString;
}


- (IBAction)matchButtonWasPressed:(id)sender {
    PFObject *notifObject = [PFObject objectWithClassName:@"Notification"];
    [notifObject setObject:[PFUser currentUser] forKey:@"from"];
    [notifObject setObject:@"always_on" forKey:@"type"];
    [notifObject setObject:_connection forKey:@"posting"];
    [notifObject setObject:[_connection objectForKey:@"postedBy"] forKey:@"for"];
    [notifObject saveInBackground];
    
    /*[notifObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        PFPush *push = [[PFPush alloc] init];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"always_on", @"type",
                              _connection.objectId, @"connection",
                              @"Possible Connection", @"alert",
                              @"Increment", @"badge",
                              nil];
        PFUser *other = [_connection objectForKey:@"postedBy"];
        [push setChannel:[NSString stringWithFormat:@"user_%@", other.objectId]];
        [push setData:data];
        [push sendPushInBackgroundWithTarget:self selector:@selector(pushSent)];
    }];*/
}

-(void)pushSent {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Accepted!" message:@"We will notify the poster that they have a match. If they accept you can begin chatting on the matches page." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

@end
