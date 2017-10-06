//
//  AddMasternodeViewController.h
//  DashControl
//
//  Created by Sam Westrich on 10/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddMasternodeViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField * inputField;

-(IBAction)done:(id)sender;

@end
