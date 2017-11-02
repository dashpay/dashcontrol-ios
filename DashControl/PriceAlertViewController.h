//
//  PriceAlertViewController.h
//  DashControl
//
//  Created by Manuel Boyer on 27/10/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PriceViewController.h"

@interface PriceAlertViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, assign) PriceViewController *delegate;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL isEditing;

@property (nonatomic) NSInteger priceAlertIdentifier;
@property (strong, nonatomic) NSNumber *priceAmount;
@property (nonatomic) BOOL isOver;

@end
