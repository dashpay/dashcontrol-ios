//
//  ProposalDetailViewController.h
//  DashControl
//
//  Created by Manuel Boyer on 02/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>

@interface ProposalDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate, UIViewControllerPreviewingDelegate>

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@property (nonatomic, retain) Proposal *currentProposal;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

//3D Touch
@property (nonatomic, strong) id previewingContext;

@end
