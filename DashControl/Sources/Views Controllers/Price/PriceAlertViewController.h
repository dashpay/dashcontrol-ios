//
//  PriceAlertViewController.h
//  DashControl
//
//  Created by Manuel Boyer on 27/10/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OldPriceViewController.h"
#import "DCTriggerEntity+CoreDataProperties.h"

@class DCPersistenceStack;

@interface PriceAlertViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;

@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,strong) DCTriggerEntity * editingTrigger;

@property (nonatomic, strong) DCMarketEntity * selectedMarket;
@property (nonatomic, strong) DCExchangeEntity * selectedExchange;

@end
