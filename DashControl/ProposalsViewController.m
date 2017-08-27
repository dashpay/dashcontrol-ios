//
//  ProposalsViewController.m
//  DashControl
//
//  Created by Manuel Boyer on 23/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ProposalsViewController.h"

@interface ProposalsViewController ()

@end

@implementation ProposalsViewController
@synthesize managedObjectContext;
//@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    managedObjectContext = [[ProposalsManager sharedManager] managedObjectContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    Budget *budget = [[[ProposalsManager sharedManager] fetchAllObjectsForEntity:@"Budget" inContext:self.managedObjectContext] firstObject];
    [budget allotedAmount];
    NSLog(@"Budget:%@", budget);
    
    NSArray *proposals = [[ProposalsManager sharedManager] fetchAllObjectsForEntity:@"Proposal" inContext:self.managedObjectContext];
    NSLog(@"All proposals count:%lu", [proposals count]);
    for (Proposal *proposal in proposals) {
        NSLog(@"Proposal:%@\rThe proposal has %lu comments", proposal.title, proposal.comments.count);
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
