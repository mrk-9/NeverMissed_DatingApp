//
//  NMPublicBoardTableViewController.m
//  NeverMissed
//
//  Created by Tom Mignone on 5/18/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//

#import <Parse/Parse.h>
#import "NMPublicBoardTableViewController.h"
#import "NMChatViewController.h"
#import "NMMatchTableViewCell.h"
#import "NMConnectionModalViewController.h"
#import "NMEditConnectionAttributesViewController.h"
#import "NMPublicBoardLocationTableViewCell.h"
#import "NMNotPaidForModalViewController.h"
#import "NMPublicBoardTableViewController.h"
#import "NMPublicLocationConnectionDetailsViewController.h"

@interface NMPublicBoardTableViewController ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@end


@implementation NMPublicBoardTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.location = [[CLLocation alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 10.0;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [self.locationManager requestWhenInUseAuthorization];
    }
    else{
        if([CLLocationManager authorizationStatus]== kCLAuthorizationStatusDenied ){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                                            message:@"Please enable location services in your device settings to use the venue search feature."
                                                           delegate:self
                                                  cancelButtonTitle:@"Confirm"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    if(self.publicLocationCoordinates == nil){
        [self.locationManager startUpdatingLocation];
    }
    //[self loadNearbyConnections];
    
    _connectionArray = [[NSMutableArray alloc] init];
    _connectionDetailsArray = [[NSMutableArray alloc] init];
    
    UIRefreshControl *refresh = [UIRefreshControl new];
    self.refreshControl = refresh;
    [self.refreshControl setTintColor:[UIColor grayColor]];
    [self.refreshControl addTarget:self action:@selector(refreshPulled) forControlEvents:UIControlEventValueChanged];
    
    // [self loadConnections];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    self.location = newLocation;
    _connectionArray = [[NSMutableArray alloc] init];
    _connectionDetailsArray = [[NSMutableArray alloc] init];

    [self loadNearbyConnections];
    
    [self.tableView reloadData];
    NSLog(@"Latitude:%f Longitude:%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
}

-(void)refreshPulled {
    _connectionArray = [[NSMutableArray alloc] init];
    _connectionDetailsArray = [[NSMutableArray alloc] init];
    [self loadNearbyConnections];
    
}

-(void) loadNearbyConnections{
    [_connectionArray removeAllObjects];
    [_connectionDetailsArray removeAllObjects];
    //Save id of the current user
    //PFUser *user = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Posting"];
    [query whereKey:@"type" equalTo:@"gps"]; 
    if(_publicLocationCoordinates == nil){
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude longitude:self.location.coordinate.longitude];
        [query whereKey:@"location" nearGeoPoint:geoPoint withinMiles:50.0];
    }
    else{
        [query whereKey:@"location" nearGeoPoint:_publicLocationCoordinates withinMiles:50.0];
    }
    
    [query whereKey:@"public" equalTo:@YES];
    [query includeKey:@"postedBy"];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *connections, NSError *error) {
        //Add each public connection to the array
        for (PFObject *connection in connections) {
            [_connectionArray addObject:connection];
            

            
           // [_connectionDetailsArray addObject:connectionDetails];
            
            [self.tableView reloadData];
            
        }
        [self.refreshControl endRefreshing];
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
        NMPublicBoardLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if(cell == nil) {
            cell = [[NMPublicBoardLocationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
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
    
        NSString *hairColor = [[connection objectForKey:@"hairColor"]  lowercaseString];
        NSString *clothingColor = [[connection objectForKey:@"clothingColor"] lowercaseString];
        NSDate *postedAt = [connection createdAt];
        NSString *time = [self timeAgo:postedAt];
        NSString *connectionDetails = [NSString stringWithFormat:@"%@ seeking %@ with %@ hair and %@ clothing posted %@ ago", posterGender, targetGender, hairColor, clothingColor, time];

        cell.descriptionLabel.text = connectionDetails;

        return cell;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return NULL;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *selectedConnection = [_connectionArray objectAtIndex:[indexPath row]];
    
    NMPublicLocationConnectionDetailsViewController *connectionDetailsVewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PublicLocationConnectionDetailsView"];
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
