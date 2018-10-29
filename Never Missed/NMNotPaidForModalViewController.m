//
//  NMNotPaidForModalViewController.m
//  NeverMissed
//
//  Created by William Emmanuel on 12/26/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMNotPaidForModalViewController.h"
#import "NMChatViewController.h"
#import "MBProgressHUD.h"

@interface NMNotPaidForModalViewController ()

@end

@implementation NMNotPaidForModalViewController {
    PFUser *_currentUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    _currentUser = [PFUser currentUser];
    [_currentUser fetchIfNeeded];
    [_backButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];

    [_settingsOrPayButton setTitle:@"Pay for connection" forState:UIControlStateNormal];
    [_settingsOrPayButton addTarget:self action:@selector(payButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];

    PFFile *imageFile = [_connectedUser objectForKey:@"profilePicture"];
    NSData *data = [imageFile getData];
    _profilePicture.image = [UIImage imageWithData:data];
    _profilePicture.contentMode = UIViewContentModeScaleAspectFill;
    _nameLabel.text = [_connectedUser objectForKey:@"name"];
    CALayer *imageLayer = _profilePicture.layer;
    [imageLayer setCornerRadius:50];
    [imageLayer setBorderWidth:0];
    [imageLayer setMasksToBounds:YES];
    
}



-(void)backButtonWasPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)payButtonWasPressed {
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"2"]];
        productsRequest.delegate = self;
        [productsRequest start];
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SKProduct *validProduct = nil;
    int count = (int)[response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
    }
}

- (IBAction)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (IBAction) restore{
    //this is called when the user restores purchases, you should hook this up to a button
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %i", (int)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        if(SKPaymentTransactionStateRestored){
            NSLog(@"Transaction state -> Restored");
            //called when the user successfully restores a purchase
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
        
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                if([transaction.payment.productIdentifier isEqualToString:@"2"]) {
                    [_connection setObject:@YES forKey:@"paidFor"];
                    [_connection save];
                    [_currentUser incrementKey:@"purchasedConnections" byAmount:@-1];
                    [_currentUser save];
                    [self dismissViewControllerAnimated:YES completion:^{
                        NMChatViewController * chatViewController = [[NMChatViewController alloc] initWithNibName:nil bundle:nil];
                        chatViewController.connection = _connection;
                        chatViewController.connectionUser = _connectedUser;
                        [self.navigationController pushViewController:chatViewController animated:YES];
                    }];
                }
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finnish
                if(transaction.error.code != SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void)settingsButtonWasPressed {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *myVC = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"SettingsNav"];
    [self dismissViewControllerAnimated:YES completion:nil];
    [(UINavigationController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController] popViewControllerAnimated:YES];
    [(UINavigationController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:myVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
