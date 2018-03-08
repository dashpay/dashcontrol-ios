//
//  ProposalDetailViewController.h
//  DashControl
//
//  Created by Manuel Boyer on 02/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>

@interface OldProposalDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate>

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@property (nonatomic, retain) DCProposalEntity *currentProposal;

@property (strong, nonatomic) UIView *budgetView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
