//
//  NMConnectionsTableViewController.m
//  Never Missed
//
//  Created by Tom Mignone on 11/19/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//
#import <Parse/Parse.h>
#import "NMConnectionsTableViewController.h"
#import "NMChatViewController.h"
#import "NMMatchTableViewCell.h"
#import "NMConnectionModalViewController.h"
#import "NMEditConnectionAttributesViewController.h"
#import "NMPublishedConnectionTableViewCell.h"
#import "NMNotPaidForModalViewController.h"
#import "MBProgressHUD.h"

static const int SEVEN_DAY_AGO_SECONDS = -604800;

@interface NMConnectionsTableViewController ()

@property (strong, nonatomic) NSIndexPath* indexToDelete;

-(void)confirmDeleteWithIndexPath:(NSIndexPath*)indexToDelete;

@end

@implementation NMConnectionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    hud.labelText = @"Loading";
    hud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0];
    
    _connectionUserArray = [[NSMutableArray alloc] init];
    _connectionArray = [[NSMutableArray alloc] init];
    _unmatchedRequests = [[NSMutableArray alloc] init];
    
    [self.segmentedControl addTarget:self
                         action:@selector(segmentControlValueChanged:)
               forControlEvents:UIControlEventValueChanged];
    
    _unmatchedRequestsAreLoading = NO;
    _connectionsAreLoading = NO;
    
}

-(void)refreshPulled {
    if (_unmatchedRequestsAreLoading || _connectionsAreLoading)
        return;
    if(self.segmentedControl.selectedSegmentIndex == 0) {
        [self loadConnections];
    } else {
        [self loadUnmatchedRequests];
    }
}

-(void) loadConnections{
    _connectionsAreLoading = YES;
    [_connectionArray removeAllObjects];
    [_connectionUserArray removeAllObjects];
    //Save id of the current user
    PFUser *user = [PFUser currentUser];
    NSString *currentUserID = user.objectId;
    
    NSDate* now = [NSDate date];
    NSDate* sevenDaysAgo = [now dateByAddingTimeInterval:SEVEN_DAY_AGO_SECONDS];
    
    //Create subqueries
    PFQuery *user1Query = [PFQuery queryWithClassName:@"Connection"];
    [user1Query whereKey:@"user1" equalTo:[PFUser currentUser]];
    PFQuery *user2Query = [PFQuery queryWithClassName:@"Connection"];
    [user2Query whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    //Create main query with constraints
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[user1Query, user2Query]];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:sevenDaysAgo];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"user1"];
    [query includeKey:@"user2"];
    
    //Query for all connections involving the currentUser
    [query findObjectsInBackgroundWithBlock:^(NSArray *connections, NSError *error) {
        //For each connection same the user object for the other user
        for (PFObject *connection in connections) {
            [_connectionArray addObject:connection];
            PFUser *user1 = [connection objectForKey:@"user1"];
            PFUser *user2 = [connection objectForKey:@"user2"];
            if([user1.objectId isEqualToString:currentUserID]){
                [_connectionUserArray addObject:user2];
                NSLog(@"Added user %@ to connection list", user2[@"name"]);
            }
            else if([user2.objectId isEqualToString:currentUserID]){
                [_connectionUserArray addObject:user1];
                NSLog(@"Added user %@ to connection list", user2[@"name"]);
            }
            else NSLog(@"Error occurred");
            [self.tableView reloadData];
            //[self.refreshControl endRefreshing];
            _connectionsAreLoading = NO;
        }
        [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }];
}

