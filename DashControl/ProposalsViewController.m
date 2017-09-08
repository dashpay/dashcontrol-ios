//
//  ProposalsViewController.m
//  DashControl
//
//  Created by Manuel Boyer on 23/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ProposalsViewController.h"
#import "ProposalCell.h"
#import "ProposalDetailViewController.h"
#import "ProposalScopeButtonsView.h"

@interface ProposalsViewController ()
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@end

@implementation ProposalsViewController
@synthesize managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;

static NSString *CellIdentifier = @"ProposalCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    managedObjectContext = [[ProposalsManager sharedManager] managedObjectContext];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(budgetDidUpdate:)
     name:BUDGET_DID_UPDATE_NOTIFICATION
     object:nil];
    
    [self budgetDidUpdate:nil];
    
    [self cfgSearchController];
    [self.proposalHeaderView addSubview:self.searchController.searchBar];
    [self.proposalScopeButtonsView.scopeSegmentedControl addTarget:self action:@selector(updateScopeSelectedButton:) forControlEvents:UIControlEventValueChanged];

    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [self forceTouchIntialize];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.fetchedResultsController = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
    
    /*
    NSArray *proposals = [[ProposalsManager sharedManager] fetchAllObjectsForEntity:@"Proposal" inContext:self.managedObjectContext];
    NSLog(@"All proposals count:%lu", (unsigned long)[proposals count]);
    for (Proposal *proposal in proposals) {
        NSLog(@"order:%d ## %@", proposal.order, proposal.title);
    }
    */
}

#pragma mark - Budget Updates

-(void)budgetDidUpdate:(NSNotification*)notification {
    Budget *budget = [[[ProposalsManager sharedManager] fetchAllObjectsForEntity:@"Budget" inContext:managedObjectContext] firstObject];
    [_proposalHeaderView configureWithBudget:budget];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id  sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Proposal *proposal = [_fetchedResultsController objectAtIndexPath:indexPath];
    [(ProposalCell*)cell setCurrentProposal:proposal];
    [(ProposalCell*)cell cfgViews];
    [(ProposalCell*)cell progressView].value = proposal.lastProgressDisplayed;
}

-(void) tableView:(UITableView *) tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Proposal *proposal = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    CGFloat currentProgress =  (proposal.yes / (proposal.yes + proposal.remainingYesVotesUntilFunding)) * 100;

    if (proposal.lastProgressDisplayed != currentProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:1.f delay:CGFLOAT_MIN options:UIViewAnimationOptionTransitionNone animations:^{
                [(ProposalCell*)cell progressView].value = currentProgress;
            } completion:^(BOOL finished) {
                proposal.lastProgressDisplayed = currentProgress;
                NSError *error = nil;
                [managedObjectContext save:&error];
            }];
        });
    }
    else {
        [(ProposalCell*)cell progressView].value = currentProgress;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProposalCell *cell = (ProposalCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
     if ([[segue identifier] isEqualToString:@"pushProposalDetail"])
     {
         //Get reference to the destination view controller
         ProposalDetailViewController *vc = [segue destinationViewController];
         [vc setManagedObjectContext:managedObjectContext];
         [vc setCurrentProposal:[(ProposalCell*)sender currentProposal]];
         vc.hidesBottomBarWhenPushed = YES;
     }
}

#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Proposal" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSString *searchString = self.searchController.searchBar.text;
    
    NSPredicate *scopePredicate;
    if (self.proposalScopeButtonsView.scopeSegmentedControl.selectedSegmentIndex == 0) {
        scopePredicate = [NSPredicate predicateWithFormat:@"dateEnd > %@", [NSDate date]];
    }
    else if (self.proposalScopeButtonsView.scopeSegmentedControl.selectedSegmentIndex == 1) {
        scopePredicate = [NSPredicate predicateWithFormat:@"dateEnd < %@", [NSDate date]];
    }
    else {
        scopePredicate = [NSPredicate predicateWithFormat:@"dateEnd > %@ AND remainingPaymentCount > 0 AND willBeFunded == YES AND inNextBudget == YES", [NSDate date]];
    }
    
    if (searchString.length > 0)
    {
        NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", searchString];
        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString];
        NSPredicate *ownerPredicate = [NSPredicate predicateWithFormat:@"ownerUsername CONTAINS[cd] %@", searchString];
        NSPredicate *orPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:namePredicate, titlePredicate, ownerPredicate, nil]];
        
        NSPredicate *andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:scopePredicate, nil]];
        
        NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:orPredicate, andPredicate, nil]];
        [fetchRequest setPredicate:finalPredicate];
    }
    else
    {
        [fetchRequest setPredicate:scopePredicate];
    }
    
    if (self.proposalScopeButtonsView.scopeSegmentedControl.selectedSegmentIndex == 0 || self.proposalScopeButtonsView.scopeSegmentedControl.selectedSegmentIndex == 2) {
        NSSortDescriptor *orderSort = [[NSSortDescriptor alloc]
                                       initWithKey:@"order" ascending:YES];
        NSSortDescriptor *dateAddedSort = [[NSSortDescriptor alloc]
                                           initWithKey:@"dateAdded" ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:orderSort, dateAddedSort, nil]];
    }
    else {
        NSSortDescriptor *dateEndSort = [[NSSortDescriptor alloc]
                                         initWithKey:@"dateEnd" ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:dateEndSort, nil]];
    }


    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self configureCell:[tableView cellForRowAtIndexPath:newIndexPath] atIndexPath:indexPath];
            
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

