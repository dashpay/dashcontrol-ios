//
//  PortfolioViewController.h
//  DashControl
//
//  Created by Sam Westrich on 10/2/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class DCPersistenceStack;

@interface OldPortfolioViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;

@property (nonatomic,strong) IBOutlet UILabel * balanceLabel;

@end
