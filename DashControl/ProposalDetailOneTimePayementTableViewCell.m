//
//  ProposalDetailOneTimePayementTableViewCell.m
//  DashControl
//
//  Created by Manuel Boyer on 05/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ProposalDetailOneTimePayementTableViewCell.h"

@implementation ProposalDetailOneTimePayementTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithProposal:(Proposal*)proposal {
    _labelOneTimePayment.text = NSLocalizedString(@"One-time payment", @"Proposal Detail View");
    
    
    NSString *oneTimePaymentAmountString = [NSString stringWithFormat:@"%d", 1701];
    NSString *dashString = NSLocalizedString(@"DASH", nil);
    NSString *currencyAmountString = [NSString stringWithFormat:@"(%@ %@)", @"365003", @"USD"];
    
    
    NSString *finalString = [NSString stringWithFormat:@"%@ %@ %@", oneTimePaymentAmountString, dashString, currencyAmountString];
    NSMutableAttributedString *mutAttributedString = [[NSMutableAttributedString alloc] initWithString:finalString];
    
    NSRange oneTimePaymentAmountStringRange = [finalString rangeOfString:oneTimePaymentAmountString];
    NSRange currencyAmountStringRange = [finalString rangeOfString:currencyAmountString];
    
    [mutAttributedString beginEditing];
    [mutAttributedString addAttribute:NSFontAttributeName
                                value:[UIFont systemFontOfSize:13.5 weight:UIFontWeightRegular]
                                range:[finalString rangeOfString:finalString]];
    [mutAttributedString addAttribute:NSFontAttributeName
                                value:[UIFont systemFontOfSize:13.5 weight:UIFontWeightSemibold]
                                range:oneTimePaymentAmountStringRange];
    [mutAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:currencyAmountStringRange];
    [mutAttributedString endEditing];
    
    [_labelOneTimePaymentDetail setAttributedText:mutAttributedString];

}

@end
