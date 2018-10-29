//
//  CheckInUserVC.m
//  NeverMissed
//
//  Created by QTS Coder on 17/08/2018.
//  Copyright © 2018 William Emmanuel. All rights reserved.
//

#import "CheckInUserVC.h"
#import <MapKit/MapKit.h>
#import "PersonCheckInCollect.h"
#import "UIView+RoundedCorners.h"
#import "NaviBack.h"
#import "MyCustomPointAnnotation.h"
#import "MyCustomPinAnnotationView.h"
#import "PofileCheckInVC.h"
#import "DataLocal.h"
#import "ProfileObj.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <QuartzCore/QuartzCore.h>
#import "NMCache.h"
#import "MBProgressHUD.h"
#define IS_IOS11orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)
@interface CheckInUserVC ()<UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate>
{
    NSMutableArray *arrProfiles;
    
}
@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblNameAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblNoteAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblNumberPerson;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *viewAddress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintPersonal;
@property (weak, nonatomic) IBOutlet UIImageView *imgMap;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCheckIn;
@property (strong, nonatomic) NMCache* cache;
@property (assign, nonatomic) BOOL hasCheckedIn;
@property (strong, nonatomic) NSMutableArray* checkedInUsers;
@end

@implementation CheckInUserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    arrProfiles = [DataLocal arrProfile];
    // Do any additional setup after loading the view.
}

- (void)setupView
{
    [_viewAddress setRoundedCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight radius:10.0];
    NaviBack *rootView = [[[NSBundle mainBundle] loadNibNamed:@"NaviBack" owner:self options:nil] objectAtIndex:0];
    [rootView.btnBack addTarget:self action:@selector(clickback) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:rootView];    
    self.navigationItem.leftBarButtonItem = btn;
    CLLocationCoordinate2D BostonCoordinates = CLLocationCoordinate2DMake(42.3601, -71.0589);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(BostonCoordinates, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.MapView regionThatFits:viewRegion];
    [self.MapView setRegion:adjustedRegion animated:YES];
    
    MyCustomPointAnnotation* point1 = [[MyCustomPointAnnotation alloc] init];
    point1.coordinate = CLLocationCoordinate2DMake(42.3601, -71.0589);
    point1.price = 3;
    [self.MapView addAnnotation:point1];
    
    _lblLocation.text = self.venueName;
    
    self.cache = [NMCache sharedCache];
    self.hasCheckedIn = [self.cache hasCheckedInToVenue:self.venueId];
    if(self.hasCheckedIn == NO){
        self.btnCheckIn.enabled = YES;
    }
    else {
        self.btnCheckIn.enabled = false;
    }
    //[self callLoadAllUser];
    //[self refreshCollectionView];
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
    }];
}

- (void)callLoadAllUser
{
    PFUser* currentUser = [PFUser currentUser];
    NSDate* fourHoursAgo = [[NSDate date] dateByAddingTimeInterval:-3600*4];
    PFQuery* query = [PFQuery queryWithClassName:@"CheckIn"];
    [query whereKey:@"venueId" equalTo:self.venueId];
    [query whereKey:@"gender" equalTo:@"male"];
    [query whereKey:@"checkinTime" greaterThanOrEqualTo:fourHoursAgo];
    NSLog(@"interested in:%@, %@",self.genderInterest, self.venueId);
    [query whereKey:@"checkedInUser" notEqualTo:currentUser];
    [query includeKey:@"checkedInUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            NSLog(@"OBJECT C -->%@",objects);
            [self.checkedInUsers removeAllObjects];
            for(PFObject* object in objects){
                PFObject* checkedInUser = object[@"checkedInUser"];
                NSLog(@"CheckedInUser:%@",object[@"checkedInUser"]);
                if(![self.currentConnections containsObject:checkedInUser.objectId]) {
                    [self.checkedInUsers addObject:object];
                }
            }
            NSLog(@"VALUE -->%@", _checkedInUsers);
        }
        else {
            NSLog(@"Error finding objects");
        }
    }];
}

- (void)clickback
{
    [self.navigationController popViewControllerAnimated:true];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return  1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrProfiles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PersonCheckInCollect *collect = (PersonCheckInCollect *)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"PersonCheckInCollect" forIndexPath:indexPath];
    [collect registerCollect];
    collect.btnAvatar.tag = indexPath.row;
    [collect.btnAvatar addTarget:self action:@selector(clickAvatar:) forControlEvents:UIControlEventTouchUpInside];
    ProfileObj *obj = arrProfiles[indexPath.row];
    collect.lblName.text = obj.name;
    [collect.btnAvatar setImage:[UIImage imageNamed:obj.image] forState:UIControlStateNormal];
    
    return  collect;
}


- (void)clickAvatar:(UIButton *)btn
{
    [UIView animateWithDuration:0.75 animations:^{
      
        if (@available(iOS 11.0, *)) {
            self.topConstraintPersonal.constant = [[UIScreen mainScreen] bounds].size.height - (562 + self.view.safeAreaInsets.bottom);
        } else {
            self.topConstraintPersonal.constant = [[UIScreen mainScreen] bounds].size.height - 562;
        }
        self.viewAddress.alpha = 0.0;
        self.MapView.alpha = 0.0;
        self.imgMap.alpha = 0.0;
         [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
       
        PofileCheckInVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PofileCheckInVC"];
        vc.venueName = self.venueName;
        vc.profileObj = self->arrProfiles[btn.tag];
        vc.indexSelected = btn.tag;
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    }];
}

- (MKAnnotationView*)mapView:(MKMapView *)mapView
           viewForAnnotation:(id<MKAnnotation>)annotation
{
    // Don't do anything if it's the user's location point
    if([annotation isKindOfClass:[MKUserLocation class]]) return nil;
    
    // We could display multiple types of point annotations
    if([annotation isKindOfClass:[MyCustomPointAnnotation class]]){
        MyCustomPinAnnotationView* pin = [[MyCustomPinAnnotationView alloc] initWithAnnotation:annotation];
        return pin;
    }
    
    return nil;
}
- (IBAction)doCheckIn:(id)sender {
    [self checkinUserAtVenue:self.venueId];
}
-(void)checkinUserAtVenue:(NSString*)venueId {
    PFObject* checkinObject = [PFObject objectWithClassName:@"CheckIn"];
    PFUser* currentUser = [PFUser currentUser];
    NSLog(@"currentUser --->%@",currentUser);
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
            self.btnCheckIn.enabled = NO;
            [self.cache checkInToVenue:self.venueId];
            self.hasCheckedIn = YES;
            
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

@end
