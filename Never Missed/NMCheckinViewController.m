//
//  NMCheckinViewController.m
//  NeverMissed
//
//  Created by Aaron Preston on 4/18/16.
//  Copyright © 2016 William Emmanuel. All rights reserved.
//

#import "NMCheckinViewController.h"
#import "FSVenue.h"
#import "Foursquare2.h"
#import "FSConverter.h"
#import <Parse/Parse.h>
#import "NMCheckedInCollectionViewController.h"
#import "MBProgressHUD.h"
#import "CheckInUserVC.h"
@import CoreLocation;

@interface NMCheckinViewController () <CLLocationManagerDelegate, UISearchResultsUpdating, UISearchControllerDelegate>

@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSArray* venues;
@property (strong, nonatomic) CLLocation* location;
@property (strong, nonatomic) NSDictionary* results;
@property (strong, nonatomic) NSMutableSet* currentConnections;
@property (strong, nonatomic) UISearchController *searchController;
@property (nonatomic, weak) NSOperation* lastSearchOperation;

-(void)searchFSWithString:(NSString*)venue;

@end

@implementation NMCheckinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Locations";
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];
    
    //Setup search controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    
    // Make sure the that the search bar is visible within the navigation bar.
    [self.searchController.searchBar sizeToFit];
    
    // Include the search controller's search bar within the table's header view.
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    //Grab current user's connections
    self.currentConnections = [[NSMutableSet alloc] init];
    
    PFQuery* user1Query = [PFQuery queryWithClassName:@"Connection"];
    [user1Query whereKey:@"user1" equalTo:[PFUser currentUser]];
    PFQuery* user2Query = [PFQuery queryWithClassName:@"Connection"];
    [user2Query whereKey:@"user2" equalTo:[PFUser currentUser]];
    PFQuery* connectionsQuery = [PFQuery orQueryWithSubqueries:@[user1Query,user2Query]];
    [connectionsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error == nil) {
            NSLog(@"results:%@",objects);
            for(PFObject* connection in objects) {
                PFObject* user1 = connection[@"user1"];
                PFObject* user2 = connection[@"user2"];
                if([user1.objectId isEqualToString:[PFUser currentUser].objectId]){
                    [self.currentConnections addObject:user2.objectId];
                }
                else {
                    [self.currentConnections addObject:user1.objectId];
                }
            }
            NSLog(@"currentConnections:%@",self.currentConnections);
        }
    }];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
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

    return self.venues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckinVenueCell" forIndexPath:indexPath];
    
    // Configure the cell...
    FSVenue* venue = [self.venues objectAtIndex:indexPath.row];
    cell.textLabel.text = venue.name;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.searchController.active){
        self.searchController.active = NO;
    }
    FSVenue* venue = [self.venues objectAtIndex:indexPath.row];
    PFUser* currentUser = [PFUser currentUser];
    NSLog(@"Selected:%@, %@, %@",venue.name, venue.venueId, [currentUser objectForKey:@"gender"]);
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
     CheckInUserVC* checkedInUsersViewController = (CheckInUserVC*)[storyboard instantiateViewControllerWithIdentifier:@"CheckInUserVC"];
//    NMCheckedInCollectionViewController* checkedInUsersViewController = (NMCheckedInCollectionViewController*)[storyboard instantiateViewControllerWithIdentifier:@"NMCheckedInCollectionViewController"];
    checkedInUsersViewController.venueId = venue.venueId;
    checkedInUsersViewController.venueName = venue.name;
    checkedInUsersViewController.currentConnections = self.currentConnections;
    checkedInUsersViewController.genderInterest = [currentUser objectForKey:@"interestedIn"];
    
    [self.navigationController pushViewController:checkedInUsersViewController animated:YES];
    
}

#pragma mark - UISearchResultsUpdating Methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchText = searchController.searchBar.text;
    [self searchFSWithString:searchText];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.locationManager stopUpdatingLocation];
    self.location = locations.lastObject;
    NSLog(@"location: %f,%f",self.location.coordinate.latitude, self.location.coordinate.longitude);
    [self searchFSWithString:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"locationManager:didFailWithError");
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Private Implementation

-(void)searchFSWithString:(NSString*)venue{
    [self.lastSearchOperation cancel];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.lastSearchOperation = [Foursquare2
                                venueSearchNearByLatitude:@(self.location.coordinate.latitude)
                                longitude:@(self.location.coordinate.longitude)
                                query:venue
                                limit:nil
                                intent:intentCheckin
                                radius:@(402)
                                categoryId:nil
                                callback:^(BOOL success, id result){
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    if (success) {
                                        NSDictionary* results = (NSDictionary*)result;
                                        _venues = [results valueForKeyPath:@"response.venues"];
                                        FSConverter *converter = [[FSConverter alloc] init];
                                        _venues = [converter convertToObjects:_venues];
                                        [self.tableView reloadData];
                                        
                                    } else {
                                        NSLog(@"%@",result);
                                    }
                                    
                                }];
}



@end
