//
//  ProposalDetailDescriptionDetailTableViewCell.h
//  DashControl
//
//  Created by Manuel Boyer on 05/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProposalDetailDescriptionDetailTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelProposalDescription;

-(void)configureWithProposal:(DCProposalEntity*)proposal;

@end
