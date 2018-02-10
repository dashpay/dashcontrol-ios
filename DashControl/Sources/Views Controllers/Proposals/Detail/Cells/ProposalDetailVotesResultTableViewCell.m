//
//  ProposalDetailVotesResultTableViewCell.m
//  DashControl
//
//  Created by Manuel Boyer on 05/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ProposalDetailVotesResultTableViewCell.h"

@implementation ProposalDetailVotesResultTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithProposal:(DCProposalEntity*)proposal {
    _labelVotesResult.text = NSLocalizedString(@"Votes Result", @"Proposal Detail View");
    
    _labelVotesResultYes.text = [NSString stringWithFormat:@"%d %@", proposal.yes, NSLocalizedString(@"Yes", @"Proposal Detail View")];
    _labelVotesResultNo.text = [NSString stringWithFormat:@"%d %@", proposal.no, NSLocalizedString(@"No", @"Proposal Detail View")];
    _labelVotesResultAbstain.text = [NSString stringWithFormat:@"%d %@", proposal.abstain, NSLocalizedString(@"Abstain", @"Proposal Detail View")];
    
    UIFont *font = [UIFont systemFontOfSize:13.5 weight:UIFontWeightSemibold];
    [_labelVotesResultYes setFont:font];
    [_labelVotesResultNo setFont:font];
    [_labelVotesResultAbstain setFont:font];
}

@end
