//
//  NMLocationSelectionViewController.m
//  Never Missed
//
//  Created by William Emmanuel on 11/26/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMLocationSelectionViewController.h"
#import "NMGPSConnection.h"
#import "NMConnectionAttributesViewController.h"

@interface NMLocationSelectionViewController ()

@end

@implementation NMLocationSelectionViewController {
    CLLocationManager *_locationManager;
    MKPointAnnotation *_point;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapView.delegate = self;
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    [_locationManager setDistanceFilter:kCLDistanceFilterNone];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.mapView setShowsUserLocation:YES];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.mapView addGestureRecognizer:longPressGesture];
    [_continueButton setTarget:self];
    [_continueButton setAction:@selector(didPressContinue)];
}

-(void)didPressContinue {
    if(_point == nil) {
        UIAlertView *noPin = [[UIAlertView alloc] initWithTitle:@"No Pin Dropped" message:@"Please long press the map to set a connection location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [noPin show];
    } else {
        NMGPSConnection *connection = [[NMGPSConnection alloc] init];
        CLLocation *temp = [[CLLocation alloc] initWithLatitude:_point
                            .coordinate.latitude longitude:_point.coordinate.longitude];
        connection.location = temp;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NMConnectionAttributesViewController *myVC = (NMConnectionAttributesViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ConnectionAttributesViewController"];
        myVC.connection = connection;
        [self.navigationController pushViewController:myVC animated:YES];
    }
}

-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
    if (sender.state != UIGestureRecognizerStateBegan)
        return;
    CGPoint touchPoint = [sender locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    if(_point == nil)
        _point = [[MKPointAnnotation alloc] init];
    _point.coordinate = touchMapCoordinate;
    [self.mapView addAnnotation:_point];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *annotationView = [views objectAtIndex:0];
    id<MKAnnotation> mp = [annotationView annotation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate] ,250,250);
    [mv setRegion:region animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end
