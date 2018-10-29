//
//  SettingVC.m
//  NeverMissed
//
//  Created by QTS Coder on 23/08/2018.
//  Copyright © 2018 William Emmanuel. All rights reserved.
//

#import "SettingVC.h"
#import "SettingPhotoCollect.h"
#import "NaviBack.h"
#import "MBProgressHUD.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "LXReorderableCollectionViewFlowLayout.h"
#import "NMGPSSingleton.h"
#import "PhotoObj.h"
@interface SettingVC ()<LXReorderableCollectionViewDelegateFlowLayout, LXReorderableCollectionViewDataSource, UIGestureRecognizerDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    CGPoint locationPoint;
    NSMutableArray *arrDatas;
    int indexSave;
    NSIndexPath *indexPathPhoto;
}
@property (weak, nonatomic) IBOutlet UICollectionView *cltPhotos;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightClt;
@property (weak, nonatomic) IBOutlet UISwitch *btnSwitchAwlay;
@property (weak, nonatomic) IBOutlet UILabel *lblPlaceHolder;
@property (weak, nonatomic) IBOutlet UITextView *tvDescription;

@end

@implementation SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    arrDatas = [[NSMutableArray alloc] init];
    indexSave = 1;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setupNavi];
    _cltPhotos.delegate = self;
    _cltPhotos.dataSource = self;
    _heightClt.constant = (([[UIScreen mainScreen] bounds].size.width - 44)/3) * 2;
    [self addDonekeyboard];
    _tvDescription.textContainer.maximumNumberOfLines = 3;
    [self checkPhotoByUser];
    
    NSLog(@"-->%@",[PFUser currentUser]);
    if ([[PFUser currentUser] valueForKey:@"bio"]) {
        _tvDescription.text = [[PFUser currentUser] valueForKey:@"bio"];
        _lblPlaceHolder.hidden = true;
    }
    else{
        _lblPlaceHolder.hidden = false;
    }
}

- (void) checkPhotoByUser
{
    PFQuery* query = [PFQuery queryWithClassName:@"UserPhotos"];
    [query whereKey:@"user_id" equalTo:[PFUser currentUser].objectId];
    [query addAscendingOrder:@"position"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
       if (objects.count == 0)
       {
          
            [self saveObjectPhoto:indexSave];
       }
       else{
          
           for (PFObject *pfObj in objects) {
               
               PhotoObj *obj = [[PhotoObj alloc] init];
               obj.objectID = pfObj.objectId;
               if ([pfObj valueForKey:@"photo"])
               {
                   obj.photo = [pfObj valueForKey:@"photo"];
               }
               else{
                   obj.photo = @"";
               }
               obj.position = [[pfObj valueForKey:@"position"] intValue];
               [arrDatas addObject:obj];
           }
           [self.cltPhotos reloadData];
       }
    }];
    //PFObject* checkinObject = [PFObject objectWithClassName:@"CheckIn"];
    //PFUser* currentUser = [PFUser currentUser];
}
- (IBAction)doDone:(id)sender {
    NSString *trimmedString = [_tvDescription.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedString.length == 0) {
        [[PFUser currentUser] removeObjectForKey:@"bio"];
        [[PFUser currentUser] save];
        [self.navigationController popViewControllerAnimated:true];
    }
    else{
        [[PFUser currentUser] setValue:trimmedString forKey:@"bio"];
        [[PFUser currentUser] save];
        [self.navigationController popViewControllerAnimated:true];
    }
}

- (void)saveObjectPhoto:(int)position
{
    PFObject* photoObj = [PFObject objectWithClassName:@"UserPhotos"];
    photoObj[@"user_id"] = [PFUser currentUser].objectId;
    photoObj[@"position"] = [NSString stringWithFormat:@"%d",position];
    [photoObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (indexSave < 6) {
            PhotoObj *obj = [[PhotoObj alloc] init];
            obj.objectID = photoObj.objectId;
            obj.photo = @"";
            obj.position = indexSave;
            [arrDatas addObject:obj];
            indexSave = indexSave + 1;
            [self saveObjectPhoto:indexSave];
        }
        else{
            [self.cltPhotos reloadData];
        }
    }];
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    PFUser *current = [PFUser currentUser];
    if([[current objectForKey:@"always_on"] intValue] == 1) {
        [_btnSwitchAwlay setOn:YES];
    } else {
        [_btnSwitchAwlay setOn:NO];
    }
}

