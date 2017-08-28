//
//  ProposalCell.m
//  DashControl
//
//  Created by Manuel Boyer on 28/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ProposalCell.h"

@implementation ProposalCell
@synthesize currentProposal;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)cfgViews {
    _labelTitle.text = self.currentProposal.title;
}
@end
