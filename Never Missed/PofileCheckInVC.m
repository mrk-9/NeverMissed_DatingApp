//
//  PofileCheckInVC.m
//  NeverMissed
//
//  Created by QTS Coder on 20/08/2018.
//  Copyright © 2018 William Emmanuel. All rights reserved.
//

#import "PofileCheckInVC.h"
#import "PersonCheckInCollect.h"
#import "UIView+RoundedCorners.h"
#import "DataLocal.h"
#import "ProfileObj.h"
#import "SliceImageCollect.h"
@interface PofileCheckInVC ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray *arrProfiles;
    __weak IBOutlet UILabel *lblName;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionVIew;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UIView *viewProfile;
@property (weak, nonatomic) IBOutlet UICollectionView *cltSliceImage;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation PofileCheckInVC

- (void)viewDidLoad {
    self.lblLocation.text = self.venueName;
    [self scaleViewProfile];
    [super viewDidLoad];
    arrProfiles = [DataLocal arrProfile];
    // Do any additional setup after loading the view.
}


- (void)scaleViewProfile
{
    _pageControl.transform = CGAffineTransformMakeRotation(M_PI /2 );
    
    lblName.text = _profileObj.name;
    _viewProfile.layer.cornerRadius = 10.0;
    _viewProfile.layer.masksToBounds = true;
    self.viewProfile.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:0.5 animations:^{
        self.viewProfile.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        
    }];
    _pageControl.numberOfPages = _profileObj.numberImage;
    
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
    if (collectionView == _cltSliceImage)
    {
        return _profileObj.numberImage;
    }
    return arrProfiles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _cltSliceImage)
    {
         SliceImageCollect *collect = (SliceImageCollect *)[self.cltSliceImage dequeueReusableCellWithReuseIdentifier:@"SliceImageCollect" forIndexPath:indexPath];
        if (_profileObj.numberImage == 2)
        {
            if (indexPath.row == 0)
            {
                collect.imgProfile.image = [UIImage imageNamed:@"profile"];
            }
            else if (indexPath.row == 1)
            {
                collect.imgProfile.image = [UIImage imageNamed:@"nt1"];
            }
        }
        else
        {
            if (indexPath.row == 0)
            {
                collect.imgProfile.image = [UIImage imageNamed:@"profile2"];
            }
            else if (indexPath.row == 1)
            {
                collect.imgProfile.image = [UIImage imageNamed:@"nt1"];
            }
            else if (indexPath.row == 2)
            {
                collect.imgProfile.image = [UIImage imageNamed:@"nt2"];
            }
            else{
                collect.imgProfile.image = [UIImage imageNamed:@"nt3"];
            }
        }
        return collect;
    }
    PersonCheckInCollect *collect = (PersonCheckInCollect *)[self.collectionVIew dequeueReusableCellWithReuseIdentifier:@"PersonCheckInCollect" forIndexPath:indexPath];
    [collect registerCollect];
    collect.btnAvatar.tag = indexPath.row;
    [collect.btnAvatar addTarget:self action:@selector(clickAvatar:) forControlEvents:UIControlEventTouchUpInside];
    ProfileObj *obj = arrProfiles[indexPath.row];
    collect.lblName.text = obj.name;
    [collect.btnAvatar setImage:[UIImage imageNamed:obj.image] forState:UIControlStateNormal];
    if (indexPath.row == _indexSelected)
    {
        collect.btnAvatar.layer.borderWidth = 2.0;
        collect.btnAvatar.layer.borderColor = [UIColor colorWithRed: 0.0f/255.0f
                                                              green:81.0f/255.0f
                                                               blue:81.0f/255.0f
                                                              alpha:1.0f].CGColor;
    }
    else{
        collect.btnAvatar.layer.borderWidth = 2.0;
        collect.btnAvatar.layer.borderColor = [UIColor clearColor].CGColor;
    }
    return  collect;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _cltSliceImage)
    {
         return CGSizeMake(_cltSliceImage.frame.size.width, _cltSliceImage.frame.size.height);
    }
    return CGSizeMake(75, 120);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = _cltSliceImage.frame.size.height;
    float currentPage = _cltSliceImage.contentOffset.y / pageWidth;
    
    if (0.0f != fmodf(currentPage, 1.0f))
    {
        _pageControl.currentPage = currentPage + 1;
    }
    else
    {
        _pageControl.currentPage = currentPage;
    }
    
}

- (void)clickAvatar:(UIButton *)btn
{
    [UIView animateWithDuration:0.25 animations:^{
        _cltSliceImage.alpha = 0.0;
        lblName.alpha  = 0.0;
    } completion:^(BOOL finished) {
        ProfileObj *obj = arrProfiles[btn.tag];
        _indexSelected = btn.tag;
        _profileObj = obj;
        _pageControl.numberOfPages = _profileObj.numberImage;
        _pageControl.currentPage = 0;
        [_cltSliceImage setContentOffset:CGPointZero];
        [_cltSliceImage reloadData];
        [_collectionVIew reloadData];
        //imgProfile.image = [UIImage imageNamed:obj.image];
        lblName.text = obj.name;
        [UIView animateWithDuration:0.25 animations:^{
            _cltSliceImage.alpha = 1.0;
            lblName.alpha  = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }];
}
@end