- (IBAction)doSwitch:(id)sender {
    [self didTapSave];
}
-(void)didTapSave {
    PFUser *current = [PFUser currentUser];
    // flipping from off to on
    NMGPSSingleton *shared = [NMGPSSingleton shared];
    if ([[current objectForKey:@"always_on"] intValue] == 0 && _btnSwitchAwlay.on) {
        NMGPSSingleton *shared = [NMGPSSingleton shared];
        [shared startGettingLocation];
    }
    // flipping from on to off
    else if ([[current objectForKey:@"always_on"] intValue] == 1 && !_btnSwitchAwlay.on) {
        [shared stopGettingLocation];
    }
    NSNumber* alwaysOn = (_btnSwitchAwlay.on == YES)?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO];
    [current setObject:alwaysOn forKey:@"always_on"];
    [current saveInBackgroundWithTarget:self selector:@selector(justSaved)];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)justSaved {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saved" message:@"Always on prefrence saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavi
{
    NaviBack *rootView = [[[NSBundle mainBundle] loadNibNamed:@"NaviBack" owner:self options:nil] objectAtIndex:0];
    [rootView.btnBack addTarget:self action:@selector(clickback) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:rootView];
    self.navigationItem.leftBarButtonItem = btn;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:19.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor]; // change this color
    self.navigationItem.titleView = label;
    label.text = @"Settings";
    [label sizeToFit];
}
- (void)clickback
{
    [self.navigationController popViewControllerAnimated:true];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return (294 - 180) + (([[UIScreen mainScreen] bounds].size.width - 44)/3 * 2);
    }
    if (indexPath.row == 1)
    {
         return _tvDescription.frame.size.height + 40;
    }
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return (294 - 180) + (([[UIScreen mainScreen] bounds].size.width - 44)/3 * 2);
    }
    if (indexPath.row == 1)
    {
        return _tvDescription.frame.size.height + 40;
    }
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.row == 2)
    {
        
    }
    else  if (indexPath.row == 3)
    {
        
    }
    else  if (indexPath.row == 5)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.nmtheapp.com/#how-does-it-work"]];
    }
    else  if (indexPath.row == 6)
    {
        [PFUser logOut]; // Log out
        /*  if (![PFUser currentUser]) {
         [self dismissViewControllerAnimated:YES completion:nil];
         PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
         [logInViewController setDelegate:self];
         [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
         [logInViewController setFields: PFLogInFieldsFacebook];
         [logInViewController setSignUpController:nil];
         [self presentViewController:logInViewController animated:YES completion:NULL];
         }*/
        if (![PFUser currentUser]) {
            [self dismissViewControllerAnimated:YES completion:nil];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"loginView"];
            [self presentViewController:vc animated:YES completion:nil];
            
        }
        
    }
}
#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate



- (NSInteger)collectionView:(UICollectionView *)theCollectionView numberOfItemsInSection:(NSInteger)theSectionIndex {
    return arrDatas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SettingPhotoCollect *collect = (SettingPhotoCollect *)[self.cltPhotos dequeueReusableCellWithReuseIdentifier:@"SettingPhotoCollect" forIndexPath:indexPath];
   // [collect registerCollection];
    PhotoObj *obj = arrDatas[indexPath.row];
    collect.photoObj = obj;
    if (obj.photo.length == 0)
    {
        collect.imgCell.image = [[UIImage alloc] init];
        collect.btnDel.hidden = true;
        collect.lblAdd.hidden = false;
        collect.imgCell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    else{
        collect.btnDel.hidden = false;
        collect.lblAdd.hidden = true;
        collect.imgCell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:obj.photo]];
            if ( data == nil )
                return;
            dispatch_async(dispatch_get_main_queue(), ^{
                // WARNING: is the cell still using the same data by this point??
                collect.imgCell.image = [UIImage imageWithData: data];
            });
        });
    }
    collect.imgCell.layer.cornerRadius = ((([[UIScreen mainScreen] bounds].size.width - 44)/3)-20)/2;
    collect.imgCell.layer.masksToBounds = true;
    collect.btnDel.tag = indexPath.row;
    [collect.btnDel addTarget:self action:@selector(clickDelPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    return  collect;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    indexPathPhoto = indexPath;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Take a photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openCamera];
    }];
    [alert addAction:action1];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Choose a library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openLibrary];
    }];
    [alert addAction:action2];
    
    UIAlertAction *actioncancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:actioncancel];
    [self presentViewController:alert animated:true completion:^{
        
    }];
}

