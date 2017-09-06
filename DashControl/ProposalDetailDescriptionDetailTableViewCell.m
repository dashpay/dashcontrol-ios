//
//  ProposalDetailDescriptionDetailTableViewCell.m
//  DashControl
//
//  Created by Manuel Boyer on 05/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ProposalDetailDescriptionDetailTableViewCell.h"

@implementation ProposalDetailDescriptionDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [_labelProposalDescription setPreferredMaxLayoutWidth:self.contentView.bounds.size.width-30];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithProposal:(Proposal*)proposal {

    if (proposal.descriptionBase64Html && proposal.descriptionBase64Html.length) {
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:proposal.descriptionBase64Html options:0];
        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[decodedString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        _labelProposalDescription.attributedText = attrStr;
    }
    else {
        _labelProposalDescription.text = NSLocalizedString(@"Description is loading...", @"Proposal Detail View");
    }

    /*
    NSString *urlString = [NSString stringWithFormat:@"%@", proposal.dwUrl];
    NSMutableAttributedString *mutAttributedString = [[NSMutableAttributedString alloc] initWithString:urlString];

    [mutAttributedString beginEditing];
    [mutAttributedString addAttribute:NSFontAttributeName
                                value:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]
                                range:NSMakeRange(0, urlString.length)];
    [mutAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, urlString.length)];
    [mutAttributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, urlString.length)];
    
    [mutAttributedString endEditing];
    _labelProposalDescription.attributedText = mutAttributedString;
     */
}

@end
