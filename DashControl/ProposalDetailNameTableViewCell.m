//
//  ProposalDetailNameTableViewCell.m
//  DashControl
//
//  Created by Manuel Boyer on 05/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ProposalDetailNameTableViewCell.h"

@implementation ProposalDetailNameTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //Configure the progress view
    _progressView.progressLineWidth = 2;
    _progressView.progressColor = [UIColor blueColor];
    _progressView.progressStrokeColor = [UIColor blueColor];
    _progressView.emptyLineColor = [UIColor lightGrayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithProposal:(DCProposalEntity*)proposal {
    _labelProposalId.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"PROPOSAL ID", @"Proposal Detail View"), proposal.hashProposal];
    _labelProposalName.text = proposal.name;
}

@end
