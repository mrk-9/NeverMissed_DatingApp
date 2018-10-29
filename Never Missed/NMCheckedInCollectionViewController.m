//
//  NMCheckedInCollectionViewController.m
//  NeverMissed
//
//  Created by Aaron Preston on 5/7/16.
//  Copyright © 2016 William Emmanuel. All rights reserved.
//

#import "NMCheckedInCollectionViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "NMUserCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "NMConnectionModalViewController.h"
#import "NMCache.h"
#import "MBProgressHUD.h"

#define CELL_WIDTH 140.0
#define CELL_HEIGHT 184.0
#define CELLS_PER_ROW 2

@interface NMCheckedInCollectionViewController () <UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray* checkedInUsers;
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@property (strong, nonatomic) NMCache* cache;
@property (strong, nonatomic) NSMutableArray* interestedUsers;
@property (assign, nonatomic) BOOL hasCheckedIn;

-(void)searchAndMatchInterestWithUser:(PFUser*)userToMatch;
-(void)startRefresh;
-(void)endRefresh;
-(void)refreshCollectionView;
-(void)checkinUserAtVenue:(NSString*)venueId;
-(void)setupBackgroundView;

@end

@implementation NMCheckedInCollectionViewController

static NSString * const reuseIdentifier = @"CheckedInUserCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    self.title = self.venueName;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.cache = [NMCache sharedCache];
    self.hasCheckedIn = [self.cache hasCheckedInToVenue:self.venueId];
    
    self.checkedInUsers = [NSMutableArray array];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(startRefresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.hasCheckedIn == NO){
        self.checkinButton.enabled = YES;
        [self setupBackgroundView];
    }
    else {
        self.interestedUsers = [self.cache interestedInUsersAtVenue:self.venueId];
        [self refreshCollectionView];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    [self.cache setInterestedInUsers:self.interestedUsers atVenue:self.venueId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    NSInteger numItems = 0;
    if(self.hasCheckedIn){
        numItems = [self.checkedInUsers count];
    }
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NMUserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    if([self.checkedInUsers count] > 0){
        PFObject* checkedInObject = [self.checkedInUsers objectAtIndex:indexPath.row];
        PFUser* checkedInUser = [checkedInObject objectForKey:@"checkedInUser"];
        cell.profileImageView.file = [checkedInUser objectForKey:@"profilePicture"];
        [cell.profileImageView loadInBackground];
        
        cell.username.text = [checkedInUser objectForKey:@"name"];
        
        cell.interestButton.tag = indexPath.row;
        if([self.interestedUsers containsObject:checkedInUser.objectId]){
            [cell.interestButton setImage:[UIImage imageNamed:@"Checkmark"] forState:UIControlStateNormal];
            cell.interestButton.enabled = NO;
        }
        else {
            [cell.interestButton setImage:[UIImage imageNamed:@"Like"] forState:UIControlStateNormal];
            cell.interestButton.enabled = YES;
        }
        [cell.interestButton addTarget:self action:@selector(interestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.layer.cornerRadius = 5.0;
        cell.layer.masksToBounds = YES;
        cell.layer.borderWidth = 1;
        cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    return cell;
}

#pragma mark - Private Methods

- (IBAction)checkinPressed:(id)sender{
    NSLog(@"checkinPressed");
    [self checkinUserAtVenue:self.venueId];
}

-(void)startRefresh {
    NSLog(@"startRefresh");
    if(self.hasCheckedIn){
        [self refreshCollectionView];
    }
    else {
        [self endRefresh];
    }
}

-(void)endRefresh {
    if(self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    }
}

-(void)refreshCollectionView {
    PFUser* currentUser = [PFUser currentUser];
    NSDate* fourHoursAgo = [[NSDate date] dateByAddingTimeInterval:-3600*4];
    PFQuery* query = [PFQuery queryWithClassName:@"CheckIn"];
    [query whereKey:@"venueId" equalTo:self.venueId];
    [query whereKey:@"gender" equalTo:self.genderInterest];
    [query whereKey:@"checkinTime" greaterThanOrEqualTo:fourHoursAgo];
    NSLog(@"interested in:%@, %@",self.genderInterest, self.venueId);
    [query whereKey:@"checkedInUser" notEqualTo:currentUser];
    [query includeKey:@"checkedInUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            NSLog(@"Success!:%d",[objects count]);
            [self.checkedInUsers removeAllObjects];
            for(PFObject* object in objects){
                PFObject* checkedInUser = object[@"checkedInUser"];
                NSLog(@"CheckedInUser:%@",object[@"checkedInUser"]);
                if(![self.currentConnections containsObject:checkedInUser.objectId]) {
                    [self.checkedInUsers addObject:object];
                }
            }
            [self.collectionView reloadData];
        }
        else {
            NSLog(@"Error finding objects");
        }
        [self endRefresh];
    }];
}

-(void)interestButtonClicked:(id)sender {
    UIButton* button = (UIButton*)sender;
    NSLog(@"sender tag:%ld",(long)button.tag);
    
    PFObject* checkIn = [self.checkedInUsers objectAtIndex:button.tag];
    PFUser* checkedInUser = [checkIn objectForKey:@"checkedInUser"];
    NSLog(@"Interested In:%@",checkedInUser.objectId);
    
    if([self.interestedUsers count] < MAX_INTERESTED_USERS) {
        [self.interestedUsers addObject:checkedInUser.objectId];
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:button.tag inSection:0]]];
        [self searchAndMatchInterestWithUser:checkedInUser];
    }
    else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"You can only express interest in %d users at a given venue.",MAX_INTERESTED_USERS] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

