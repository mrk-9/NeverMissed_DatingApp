//
//  NMChatDetailViewController.m
//  NeverMissed
//
//  Created by William Emmanuel on 10/20/15.
//  Copyright © 2015 William Emmanuel. All rights reserved.
//

#import "NMChatDetailViewController.h"
#import "MBProgressHUD.h"

@interface NMChatDetailViewController ()

-(void)reportUserPrompt;
-(void)reportUserWithReason:(NSString*)reportReason;
-(void)blockUserPrompt;
-(void)blockUserWithConnectionId:(NSString*)connectionId;
-(void)alertWithMessage:(NSString*)message;

@end

@implementation NMChatDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _nameLabel.text = [_connectionUser objectForKey:@"name"];
    _schoolLabel.text = [_connectionUser objectForKey:@"school"];
    PFFile *thumbnail = [_connectionUser objectForKey:@"profilePicture"];
    NSData *imageData = [thumbnail getData];
    UIImage *image = [UIImage imageWithData:imageData];
    
    _profileImage.contentMode = UIViewContentModeScaleAspectFill;
    [_profileImage setImage:image];
    
    PFUser *currentUser = [PFUser currentUser];
    
    
    self.interest1.text = @"No common interests.";
    self.interest2.text = @"";
    self.interest3.text = @"";
    
    NSMutableSet* connectionUserSet = [NSMutableSet setWithArray:[_connectionUser objectForKey:@"userLikes"]];
    NSSet* currentUserSet = [NSSet setWithArray:[currentUser objectForKey:@"userLikes"]];
    [connectionUserSet intersectSet:currentUserSet];
    
    if([connectionUserSet count] > 0){
        NSInteger currentLabel = 1;
        NSArray* intersectedLikes = [connectionUserSet allObjects];
        for(NSDictionary* like in intersectedLikes){
            if(currentLabel == 1){
                self.interest1.text = [like objectForKey:@"likeName"];
                currentLabel++;
            }
            else if(currentLabel == 2){
                self.interest2.text = [like objectForKey:@"likeName"];
                currentLabel++;
            }
            else if(currentLabel == 3){
                self.interest3.text = [like objectForKey:@"likeName"];
                currentLabel++;
                break;
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMoreOptions:(id)sender {
    NSLog(@"showMoreOptions");
    UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* blockAction = [UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Block User");
        [self blockUserPrompt];
    }];
    [actionSheet addAction:blockAction];
    
    UIAlertAction* reportAction = [UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Report User");
        [self reportUserPrompt];
    }];
    [actionSheet addAction:reportAction];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)reportUserPrompt{
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"Why are you reporting this user?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* messagesButton = [UIAlertAction actionWithTitle:@"Inappropriate Messages" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self reportUserWithReason:@"Inappropriate Messages"];
    }];
    [alert addAction:messagesButton];
    
    UIAlertAction* photosButton = [UIAlertAction actionWithTitle:@"Inappropriate Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self reportUserWithReason:@"Inappropriate Photo"];
    }];
    [alert addAction:photosButton];
    
    UIAlertAction* offlineButton = [UIAlertAction actionWithTitle:@"Inappropriate Offline Behavior" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self reportUserWithReason:@"Inappropriate Offline Behavior"];
    }];
    [alert addAction:offlineButton];
    
    UIAlertAction* otherButton = [UIAlertAction actionWithTitle:@"Other" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self reportUserWithReason:@"Other"];
    }];
    [alert addAction:otherButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
}

-(void)reportUserWithReason:(NSString*)reportReason{
    PFUser* currentUser = [PFUser currentUser];
    PFObject* reportUser = [PFObject objectWithClassName:@"ReportedUser"];
    reportUser[@"user"] = self.connectionUser;
    reportUser[@"reporter"] = currentUser;
    reportUser[@"reason"] = reportReason;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [reportUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError* error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(succeeded){
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"Would you also like to block this user?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* blockButton = [UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self blockUserWithConnectionId:self.connection.objectId];
            }];
            [alert addAction:blockButton];
            
            UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelButton];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

-(void)blockUserPrompt{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure you want to block this user?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* blockButton = [UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self blockUserWithConnectionId:self.connection.objectId];
    }];
    [alert addAction:blockButton];
    
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)blockUserWithConnectionId:(NSString*)connectionId{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.connection deleteInBackgroundWithBlock:^(BOOL succeeded, NSError* error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(succeeded){
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            PFUser* currentUser = [PFUser currentUser];
            PFObject* blockedUser = [PFObject objectWithClassName:@"BlockedUser"];
            blockedUser[@"user"] = self.connectionUser;
            blockedUser[@"blocker"] = currentUser;
            
            [blockedUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                if(succeeded){
                    [self alertWithMessage:@"You've successfully blocked this user. If you run into any more problems, please contact us."];
                }
            }];
        }
        
        
    }];
    
}

-(void)alertWithMessage:(NSString*)message{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
