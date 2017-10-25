//
//  AddWalletAddressViewController.m
//  DashControl
//
//  Created by Sam Westrich on 10/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "AddWalletAddressViewController.h"
#import "NSString+Dash.h"
#import "DCWalletAddressEntity+CoreDataClass.h"

@interface AddWalletAddressViewController ()

@end

@implementation AddWalletAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)done:(id)sender {
    if ([[self.inputField text] isValidDashAddress]) {
        NSManagedObjectContext * context = [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer] viewContext];
        DCWalletAddressEntity * walletAddress = [NSEntityDescription insertNewObjectForEntityForName:@"WalletAddress" inManagedObjectContext:context];
        walletAddress.address = [self.inputField text];
        walletAddress.amount = -1; //-1 is updating amount;
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
        else {
            
        }
    }
}

@end
