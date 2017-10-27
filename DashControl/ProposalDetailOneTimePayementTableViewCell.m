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

-(void)configureWithProposal:(DCProposalEntity*)proposal {
    _labelOneTimePayment.text = NSLocalizedString(@"One-time payment", @"Proposal Detail View");
    
    NSString *oneTimePaymentAmountString = [NSString stringWithFormat:@"%d", proposal.monthlyAmount];
    NSString *dashString = NSLocalizedString(@"DASH", nil);
    
    NSError * error = nil;
    NSUserDefaults * standardDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * currentExchangeMarketPair = [standardDefaults objectForKey:CURRENT_EXCHANGE_MARKET_PAIR];
    DCMarketEntity * currentMarket = [[DCCoreDataManager sharedManager] marketNamed:[currentExchangeMarketPair objectForKey:@"market"] inContext:proposal.managedObjectContext error:&error];
    DCExchangeEntity * currentExchange = error?nil:[[DCCoreDataManager sharedManager] exchangeNamed:[currentExchangeMarketPair objectForKey:@"exchange"] inContext:proposal.managedObjectContext error:&error];
    NSDate *startTime;
    NSTimeInterval timeInterval = ChartTimeInterval_15Mins;
    if (!error) {
        currentMarket = currentMarket;
        currentExchange = currentExchange;
        startTime = [NSDate dateWithTimeIntervalSinceNow:-[DCChartTimeFormatter timeIntervalForChartTimeFrame:timeInterval]];
    }
    
    NSArray * chartData = [[DCCoreDataManager sharedManager] fetchChartDataForExchangeIdentifier:currentExchange.identifier forMarketIdentifier:currentMarket.identifier interval:timeInterval startTime:startTime endTime:nil inContext:proposal.managedObjectContext error:&error] ;
    DCChartDataEntryEntity * entry;
    if (!error) {
        entry = [chartData lastObject];
    }
    
    NSString *currencyAmountString = @"";
    if (!error && entry) {
        currencyAmountString = [NSString stringWithFormat:@"(%f %@)", proposal.monthlyAmount * entry.close, [currentExchangeMarketPair objectForKey:@"market"]];
    }
    
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
