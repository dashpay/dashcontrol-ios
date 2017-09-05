//
//  ProposalDetailDescriptionDetailTableViewCell.h
//  DashControl
//
//  Created by Manuel Boyer on 05/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProposalDetailDescriptionDetailTableViewCell : UITableViewCell

@property (nonatomic, retain) Proposal *currentProposal;

@property (strong, nonatomic) IBOutlet UILabel *labelProposalDescription;

-(void)configureWithProposal:(Proposal*)proposal;

@end
