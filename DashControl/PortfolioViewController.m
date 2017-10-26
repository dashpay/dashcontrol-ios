//
//  PortfolioViewController.m
//  DashControl
//
//  Created by Sam Westrich on 10/2/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "PortfolioViewController.h"
#import "DCWalletAddressEntity+CoreDataClass.h"
#import "DCWalletMasterAddressEntity+CoreDataClass.h"
#import "DCMasternodeEntity+CoreDataClass.h"
#import <FTPopOverMenu/FTPopOverMenu.h>

@interface PortfolioViewController ()

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController* walletAddressFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController* masternodeAddressFetchedResultsController;

@end

@implementation PortfolioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.managedObjectContext = [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer] viewContext];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onNavButtonTapped:event:)]];
}

-(void)onNavButtonTapped:(UIBarButtonItem *)sender event:(UIEvent *)event
{
    NSURL * requestURL = [NSURL URLWithString:@"dashwallet://request=masterPublicKey&account=0&sender=dashcontrol"];
    NSMutableArray * menuArray = [@[@"Wallet Address",@"Masternode"] mutableCopy];
    if ([[UIApplication sharedApplication] canOpenURL:requestURL]) {
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

- (NSFetchedResultsController *)walletAddressFetchedResultsController {
    
    if (_walletAddressFetchedResultsController != nil) {
        return _walletAddressFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"DCWalletAddressEntity" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"address" ascending:TRUE];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return [self.walletAddressFetchedResultsController.fetchedObjects count];
        }
        case 1:
        {
            id< NSFetchedResultsSectionInfo> sectionInfo = [[[self masternodeAddressFetchedResultsController] sections] objectAtIndex:0];
            return [sectionInfo numberOfObjects];
        }
        default:
            break;
    }
    return 0;
}

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath {
    DCWalletAddressEntity *walletAddress = [self.walletAddressFetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText:walletAddress.address];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
    static NSString * CellReuseIdentifier = @"WalletAddressCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier];
        [self configureCell:cell atIndexPath:indexPath];

    // Configure the cell from the object
    return cell;
    } else {
        static NSString * CellReuseIdentifier = @"MasternodeCell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier];
        
        DCMasternodeEntity *masternode = [self.walletAddressFetchedResultsController objectAtIndexPath:indexPath];
         [cell.textLabel setText:masternode.address];
        return cell;
    }
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
