//
//  NMTrainPublicBoardTableViewController.m
//  NeverMissed
//
//  Created by Tom Mignone on 5/18/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import <Parse/Parse.h>
#import "NMTrainPublicBoardTableViewController.h"
#import "NMChatViewController.h"
#import "NMMatchTableViewCell.h"
#import "NMConnectionModalViewController.h"
#import "NMTrainPublicBoardTableViewCell.h"
#import "NMPublicTrainConnectionDetailsViewController.h"
#import "MBProgressHUD.h"


@interface NMTrainPublicBoardTableViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@end


@implementation NMTrainPublicBoardTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    hud.labelText = @"Loading";
    hud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0];
    
    _connectionArray = [[NSMutableArray alloc] init];

    
    UIRefreshControl *refresh = [UIRefreshControl new];
    self.refreshControl = refresh;
    [self.refreshControl setTintColor:[UIColor grayColor]];
    [self.refreshControl addTarget:self action:@selector(refreshPulled) forControlEvents:UIControlEventValueChanged];
    
    [self loadTrainConnections];
}


-(void)refreshPulled {
    _connectionArray = [[NSMutableArray alloc] init];
    [self loadTrainConnections];
    
}

-(void) loadTrainConnections{
    [_connectionArray removeAllObjects];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Posting"];
    [query whereKey:@"type" equalTo:@"train"]; 
    
    [query whereKey:@"public" equalTo:@YES];
    [query includeKey:@"postedBy"];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *connections, NSError *error) {
        //Add each public connection to the array
        for (PFObject *connection in connections) {
            [_connectionArray addObject:connection];
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
        [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_connectionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"DescriptionCell";
    NMTrainPublicBoardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if(cell == nil) {
        cell = [[NMTrainPublicBoardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    // PFUser *otherUser = [_connectionUserArray objectAtIndex:[indexPath row]];
    PFObject *connection = [_connectionArray objectAtIndex:[indexPath row]];
    PFUser *userPostingConnection = [connection objectForKey:@"postedBy"];
    NSString *targetGender = [userPostingConnection objectForKey:@"interestedIn"];
    NSString *posterGender = [userPostingConnection objectForKey:@"gender"];
    if ([targetGender isEqualToString:@"male"])
    {
        targetGender = @"Male";
    }
    else targetGender = @"Female";
    if ([posterGender isEqualToString:@"male"])
    {
        posterGender = @"Male";
    }
    else posterGender = @"Female";
    
    NSDate *postedAt = [connection createdAt];
    NSString *time = [self timeAgo:postedAt];
    
    NSString *railway = [connection objectForKey:@"railway"];
    NSString *trainNo = [connection objectForKey:@"trainNo"];
    NSString *connectionDetails = [NSString stringWithFormat:@"%@ seeking %@ on %@ %@ posted %@ ago", posterGender, targetGender, railway, trainNo, time];
    
    cell.descriptionLabel.text = connectionDetails;
    
    return cell;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return NULL;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *selectedConnection = [_connectionArray objectAtIndex:[indexPath row]];
    
    NMPublicTrainConnectionDetailsViewController *connectionDetailsVewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PublicTrainConnectionDetailsView"];
    connectionDetailsVewController.connection = selectedConnection;
    [self.navigationController pushViewController:connectionDetailsVewController animated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self loadNearbyConnections];
    //[self.tableView reloadData];
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

@end
