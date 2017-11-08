//
//  PriceAlertViewController.h
//  DashControl
//
//  Created by Manuel Boyer on 27/10/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PriceViewController.h"
#import "DCTriggerEntity+CoreDataProperties.h"

@interface PriceAlertViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,assign) BOOL isEditing;

@property (nonatomic, strong) DCMarketEntity * selectedMarket;
@property (nonatomic, strong) DCExchangeEntity * selectedExchange;

@end