-(void)searchAndMatchInterestWithUser:(PFUser*)userToMatch{
    
    //Check whether the other user has already expressed interest. It may seem backwards when you first look at it,
    //but what I'm asking first is whether the other user has already expressed interest in the current user.
    PFQuery* interestQuery = [PFQuery queryWithClassName:@"Interest"];
    NSDate* fourHoursAgo = [[NSDate date] dateByAddingTimeInterval:-3600*4];
    [interestQuery whereKey:@"interestedInUser" equalTo:[PFUser currentUser]];
    [interestQuery whereKey:@"interestUser" equalTo:userToMatch];
    [interestQuery whereKey:@"venueId" equalTo:self.venueId];
    [interestQuery whereKey:@"createdAt" greaterThanOrEqualTo:fourHoursAgo];
    
    [interestQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            
            if([objects count] > 0){
                NSLog(@"Other User has expressed interest");
                PFObject *newConnection = [PFObject objectWithClassName:@"Connection"];
                [newConnection setObject:[PFUser currentUser] forKey:@"user1"];
                [newConnection setObject:userToMatch forKey:@"user2"];
                [newConnection saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(!error){
                        if(succeeded){
                            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                            NMConnectionModalViewController* connectionViewController = (NMConnectionModalViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ConnectionModalViewController"];
                            connectionViewController.connectedUser = userToMatch;
                            connectionViewController.connection = newConnection;
                            
                            //Send a push notification to the other user. This should eventually be done in cloud code!
                            /*PFPush *push = [[PFPush alloc] init];
                            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  @"connection", @"type",
                                                  newConnection.objectId, @"connection",
                                                  @"New Connection", @"alert",
                                                  @"Increment", @"badge",
                                                  nil];
                            
                            [push setChannel:[NSString stringWithFormat:@"user_%@", userToMatch.objectId]];
                            [push setData:data];
                            [push sendPushInBackground];*/
                            
                            [self presentViewController:connectionViewController animated:YES completion:nil];
                        }
                    }
                }];
            }
            else {
                NSLog(@"Save interest");
                PFObject* interestObject = [PFObject objectWithClassName:@"Interest"];
                interestObject[@"interestUser"] = [PFUser currentUser];
                interestObject[@"interestedInUser"] = userToMatch;
                interestObject[@"venueId"] = self.venueId;
                
                [interestObject saveInBackground];
            }
        }
    }];
}

-(void)checkinUserAtVenue:(NSString*)venueId {
    PFObject* checkinObject = [PFObject objectWithClassName:@"CheckIn"];
    PFUser* currentUser = [PFUser currentUser];
    checkinObject[@"checkedInUser"] = currentUser;
    checkinObject[@"venueId"] = venueId;
    checkinObject[@"checkinTime"] = [NSDate date];
    checkinObject[@"gender"] = [currentUser objectForKey:@"gender"];
    checkinObject[@"interestedIn"] = [currentUser objectForKey:@"interestedIn"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [checkinObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(succeeded){
            NSLog(@"Successful checkin");
            self.checkinButton.enabled = NO;
            [self.cache checkInToVenue:self.venueId];
            self.interestedUsers = [self.cache interestedInUsersAtVenue:self.venueId];
            self.hasCheckedIn = YES;
            self.collectionView.backgroundView = nil;
            [self refreshCollectionView];
            
        }
        else {
            NSLog(@"Failed to checkin");
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Check-In Error" message:@"There was an error while trying to check in. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

-(void)setupBackgroundView {
    UIView* bgView = [[UIView alloc] initWithFrame:self.collectionView.frame];
    UIFont* font = [UIFont boldSystemFontOfSize:26];
    NSString* text = @"Checkin to Reveal Potential Matches";
    
    UILabel* checkinMessage = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.collectionView.frame.size.width, self.collectionView.frame.size.height)];
    checkinMessage.text = text;
    checkinMessage.font = font;
    checkinMessage.numberOfLines = 0;
    checkinMessage.textColor = [UIColor lightGrayColor];
    checkinMessage.textAlignment = NSTextAlignmentCenter;
    [checkinMessage sizeToFit];
    checkinMessage.center = bgView.center;
    
    [bgView addSubview:checkinMessage];
    bgView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundView = bgView;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat collectionViewWidth = collectionView.frame.size.width;
    CGFloat equalSpacing = (collectionViewWidth-CELLS_PER_ROW*CELL_WIDTH)/(CELLS_PER_ROW+1);
    return UIEdgeInsetsMake(10,equalSpacing,10,equalSpacing);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
