//
//  AddWalletAddressViewController.h
//  DashControl
//
//  Created by Sam Westrich on 10/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddWalletAddressViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField * inputField;

-(IBAction)done:(id)sender;

@end
