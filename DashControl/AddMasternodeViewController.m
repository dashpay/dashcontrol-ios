//
//  AddMasternodeViewController.m
//  DashControl
//
//  Created by Sam Westrich on 10/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "AddMasternodeViewController.h"
#import "NSString+Dash.h"
#import "DCMasternodeEntity+CoreDataClass.h"
#import "PortfolioManager.h"

@interface AddMasternodeViewController ()

@end

@implementation AddMasternodeViewController

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
    NSString * address = [self.inputField text];
    if ([address isValidDashAddress]) {
        //first lets check to see if it has 1000 dash in it
        [[PortfolioManager sharedManager] amountAtAddress:address clb:^(uint64_t amount, NSError * _Nullable error) {
            if (error) {
                if (amount < 100000000000) {
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Not a valid masternode address",nil) message:NSLocalizedString(@"This address does not contain the required 1000 Dash",nil) preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        self.inputField.text = @"";
                    }]];
                    [self presentViewController:alert animated:TRUE completion:^{
                        
                    }];
                } else {
                    NSManagedObjectContext * context = [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer] viewContext];
                    DCMasternodeEntity * masternode = [NSEntityDescription insertNewObjectForEntityForName:@"Masternode" inManagedObjectContext:context];
                    masternode.address = [self.inputField text];
                    masternode.amount = 100000000000; //base amount;
                    NSError *error = nil;
                    if (![context save:&error]) {
                        NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
                        abort();
                    }
                }
            } else {
                
                
            }
        }];
        
    } else {
        
    }
}
@end
