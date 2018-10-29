//
//  NMPaymentViewController.m
//  Never Missed
//
//  Created by William Emmanuel on 11/27/14.
//  Copyright (c) 2014 William Emmanuel. All rights reserved.
//

#import "NMPaymentViewController.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

@interface NMPaymentViewController ()

@end

@implementation NMPaymentViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_subscribeButton addTarget:self action:@selector(subscribeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    // this is still not working yet
    PFUser *current = [PFUser currentUser];
    if([[current objectForKey:@"subscribed"] intValue] == 1) {
        _statusLabel.text = @"You are currently subscribed";
    } else {
        _statusLabel.text = @"You are currently not subscribed.";
    }
}

-(void)subscribeButtonPressed {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"3"]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
    }
}

-(void)payButtonPressed {
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
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
    SKProduct *validProduct = nil;
    int count = [response.products count];
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
    NSLog(@"received restored transactions: %i", queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        if(SKPaymentTransactionStateRestored){
            NSLog(@"Transaction State -> Restored");
            //called when the user successfully restores a purchase
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
        
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                if([transaction.payment.productIdentifier isEqualToString:@"2"]) {
                    [[PFUser currentUser] incrementKey:@"purchasedConnections"];
                    [[PFUser currentUser] saveEventually];
                }
                if ([transaction.payment.productIdentifier isEqualToString:@"3"]) {
                    [[PFUser currentUser] setObject:@YES forKey:@"subscribed"];
                    [[PFUser currentUser] saveEventually];
                }
                NSLog(@"Transaction state -> Purchased");
                if([[[PFUser currentUser] objectForKey:@"subscribed" ] intValue] == 1) {
                    _statusLabel.text = @"You are currently subscribed.";
                } else {
                   _statusLabel.text = @"You are currently not subscribed.";
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