#pragma mark - UISearchController

-(void)cfgSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    //self.searchController.searchBar.placeholder = NSLocalizedString(@"Search name or owner", nil);
    self.searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    self.fetchedResultsController = nil;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [self.tableView reloadData];
}

#pragma mark - UIScopeBarUpdate

-(void)updateScopeSelectedButton:(UISegmentedControl *)segmentedControl {
    self.fetchedResultsController = nil;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    
    [self.tableView reloadData];
}

#pragma mark - 3D Touch
-(void)forceTouchIntialize{
    if ([self isForceTouchAvailable]) {
        self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
}

- (BOOL)isForceTouchAvailable {
    BOOL isForceTouchAvailable = NO;
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        isForceTouchAvailable = self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    }
    return isForceTouchAvailable;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if ([self isForceTouchAvailable]) {
        if (!self.previewingContext) {
            self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
        }
    } else {
        if (self.previewingContext) {
            [self unregisterForPreviewingWithContext:self.previewingContext];
            self.previewingContext = nil;
        }
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing> )previewingContext viewControllerForLocation:(CGPoint)location{
    
    CGPoint cellPostion = [self.tableView convertPoint:location fromView:self.view];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:cellPostion];
    if (indexPath) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        Proposal *proposal = [_fetchedResultsController objectAtIndexPath:indexPath];
        SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:proposal.dwUrl]];
        svc.delegate = self;
        [svc registerForPreviewingWithDelegate:self sourceView:self.view];
        previewingContext.sourceRect = [self.view convertRect:cell.frame fromView:self.tableView];
        return svc;
    }
    
    return nil;
}
-(void)previewingContext:(id )previewingContext commitViewController: (UIViewController *)viewControllerToCommit {
    [self.navigationController showViewController:viewControllerToCommit sender:nil];
}

#pragma mark - NSUserActivity continueUserActivity

-(void)simulateNavitationToProposalWithHash:(NSString*)hash {
    
    if (!managedObjectContext) {
        managedObjectContext = [[ProposalsManager sharedManager] managedObjectContext];
    }
    
    Proposal *proposal;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Proposal" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *hashPredicate = [NSPredicate predicateWithFormat:@"hashProposal == %@", hash];
    [request setPredicate:hashPredicate];
    NSError *error;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (array == nil)
    {
        NSLog(@"Error while festching %@ with predicate %@", entityDescription.name, hashPredicate);
    }
    else {
        proposal = array.firstObject;
    }
    if (proposal) {
        if (![[self fetchedResultsController] performFetch:&error]) {
            return;
        }
        NSIndexPath *indexPath = [_fetchedResultsController indexPathForObject:proposal];
        if (indexPath) {
            if (![[self.tableView indexPathsForVisibleRows] containsObject:indexPath]) {
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            }
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                [self performSegueWithIdentifier:@"pushProposalDetail" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
            });
        }
    }
}


@end
