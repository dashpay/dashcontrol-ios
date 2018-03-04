//
//  ProposalsViewController.h
//  DashControl
//
//  Created by Manuel Boyer on 23/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>
#import "ProposalHeaderView.h"
#import "ProposalScopeButtonsView.h"

@class DCPersistenceStack;

@interface OldProposalsViewController : UIViewController <NSFetchedResultsControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, SFSafariViewControllerDelegate>

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) IBOutlet ProposalHeaderView *proposalHeaderView;
@property (strong, nonatomic) IBOutlet ProposalScopeButtonsView *proposalScopeButtonsView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;

-(void)simulateNavitationToProposalWithHash:(NSString*)hash;

@end
