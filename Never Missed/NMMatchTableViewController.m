//
//  NMMatchTableTableViewController.m
//  Never Missed
//
//  Created by William Emmanuel on 11/18/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMMatchTableViewController.h"


@interface NMMatchTableViewController ()

@end

@implementation NMMatchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _unmatchedRequests = [NSMutableArray new];
    _connections = [NSMutableArray new];
    
    UIRefreshControl *refresh = [UIRefreshControl new];
    self.refreshControl = refresh;
    [self.refreshControl setTintColor:[UIColor grayColor]];
    [self.refreshControl addTarget:self action:@selector(refreshPulled) forControlEvents:UIControlEventValueChanged];
    _unmatchedRequestsAreLoading = NO;
    _connectionsAreLoading = NO;
    [self loadMatchesAndConnections];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)refreshPulled {
    if (_unmatchedRequestsAreLoading || _connectionsAreLoading)
        return;
    // pf query again
}

- (void)loadMatchesAndConnections
{
    _unmatchedRequestsAreLoading = YES;
    _connectionsAreLoading = YES;
    
    PFQuery *getConnectionsUser1 = [PFQuery queryWithClassName:@"Connection"];
    [getConnectionsUser1 whereKey:@"user1" equalTo:[PFUser currentUser]];
    PFQuery *getConnectionsUser2 = [PFQuery queryWithClassName:@"Connection"];
    [getConnectionsUser2 whereKey:@"user2" equalTo:[PFUser currentUser]];
    PFQuery *getConnections = [PFQuery orQueryWithSubqueries:@[getConnectionsUser1,getConnectionsUser2]];
    [getConnections includeKey:@"user1"];
    [getConnections includeKey:@"user2"];
    [getConnections findObjectsInBackgroundWithTarget:self selector:@selector(connectionQueryReturn:error:)];
    

    PFQuery *getUnmatchedRequests = [PFQuery queryWithClassName:@"Posting"];
    [getUnmatchedRequests whereKey:@"type" equalTo:@"gps"];
    [getUnmatchedRequests whereKey:@"postedBy" equalTo:[PFUser currentUser]];
    [getUnmatchedRequests findObjectsInBackgroundWithTarget:self selector:@selector(unmatchedRequestsQueryReturn:error:)];
}

-(void)unmatchedRequestsQueryReturn:(id)result error:(NSError *)error {
    _unmatchedRequestsAreLoading = NO;
    if(result == nil) {
        // error catching
        return;
    }
    [_unmatchedRequests removeAllObjects];
    for(PFObject *unmatchedRequestResult in (NSArray*)result) {
        NMConnection *unmatchedConnection;
        if ([[unmatchedRequestResult objectForKey:@"type"] isEqualToString:@"gps"])  {
            unmatchedConnection = [[NMGPSConnection alloc] initWithParseObject:unmatchedRequestResult];
        } else if ([[unmatchedRequestResult objectForKey:@"type"] isEqualToString:@"gps"]) {
            unmatchedConnection = [[NMPlaneConnection alloc] initWithParseObject:unmatchedRequestResult];
        } // now do the same for trains
    }
    // could be an issue if one does not return
    if(!_connectionsAreLoading)
        [self.tableView reloadData];
}

-(void)connectionQueryReturn:(id)result error:(NSError *)error {
    _connectionsAreLoading = NO;
    if(result == nil) {
        // error catching
        return;
    }
    [_connections removeAllObjects];
    for(PFObject *connectionResult in (NSArray*)result) {
        [_connections addObject:connectionResult];
    }
    // could be an issue if one does not return
    if(!_unmatchedRequestsAreLoading)
        [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section ==0) {
        return [_connections count];
    } else {
        return [_unmatchedRequests count];
    }
}

-(NSString* )tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section ==0) {
        return @"Connections";
    } else {
        return @"Pending requests";
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    if(indexPath.section == 0) {
        //PFObject *connection = [_connections objectAtIndex:indexPath.row];
        cell.textLabel.text = @"A connection here!";
        cell.detailTextLabel.text = @"What a treat";
    } else if (indexPath.section == 1) {
        //NMConnection *unmatchedConnection = [_unmatchedRequests objectAtIndex:indexPath.row];
        cell.textLabel.text = @"Aww an unmatched request";
        cell.detailTextLabel.text = @"so sad";
    }
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
