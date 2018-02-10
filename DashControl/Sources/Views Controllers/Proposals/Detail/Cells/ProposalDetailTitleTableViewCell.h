//
//  ProposalDetailTitleTableViewCell.h
//  DashControl
//
//  Created by Manuel Boyer on 05/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProposalDetailTitleTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelProposalTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelProposalOwner;

-(void)configureWithProposal:(DCProposalEntity*)proposal;

@end
