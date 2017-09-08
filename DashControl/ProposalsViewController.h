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

@interface ProposalsViewController : UIViewController <NSFetchedResultsControllerDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, SFSafariViewControllerDelegate, UIViewControllerPreviewingDelegate>

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) IBOutlet ProposalHeaderView *proposalHeaderView;
@property (strong, nonatomic) IBOutlet ProposalScopeButtonsView *proposalScopeButtonsView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;

//3D Touch
@property (nonatomic, strong) id previewingContext;

-(void)simulateNavitationToProposalWithHash:(NSString*)hash;

@end
