//
//  ProposalDetailCompletedPaymentsTableViewCell.m
//  DashControl
//
//  Created by Manuel Boyer on 05/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ProposalDetailCompletedPaymentsTableViewCell.h"

@implementation ProposalDetailCompletedPaymentsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureWithProposal:(Proposal*)proposal {
    _labelCompletedPayments.text = NSLocalizedString(@"Completed payments", @"Proposal Detail View");
    _labelMonthRemaining.text = [NSString stringWithFormat:@"%d %@", proposal.remainingPaymentCount, proposal.remainingPaymentCount>1?NSLocalizedString(@"months remaining", @"Proposal Detail View"):NSLocalizedString(@"month remaining", @"Proposal Detail View")];
    
    NSString *completedPaymentAmountString = [NSString stringWithFormat:@"%d", proposal.totalPaymentCount-proposal.remainingPaymentCount];
    NSString *totallingInString = NSLocalizedString(@"totalling in", @"Proposal Detail View");
    NSString *dashString = NSLocalizedString(@"DASH", nil);
    NSString *currencyAmountString = [NSString stringWithFormat:@"%d", (proposal.totalPaymentCount-proposal.remainingPaymentCount)*proposal.monthlyAmount];
    
    
    NSString *finalString = [NSString stringWithFormat:@"%@ %@ %@ %@", completedPaymentAmountString, totallingInString, currencyAmountString, dashString];
    NSMutableAttributedString *mutAttributedString = [[NSMutableAttributedString alloc] initWithString:finalString];
    
    NSRange dashTotallingInRange = [finalString rangeOfString:[NSString stringWithFormat:@"%@ %@ %@", completedPaymentAmountString, totallingInString, currencyAmountString]];
    //NSRange currencyAmountStringRange = [finalString rangeOfString:currencyAmountString];
    
    [mutAttributedString beginEditing];
    [mutAttributedString addAttribute:NSFontAttributeName
                                value:[UIFont systemFontOfSize:13.5 weight:UIFontWeightRegular]
                                range:[finalString rangeOfString:finalString]];
    [mutAttributedString addAttribute:NSFontAttributeName
                                value:[UIFont systemFontOfSize:13.5 weight:UIFontWeightSemibold]
                                range:dashTotallingInRange];
    [mutAttributedString endEditing];
    
    [_labelCompletedPaymentsDetail setAttributedText:mutAttributedString];

}

@end
