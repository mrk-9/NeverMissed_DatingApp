//
//  NMPublicBoardSelectionViewController.m
//  NeverMissed
//
//  Created by Tom Mignone on 5/18/15.
//  Copyright (c) 2015 William Emmanuel. All rights reserved.
//
#import "NMPublicBoardTableViewController.h"
#import "NMPublicBoardSelectionViewController.h"

@implementation NMPublicBoardSelectionViewController
- (IBAction)launchNewYorkBoard:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    NMPublicBoardTableViewController *publishedConnectionsView =
    (NMPublicBoardTableViewController *)
    [storyboard instantiateViewControllerWithIdentifier:@"PublishedConnectionView"];
    
    double latitude = 40.7127;
    double longitude = -74.0059;
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
    publishedConnectionsView.publicLocationCoordinates = geoPoint;
    
    [self.navigationController pushViewController:publishedConnectionsView animated:YES];
}
- (IBAction)launchWashingtonDCBoard:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    NMPublicBoardTableViewController *publishedConnectionsView =
    (NMPublicBoardTableViewController *)
    [storyboard instantiateViewControllerWithIdentifier:@"PublishedConnectionView"];
    
    double latitude = 38.9047;
    double longitude = -77.0164;
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:latitude longitude:longitude];
    publishedConnectionsView.publicLocationCoordinates = geoPoint;
    
    [self.navigationController pushViewController:publishedConnectionsView animated:YES];
}
- (IBAction)launchOtherBoard:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    NMPublicBoardTableViewController *publishedConnectionsView =
    (NMPublicBoardTableViewController *)
    [storyboard instantiateViewControllerWithIdentifier:@"PublishedConnectionView"];
    
    //set the Geopoint to nil then we will query current location instead
    publishedConnectionsView.publicLocationCoordinates = nil;
    
    [self.navigationController pushViewController:publishedConnectionsView animated:YES];
}

@end