-(void)loadUnmatchedRequests {
    if(!_unmatchedRequestsAreLoading){
        _unmatchedRequestsAreLoading = YES;
        [_unmatchedRequests removeAllObjects];
    
        //query for pending GPS connections
        NSDate* now = [NSDate date];
        NSDate* sevenDaysAgo = [now dateByAddingTimeInterval:SEVEN_DAY_AGO_SECONDS];
        
        PFQuery *getUnmatchedGPSRequests = [PFQuery queryWithClassName:@"Posting"];
        [getUnmatchedGPSRequests whereKey:@"createdAt" greaterThanOrEqualTo:sevenDaysAgo];
        [getUnmatchedGPSRequests whereKey:@"type" equalTo:@"gps"];
        [getUnmatchedGPSRequests whereKey:@"postedBy" equalTo:[PFUser currentUser]];
        [getUnmatchedGPSRequests findObjectsInBackgroundWithTarget:self selector:@selector(unmatchedGPSConnectionReturn:error:)];
    }
}
-(void)unmatchedGPSConnectionReturn:(id)result error:(NSError *)error {
    if(result == nil) {
        // error catching
        return;
    }
    for(PFObject *unmatchedRequestResult in (NSArray*)result) {
        NMConnection *unmatchedConnection;
            unmatchedConnection = [[NMGPSConnection alloc] initWithParseObject:unmatchedRequestResult];
            unmatchedConnection.connectionType = @"GPS Connection";
        [_unmatchedRequests addObject:unmatchedConnection];
    }
    
    NSDate* now = [NSDate date];
    NSDate* sevenDaysAgo = [now dateByAddingTimeInterval:SEVEN_DAY_AGO_SECONDS];
    
    PFQuery *getUnmatchedTrainRequests = [PFQuery queryWithClassName:@"Posting"];
    [getUnmatchedTrainRequests whereKey:@"createdAt" greaterThanOrEqualTo:sevenDaysAgo];
    [getUnmatchedTrainRequests whereKey:@"type" equalTo:@"train"];
    [getUnmatchedTrainRequests whereKey:@"postedBy" equalTo:[PFUser currentUser]];
    [getUnmatchedTrainRequests findObjectsInBackgroundWithTarget:self selector:@selector(unmatchedTrainConnectionReturn:error:)];
    [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}

-(void)unmatchedTrainConnectionReturn:(id)result error:(NSError *)error {
    if(result == nil) {
        // error catching
        return;
    }
    for(PFObject *unmatchedRequestResult in (NSArray*)result) {
        NMConnection *unmatchedConnection;
        unmatchedConnection = [[NMTrainConnection alloc] initWithParseObject:unmatchedRequestResult];
        unmatchedConnection.connectionType = @"Train Connection";
        
        [_unmatchedRequests addObject:unmatchedConnection];
    }
    
    NSDate* now = [NSDate date];
    NSDate* sevenDaysAgo = [now dateByAddingTimeInterval:SEVEN_DAY_AGO_SECONDS];
    
    PFQuery *getUnmatchedPlaneRequests = [PFQuery queryWithClassName:@"Posting"];
    [getUnmatchedPlaneRequests whereKey:@"createdAt" greaterThanOrEqualTo:sevenDaysAgo];
    [getUnmatchedPlaneRequests whereKey:@"type" equalTo:@"plane"]; 
    [getUnmatchedPlaneRequests whereKey:@"postedBy" equalTo:[PFUser currentUser]];
    [getUnmatchedPlaneRequests findObjectsInBackgroundWithTarget:self selector:@selector(unmatchedPlaneConnectionReturn:error:)];
        NSLog(@"Train Complete");
}


-(void)unmatchedPlaneConnectionReturn:(id)result error:(NSError *)error {
    if(result == nil) {
        // error catching
        return;
    }
    //[_unmatchedRequests removeAllObjects];
    for(PFObject *unmatchedRequestResult in (NSArray*)result) {
        NMConnection *unmatchedConnection;
        unmatchedConnection = [[NMPlaneConnection alloc] initWithParseObject:unmatchedRequestResult];
        unmatchedConnection.connectionType = @"Plane Connection";
        
        [_unmatchedRequests addObject:unmatchedConnection];
    }
    // could be an issue if one does not return
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [_unmatchedRequests sortedArrayUsingDescriptors:sortDescriptors];
    
    _unmatchedRequests = [sortedArray mutableCopy];
    
    //Check the query count so you know when you are done with all 3
    //[self.refreshControl endRefreshing];
    [self.tableView reloadData];
    NSLog(@"Plane Complete");
    _unmatchedRequestsAreLoading = NO;
    NSLog(_unmatchedRequestsAreLoading ? @"Yes" : @"No");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.segmentedControl.selectedSegmentIndex == 0){
    return 1;
    }
    else return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.segmentedControl.selectedSegmentIndex == 0)
        return [_connectionUserArray count];
    else  {
        return [_unmatchedRequests count];
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_segmentedControl.selectedSegmentIndex == 0) {
        static NSString *cellIdentifier = @"MatchedCell";
        NMMatchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if(cell == nil) {
            cell = [[NMMatchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        PFUser *otherUser = [_connectionUserArray objectAtIndex:[indexPath row]];
        PFObject *connection = [_connectionArray objectAtIndex:[indexPath row]];
        cell.nameLabel.text = [otherUser objectForKey:@"name"];
        PFFile *thumbnail = [otherUser objectForKey:@"profilePicture"];
        NSData *imageData = [thumbnail getData];
        UIImage *image = [UIImage imageWithData:imageData];
        
        cell.profileImage.contentMode = UIViewContentModeScaleAspectFill;
        CALayer *imageLayer = cell.profileImage.layer;
        [imageLayer setCornerRadius:30];
        [imageLayer setMasksToBounds:YES];
        [cell.profileImage setImage:image];
        
        NSString *matchedAt = [self timeAgo:connection.createdAt];
        if(connection[@"lastMessage"] != NULL){
            cell.matchDateLabel.text = connection[@"lastMessage"];
        }
        else{
            cell.matchDateLabel.text = [NSString stringWithFormat:@"Matched %@ ago", matchedAt];
        }
        return cell;
    } else {
        static NSString *cellIdentifier2 = @"UnmatchedCell";
        NMPublishedConnectionTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:cellIdentifier2 forIndexPath:indexPath];
        if(cell == nil) {
            cell = [[NMPublishedConnectionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        }
        if(_unmatchedRequestsAreLoading == NO){
        NMConnection *unmatched = [_unmatchedRequests objectAtIndex:indexPath.row];
        cell.hatLabel.text = (unmatched.hat ? @"YES" : @"NO");
        NSString *labelText = [NSString stringWithFormat:@"Posted %@ ago", [self timeAgo:unmatched.pfobject.createdAt]];
            cell.connectionDateLabel.text = labelText;
            cell.connectionTypeLabel.text = unmatched.connectionType;
            
            if([unmatched.connectionType isEqualToString:@"Plane Connection"]){
                cell.connectionTypeIcon.image = [UIImage imageNamed:@"plane.png"];
            }
            else if([unmatched.connectionType isEqualToString:@"Train Connection"]){
                cell.connectionTypeIcon.image = [UIImage imageNamed:@"train.png"];
            }
            else if([unmatched.connectionType isEqualToString:@"GPS Connection"]){
                cell.connectionTypeIcon.image = [UIImage imageNamed:@"map.png"];
            }
        }
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    return NULL;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_segmentedControl.selectedSegmentIndex == 0) {
        PFObject *selectedConnection = [_connectionArray objectAtIndex:[indexPath row]];
        PFUser *selectedUser = [_connectionUserArray objectAtIndex:[indexPath row]];
        PFUser *current = [PFUser currentUser];
        [current fetchIfNeeded];
        if([[selectedUser objectForKey:@"subscribed"] intValue] == 1) {
            [selectedConnection setObject:@YES forKey:@"paidFor"];
            [selectedConnection saveEventually];
        }
        else if ([[current objectForKey:@"subscribed"] intValue] == 1) {
            [selectedConnection setObject:@YES forKey:@"paidFor"];
            [selectedConnection saveEventually];
        }
        if([[selectedConnection objectForKey:@"paidFor"] intValue] == 1) {
            NMChatViewController * chatViewController = [[NMChatViewController alloc] initWithNibName:nil bundle:nil];
            chatViewController.connection = selectedConnection;
            chatViewController.connectionUser = selectedUser;
            NSLog(@"Object ID%@",selectedConnection.objectId);
            [self.navigationController pushViewController:chatViewController animated:YES];
        } else {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            NMNotPaidForModalViewController *npvc = (NMNotPaidForModalViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NotPaidForViewController"];
            npvc.connection = selectedConnection;
            npvc.connectedUser = selectedUser;
            [self.navigationController presentViewController:npvc animated:YES completion:nil];
        }
    }
    if (_segmentedControl.selectedSegmentIndex == 1){
        NMConnection *selectedConnection = [_unmatchedRequests objectAtIndex:[indexPath row]];
        NMEditConnectionAttributesViewController *connectionDetailsVewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditConnectionDetailsView"];
        connectionDetailsVewController.connection = selectedConnection;
        [self.navigationController pushViewController:connectionDetailsVewController animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSLog(@"Delete");
        [self confirmDeleteWithIndexPath:indexPath];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //For the moment on make connected matches editable.
    if (_segmentedControl.selectedSegmentIndex == 0){
        return YES;
    }
    else {
        return  NO;
    }
}

- (IBAction)segmentControlValueChanged:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    hud.labelText = @"Loading";
    hud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0];
    if(self.segmentedControl.selectedSegmentIndex == 0)
        [self loadConnections];
    else
        [self loadUnmatchedRequests];
    // reload data based on the new index
    [self.tableView reloadData];
    // reset the scrolling to the top of the table view
    if ([self tableView:self.tableView numberOfRowsInSection:0] > 0) {
        NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:topIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

-(NSString *)timeAgo:(NSDate*)date {
    NSDate *todayDate = [NSDate date];
    double ti = [date timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if (ti < 1) {
        return @"1 sec";
    } else if (ti < 60) {
        return @"1 min";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        if(diff == 1){
            return [NSString stringWithFormat:@"%d hours", diff];
        }
        return[NSString stringWithFormat:@"%d hours", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        if(diff == 1){
            return [NSString stringWithFormat:@"%d day", diff];
        }
        return[NSString stringWithFormat:@"%d days", diff];
    } else if (ti < 31556926) {
        int diff = round(ti / 60 / 60 / 24 / 30);
        if (diff == 1) {
            return [NSString stringWithFormat:@"%d month", diff];
        }
        return [NSString stringWithFormat:@"%d months", diff];
    } else {
        int diff = round(ti / 60 / 60 / 24 / 30 / 12);
        if(diff == 1){
            return [NSString stringWithFormat:@"%d year", diff];
        }
        return [NSString stringWithFormat:@"%d years", diff];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadConnections];
    [self loadUnmatchedRequests];
    [self.tableView reloadData];
}

#pragma mark - Private Implementation Methods

-(void)confirmDeleteWithIndexPath:(NSIndexPath*)indexToDelete{
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure you want to permanently delete this match?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.tableView beginUpdates];
        PFObject* connection = [self.connectionArray objectAtIndex:indexToDelete.row];
        [self.connectionArray removeObjectAtIndex:indexToDelete.row];
        [self.connectionUserArray removeObjectAtIndex:indexToDelete.row];
        [connection deleteEventually];
        [self.tableView deleteRowsAtIndexPaths:@[indexToDelete] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