- (void)openLibrary
{
    UIImagePickerController *pickerView = [[UIImagePickerController alloc] init];
    pickerView.allowsEditing = YES;
    pickerView.delegate = self;
    [pickerView setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:pickerView animated:YES completion:nil];
}

- (void) openCamera
{
    UIImagePickerController *pickerView =[[UIImagePickerController alloc]init];
    pickerView.allowsEditing = YES;
    pickerView.delegate = self;
    pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:pickerView animated:YES completion:nil];
}
- (void)clickDelPhoto:(UIButton *)btn
{
    PhotoObj *obj = arrDatas[btn.tag];
    obj.photo = @"";
    PFQuery *q = [PFQuery queryWithClassName:@"UserPhotos"];
    [q getObjectInBackgroundWithId:obj.objectID block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [object setValue:@"" forKey:@"photo"];
        [object saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
            
        }];
    }];
    [self.cltPhotos reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:btn.tag inSection:0]]];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage * img = [info valueForKey:UIImagePickerControllerEditedImage];
    NSData* data = UIImageJPEGRepresentation(img, 0.5f);
    PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@_%ld.jpg",[PFUser currentUser].objectId, (long)indexPathPhoto.row] data:data];
    
    // Save the image to Parse
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // The image has now been uploaded to Parse. Associate it with a new object
            PhotoObj *obj = arrDatas[indexPathPhoto.row];
            obj.photo = imageFile.url;
            [_cltPhotos reloadItemsAtIndexPaths:@[indexPathPhoto]];
            //[self.cltPhotos reloadData];
            PFQuery *q = [PFQuery queryWithClassName:@"UserPhotos"];
            [q getObjectInBackgroundWithId:obj.objectID block:^(PFObject * _Nullable object, NSError * _Nullable error) {
                [object setValue:imageFile.url forKey:@"photo"];
                [object saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
                    
                }];
            }];
        }
    }];
    [self dismissViewControllerAnimated:true completion:^{
        
    }];
}
#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    UIImage *playingCard = arrDatas[fromIndexPath.item];
    [arrDatas removeObjectAtIndex:fromIndexPath.item];
    [arrDatas insertObject:playingCard atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
    return YES;
}


#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods
- (void)updatePosition
{
    for (int row = 0; row < arrDatas.count; row++) {
        PhotoObj *obj = arrDatas[row];
        PFQuery *q = [PFQuery queryWithClassName:@"UserPhotos"];
        [q getObjectInBackgroundWithId:obj.objectID block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [object setValue:[NSString stringWithFormat:@"%d",row] forKey:@"position"];
            [object saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
                
            }];
        }];
    }
}
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexPath --->%ld",(long)indexPath.row);
    NSLog(@"will begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
   // NSLog(@"did begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
   // NSLog(@"will end drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did end drag");
    [self updatePosition];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((([[UIScreen mainScreen] bounds].size.width - 44)/3), (([[UIScreen mainScreen] bounds].size.width - 44)/3));
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.tableView setContentOffset:CGPointMake(0, 150) animated:true];
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView == _tvDescription)
    {
        [self textViewFitToContent:_tvDescription];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    NSInteger lenght = textView.text.length;
    if (lenght > 0)
    {
        _lblPlaceHolder.hidden = true;
    }
    else{
        _lblPlaceHolder.hidden = false;
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    return textView.text.length + (text.length - range.length) <= 200;
}

- (void)addDonekeyboard
{
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(DoneButtonPressed)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    self.tvDescription.inputAccessoryView = keyboardToolbar;
}


-(void)DoneButtonPressed
{
    [self.tvDescription resignFirstResponder];
      [self.tableView setContentOffset:CGPointMake(0, 0) animated:true];
}
- (void)textViewFitToContent:(UITextView *)textView
{
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    textView.scrollEnabled = NO;
}
@end
