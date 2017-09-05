//
//  ProposalDetailViewController.m
//  DashControl
//
//  Created by Manuel Boyer on 02/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ProposalDetailViewController.h"
#import "ProposalDetailNameTableViewCell.h"
#import "ProposalDetailTitleTableViewCell.h"
#import "ProposalDetailOneTimePayementTableViewCell.h"
#import "ProposalDetailCompletedPaymentsTableViewCell.h"
#import "ProposalDetailVotesResultTableViewCell.h"
#import "ProposalDetailDescriptionHeaderTableViewCell.h"
#import "ProposalDetailDescriptionDetailTableViewCell.h"

#import <SafariServices/SafariServices.h>

static NSString *CellDetailNameIdentifier = @"ProposalDetailNameCell";
static NSString *CellDetailTitleIdentifier = @"ProposalDetailTitleCell";
static NSString *CellDetailOneTimePayementIdentifier = @"ProposalDetailOneTimePaymentCell";
static NSString *CellDetailCompletedPaymentsIdentifier = @"ProposalDetailCompletedPaymentsCell";
static NSString *CellDetailVotesResultIdentifier = @"ProposalDetailVotesResultCell";
static NSString *CellDetailDescriptionHeaderIdentifier = @"ProposalDetailDescriptionHeaderCell";
static NSString *CellDetailDescriptionDetailIdentifier = @"ProposalDetailDescriptionDetailCell";

@interface ProposalDetailViewController ()

@end

@implementation ProposalDetailViewController
@synthesize managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"Proposal:%@", self.currentProposal);
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(proposalDidUpdate:)
     name:PROPOSAL_DID_UPDATE_NOTIFICATION
     object:nil];
    
    [self fetchProposalDetail];
    [self forceTouchIntialize];
}

-(void)fetchProposalDetail {
    [[ProposalsManager sharedManager] fetchProposalsWithHash:self.currentProposal.hashProposal];
}

-(void)proposalDidUpdate:(NSNotification*)notification {
    if ([[notification name] isEqualToString:PROPOSAL_DID_UPDATE_NOTIFICATION] && [[[notification userInfo] objectForKey:@"hash"] isEqualToString:self.currentProposal.hashProposal]) {
        NSLog(@"Proposal updated:%@", self.currentProposal);
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    if ([cellIdentifier isEqualToString:CellDetailNameIdentifier]) {
        return 70;
    }
    else if ([cellIdentifier isEqualToString:CellDetailTitleIdentifier]) {
        return 60;
    }
    else if ([cellIdentifier isEqualToString:CellDetailOneTimePayementIdentifier]) {
        return 60;
    }
    else if ([cellIdentifier isEqualToString:CellDetailCompletedPaymentsIdentifier]) {
        return 60;
    }
    else if ([cellIdentifier isEqualToString:CellDetailVotesResultIdentifier]) {
        return 70;
    }
    else if ([cellIdentifier isEqualToString:CellDetailDescriptionHeaderIdentifier]) {
        return 40;
    }
    else if ([cellIdentifier isEqualToString:CellDetailDescriptionDetailIdentifier]) {
        return UITableViewAutomaticDimension;
    }
    else {
        return CGFLOAT_MIN;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(configureWithProposal:)]) {
        [cell performSelector:@selector(configureWithProposal:) withObject:self.currentProposal];
    }
    return cell;
}
-(void) tableView:(UITableView *) tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        CGFloat currentProgress =  (self.currentProposal.yes / (self.currentProposal.yes + self.currentProposal.remainingYesVotesUntilFunding)) * 100;
        
        if (self.currentProposal.lastProgressDisplayed != currentProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:1.f delay:CGFLOAT_MIN options:UIViewAnimationOptionTransitionNone animations:^{
                    [(ProposalDetailNameTableViewCell*)cell progressView].value = currentProgress;
                } completion:^(BOOL finished) {
                    self.currentProposal.lastProgressDisplayed = currentProgress;
                    NSError *error = nil;
                    [self.managedObjectContext save:&error];
                }];
            });
        }
        else {
            [(ProposalDetailNameTableViewCell*)cell progressView].value = currentProgress;
        }
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    if ([cellIdentifier isEqualToString:CellDetailDescriptionDetailIdentifier]) {
        SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:self.currentProposal.dwUrl]];
        svc.delegate = self;
        [self presentViewController:svc animated:YES completion:nil];
    }
}
-(NSString *)cellIdentifierForIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row == 0) {
        return CellDetailNameIdentifier;
    }
    else if (indexPath.row == 1) {
        return CellDetailTitleIdentifier;
    }
    else if (indexPath.row == 2) {
        return CellDetailOneTimePayementIdentifier;
    }
    else if (indexPath.row == 3) {
        return CellDetailCompletedPaymentsIdentifier;
    }
    else if (indexPath.row == 4) {
        return CellDetailVotesResultIdentifier;
    }
    else if (indexPath.row == 5) {
        return CellDetailDescriptionHeaderIdentifier;
    }
    else if (indexPath.row == 6) {
        return CellDetailDescriptionDetailIdentifier;
    }
    else {
        return nil;
    }
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
    if (indexPath && (indexPath.row == 0 || indexPath.row == 6)) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:self.currentProposal.dwUrl]];
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


@end
