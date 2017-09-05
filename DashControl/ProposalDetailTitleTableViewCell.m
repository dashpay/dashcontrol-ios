//
//  ProposalDetailTitleTableViewCell.m
//  DashControl
//
//  Created by Manuel Boyer on 05/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ProposalDetailTitleTableViewCell.h"

@implementation ProposalDetailTitleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithProposal:(Proposal*)proposal {
    _labelTitle.text = NSLocalizedString(@"Title", @"Proposal Detail View");
    _labelProposalTitle.text = proposal.title;
    
    NSString *byUsernameString = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Owner",  @"Proposal Detail View"), proposal.ownerUsername];
    NSMutableAttributedString *mutAttributedString = [[NSMutableAttributedString alloc] initWithString:byUsernameString];
    NSRange byUsernameRange = [byUsernameString rangeOfString:byUsernameString];
    NSRange usernameRange = [byUsernameString rangeOfString:proposal.ownerUsername];
    [mutAttributedString beginEditing];

    [mutAttributedString addAttribute:NSFontAttributeName
                                value:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]
                                range:byUsernameRange];
    [mutAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:byUsernameRange];
    [mutAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:usernameRange];
    [mutAttributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:usernameRange];
    
    [mutAttributedString endEditing];
    
    [_labelProposalOwner setAttributedText:mutAttributedString];
}

@end
