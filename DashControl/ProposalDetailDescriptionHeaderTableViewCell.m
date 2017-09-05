//
//  ProposalDetailDescriptionHeaderTableViewCell.m
//  DashControl
//
//  Created by Manuel Boyer on 05/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ProposalDetailDescriptionHeaderTableViewCell.h"

@implementation ProposalDetailDescriptionHeaderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithProposal:(Proposal*)proposal {
    _labelDescription.text = NSLocalizedString(@"PROPOSAL DESCRIPTION", @"Proposal Detail View");
}

@end
