//
//  NMVenueSearchViewController.m
//  Never Missed
//
//  Created by William Emmanuel on 8/27/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMVenueSearchViewController.h"
#import "FSVenue.h"
#import "Foursquare2.h"
#import "FSConverter.h"
#import "NMGPSConnection.h"
#import "NMConnectionAttributesViewController.h"

@interface NMVenueSearchViewController ()
//<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchDisplayDelegate>

@property (strong, nonatomic) NSArray *venues;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSDictionary *dic;
@property (strong, nonatomic) UISearchController* searchController;
@property (strong, nonatomic) UISearchDisplayController* iOS7SearchController;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, weak) NSOperation *lastSearchOperation;

@end

@implementation NMVenueSearchViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    if(NSClassFromString(@"UISearchController")) {
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
    
    if(NSClassFromString(@"UISearchController")) {
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.searchController.searchResultsUpdater = self;
        self.searchController.delegate = self;
        self.searchController.dimsBackgroundDuringPresentation = NO;
        
        // Make sure the that the search bar is visible within the navigation bar.
        [self.searchController.searchBar sizeToFit];
        
        // Include the search controller's search bar within the table's header view.
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
    else{
        self.searchBar = [[UISearchBar alloc] init];
        self.iOS7SearchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        [self.iOS7SearchController setDelegate:self];
        self.iOS7SearchController.searchResultsDataSource = self;
        self.iOS7SearchController.searchResultsDelegate = self;
        self.searchBar.frame = CGRectMake(0, 0, 0, 38);
        self.tableView.tableHeaderView = self.searchBar;
    }

    
    self.definesPresentationContext = YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self startSearchWithString:searchString];
    
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    self.location = newLocation;
    [self startSearchWithString:nil];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
}

//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    [self startSearchWithString:searchText];
}



- (void)startSearchWithString:(NSString *)string {
    NSLog(@"LOADING AGAIN");
    [self.lastSearchOperation cancel];
    
    self.lastSearchOperation = [Foursquare2
                                venueSearchNearByLatitude:@(self.location.coordinate.latitude)
                                longitude:@(self.location.coordinate.longitude)
                                query:string
                                limit:nil
                                intent:intentCheckin
                                radius:@(5000)
                                categoryId:nil
                                callback:^(BOOL success, id result){
                                    if (success) {
                                        _dic = result;
                                        _venues = [_dic valueForKeyPath:@"response.venues"];
                                        FSConverter *converter = [[FSConverter alloc] init];
                                        _venues = [converter convertToObjects:_venues];
                                        NSLog(@"Venue count: %lu", (unsigned long)[_venues count]);
                                        NSLog(@"%@", _venues);
                                        [self.tableView reloadData];
                                        //[self.searchController.searchResultsController reloadData];
                                    } else {
                                        NSLog(@"%@",result);
                                    }
                             
                                }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.venues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.venues[indexPath.row] name];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FSVenue *selectedVenue = [self.venues objectAtIndex:indexPath.row];
    NMGPSConnection *connection = [[NMGPSConnection alloc] init];
    CLLocation *temp = [[CLLocation alloc] initWithLatitude:selectedVenue.coordinate.latitude longitude:selectedVenue.coordinate.longitude];
    connection.location = temp;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NMConnectionAttributesViewController *myVC = (NMConnectionAttributesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ConnectionAttributesViewController"];
    myVC.connection = connection;
    [self.navigationController pushViewController:myVC animated:YES];
}

/*- (IBAction)doneButtonTapped:(id)sender {
 [self.lastSearchOperation cancel];
 [self dismissViewControllerAnimated:YES completion:nil];
 }*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}
@end
