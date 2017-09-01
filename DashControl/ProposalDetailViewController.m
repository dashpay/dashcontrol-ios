//
//  ProposalDetailViewController.m
//  DashControl
//
//  Created by Manuel Boyer on 02/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ProposalDetailViewController.h"

@interface ProposalDetailViewController ()

@end

@implementation ProposalDetailViewController

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
}

-(void)fetchProposalDetail {
    [[ProposalsManager sharedManager] fetchProposalsWithHash:self.currentProposal.hashProposal];
}

-(void)proposalDidUpdate:(NSNotification*)notification {
    if ([[notification name] isEqualToString:PROPOSAL_DID_UPDATE_NOTIFICATION] && [[[notification userInfo] objectForKey:@"hash"] isEqualToString:self.currentProposal.hashProposal]) {
        NSLog(@"Proposal updated:%@", self.currentProposal);
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

@end
