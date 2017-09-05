//
//  ProposalDetailVotesResultTableViewCell.h
//  DashControl
//
//  Created by Manuel Boyer on 05/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProposalDetailVotesResultTableViewCell : UITableViewCell

@property (nonatomic, retain) Proposal *currentProposal;

@property (strong, nonatomic) IBOutlet UILabel *labelVotesResult;
@property (strong, nonatomic) IBOutlet UILabel *labelVotesResultYes;
@property (strong, nonatomic) IBOutlet UILabel *labelVotesResultNo;
@property (strong, nonatomic) IBOutlet UILabel *labelVotesResultAbstain;

-(void)configureWithProposal:(Proposal*)proposal;

@end
