//
//  PortfolioViewController.m
//  DashControl
//
//  Created by Sam Westrich on 10/2/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "PortfolioViewController.h"

#import "DCPersistenceStack.h"
#import "DCWalletAddressEntity+CoreDataClass.h"
#import "DCWalletAccountEntity+CoreDataClass.h"
#import "DCWalletEntity+CoreDataClass.h"
#import "DCMasternodeEntity+CoreDataClass.h"
#import <FTPopOverMenu/FTPopOverMenu.h>
#import "DCCoreDataManager.h"
#import "DCPortfolioManager.h"

@interface PortfolioViewController ()

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController* walletFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController* walletAddressFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController* masternodeAddressFetchedResultsController;
@property id balanceObserver;

- (IBAction)refreshAmounts:(UIRefreshControl *)sender;

@end

@implementation PortfolioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.managedObjectContext = self.stack.persistentContainer.viewContext;
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onNavButtonTapped:event:)]];
    
    self.balanceObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:PORTFOLIO_DID_UPDATE_NOTIFICATION object:nil
                                                       queue:nil usingBlock:^(NSNotification * _Nonnull note) {
                                                           [self refreshTotalWorth];
                                                       }];
    [self refreshTotalWorth];
}
     
     -(void)refreshTotalWorth {
         NSError * error =nil;
         uint64_t totalWorth = [[DCPortfolioManager sharedInstance] totalWorthInContext:nil error:&error];
         float worthDash = totalWorth/100000000.0;
         NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
         [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
         [numberFormatter setRoundingMode:NSNumberFormatterRoundHalfDown];
         numberFormatter.maximumFractionDigits = 6;
         numberFormatter.minimumFractionDigits = 0;
         numberFormatter.minimumSignificantDigits = 0;
         numberFormatter.maximumSignificantDigits = 6;
         numberFormatter.usesSignificantDigits = TRUE;
         
         self.balanceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ DASH worth %@ USD", nil),[numberFormatter stringFromNumber:@(worthDash)],@"0"];
     }

- (IBAction)refreshAmounts:(UIRefreshControl *)sender {
    [[DCPortfolioManager sharedInstance] updateAmounts];
    
}

-(void)onNavButtonTapped:(UIBarButtonItem *)sender event:(UIEvent *)event
{
    NSURL * requestURL = [NSURL URLWithString:@"dashwallet://request=masterPublicKey&account=0&sender=dashcontrol"];
    NSMutableArray * menuArray = [@[@"Wallet Address",@"Masternode"] mutableCopy];
    NSError * error = nil;
    NSArray * dashwalletEntities = [[DCCoreDataManager sharedInstance] walletsWithIndentifier:@"dashwallet" inContext:nil error:&error];
    if (![dashwalletEntities count] && [[UIApplication sharedApplication] canOpenURL:requestURL]) {
        [menuArray addObject:@"Link Dashwallet"];
    }
    [FTPopOverMenu showFromEvent:event
                   withMenuArray:menuArray doneBlock:^(NSInteger selectedIndex) {
                       switch (selectedIndex) {
                           case 0:
                               [self performSegueWithIdentifier:@"AddWalletAddressSegue" sender:self];
                               break;
                           case 1:
                               [self performSegueWithIdentifier:@"AddMasternodeSegue" sender:self];
                               break;
                           case 2: {
                               [[UIApplication sharedApplication] openURL:requestURL options:@{} completionHandler:^(BOOL success) {
                                   
                               }];
                           }
                           default:
                               break;
                       }
                   } dismissBlock:^{
                       
                   }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - fetchedResultsControllers

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSUInteger realSection;
    if (controller == _walletFetchedResultsController) {
        realSection = 0;
    } else if (controller == _masternodeAddressFetchedResultsController) {
        realSection = 1;
    } else {
        realSection = 2;
    }
    NSIndexPath * realIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:realSection];
    NSIndexPath * realNewIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:realSection];
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:realNewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:realIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:realIndexPath] atIndexPath:realIndexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView moveRowAtIndexPath:realIndexPath toIndexPath:realNewIndexPath];
            [self configureCell:[tableView cellForRowAtIndexPath:realNewIndexPath] atIndexPath:indexPath];
            
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

- (NSFetchedResultsController *)walletFetchedResultsController {
    
    if (_walletFetchedResultsController != nil) {
        return _walletFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"DCWalletEntity" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:TRUE];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.walletFetchedResultsController = theFetchedResultsController;
    _walletFetchedResultsController.delegate = self;
    NSError *error = nil;
    if (![_walletFetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    return _walletFetchedResultsController;
}

- (NSFetchedResultsController *)walletAddressFetchedResultsController {
    
    if (_walletAddressFetchedResultsController != nil) {
        return _walletAddressFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"DCWalletAddressEntity" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"address" ascending:TRUE];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"walletAccount = nil"]];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.walletAddressFetchedResultsController = theFetchedResultsController;
    _walletAddressFetchedResultsController.delegate = self;
    NSError *error = nil;
    if (![_walletAddressFetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    return _walletAddressFetchedResultsController;
}

- (NSFetchedResultsController *)masternodeAddressFetchedResultsController {
    
    if (_masternodeAddressFetchedResultsController != nil) {
        return _masternodeAddressFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"DCMasternodeEntity" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"address" ascending:TRUE];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.masternodeAddressFetchedResultsController = theFetchedResultsController;
    _masternodeAddressFetchedResultsController.delegate = self;
    NSError *error = nil;
    if (![_masternodeAddressFetchedResultsController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    return _masternodeAddressFetchedResultsController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return [self.walletFetchedResultsController.fetchedObjects count];
        }
        case 1:
        {
            return [self.masternodeAddressFetchedResultsController.fetchedObjects count];
        }
        case 2:
        {
            return [self.walletAddressFetchedResultsController.fetchedObjects count];
        }
        default:
            break;
    }
    return 0;
}

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            DCWalletEntity *wallet = [self.walletFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            [cell.textLabel setText:wallet.name];
            return;
        }
        case 1:
        {
            DCMasternodeEntity *masternode = [self.masternodeAddressFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            [cell.textLabel setText:[NSString stringWithFormat:@"%@ - %@",@"Masternode",masternode.address]];
            return;
        }
        case 2:
        {
            DCWalletAddressEntity *walletAddress = [self.walletAddressFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            [cell.textLabel setText:walletAddress.address];
            return;
        }
        default:
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
    switch (indexPath.section) {
        case 0:
        {
            static NSString * CellReuseIdentifier = @"WalletCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier];
            [self configureCell:cell atIndexPath:indexPath];
            break;
        }
        case 1:
        {
            static NSString * CellReuseIdentifier = @"MasternodeCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier];
            [self configureCell:cell atIndexPath:indexPath];
            break;
        }
        case 2:
        {

            static NSString * CellReuseIdentifier = @"WalletAddressCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier];
            [self configureCell:cell atIndexPath:indexPath];
            break;
        }
    }
    return cell;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
