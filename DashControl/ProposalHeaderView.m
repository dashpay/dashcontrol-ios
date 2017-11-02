//
//  BudgetView.m
//  DashControl
//
//  Created by Manuel Boyer on 06/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ProposalHeaderView.h"

@implementation ProposalHeaderView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    _bottomBorder = [CALayer layer];
    _bottomBorder.frame = CGRectMake(0.0f, self.bounds.size.height-0.5, self.bounds.size.width, 0.5f);
    _bottomBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.layer addSublayer:_bottomBorder];
    
    _nearBottomBorder = [CALayer layer];
    _nearBottomBorder.frame = CGRectMake(0.0f, self.bounds.size.height-22.5, self.bounds.size.width, 0.5f);
    _nearBottomBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.layer addSublayer:_nearBottomBorder];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _bottomBorder.frame = CGRectMake(0.0f, self.bounds.size.height-0.5, self.bounds.size.width, 0.5f);
    _nearBottomBorder.frame = CGRectMake(0.0f, self.bounds.size.height-22.5, self.bounds.size.width, 0.5f);
}

-(void)configureWithBudget:(DCBudgetEntity*)budget {
    _labelTotal.text = NSLocalizedString(@"TOTAL", @"Budget view");
    _labelAlloted.text = NSLocalizedString(@"ALLOTED", @"Budget view");
    _labelTotalValue.text = [NSString stringWithFormat:@"%.1f", budget.totalAmount];
    _labelAllotedValue.text = [NSString stringWithFormat:@"%.1f", budget.allotedAmount];
    
    if (TRUE) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_labelTotal.text];
        float spacing = 1.7f;
        [attributedString addAttribute:NSKernAttributeName
                                 value:@(spacing)
                                 range:NSMakeRange(0, [_labelTotal.text length])];
        
        _labelTotal.attributedText = attributedString;
    }
    if (TRUE) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_labelAlloted.text];
        float spacing = 1.7f;
        [attributedString addAttribute:NSKernAttributeName
                                 value:@(spacing)
                                 range:NSMakeRange(0, [_labelAlloted.text length])];
        
        _labelAlloted.attributedText = attributedString;
    }

    if (TRUE) {
        NSString *superBlockValueString = [NSString stringWithFormat:@"%d", budget.superblock];
        NSString *superBlockString = NSLocalizedString(@"Superblock", @"Budget view");
        
        NSString *finalSuperBlockString = [NSString stringWithFormat:@"%@ %@", superBlockValueString, superBlockString];

        NSRange superBlockStringRange = [finalSuperBlockString rangeOfString:superBlockString];
        
        NSMutableAttributedString *mutAttributedString = [[NSMutableAttributedString alloc] initWithString:finalSuperBlockString];
        [mutAttributedString beginEditing];
        [mutAttributedString addAttribute:NSFontAttributeName
                                    value:[UIFont systemFontOfSize:8.6 weight:UIFontWeightRegular]
                                    range:NSMakeRange(0, finalSuperBlockString.length)];
        [mutAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:superBlockStringRange];
        [mutAttributedString endEditing];
        [_labelSuperblock setAttributedText:mutAttributedString];
    }
    if (TRUE) {
        NSInteger numberOfDays = [self daysBetweenDate:[NSDate date] andDate:budget.paymentDate];
        NSString *inXDaysString = [NSString stringWithFormat:NSLocalizedString(@"in %d Days", @"Proposals View"), numberOfDays];

        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterLongStyle];
        [df setTimeStyle:NSDateFormatterNoStyle];
        NSString *dateString = [df stringFromDate:budget.paymentDate];
        
        NSString *finalString = [NSString stringWithFormat:@"%@ %@", inXDaysString, dateString];
        
        NSRange dateStringRange = [finalString rangeOfString:dateString];
        
        NSMutableAttributedString *mutAttributedString = [[NSMutableAttributedString alloc] initWithString:finalString];
        [mutAttributedString beginEditing];
        [mutAttributedString addAttribute:NSFontAttributeName
                                    value:[UIFont systemFontOfSize:8.6 weight:UIFontWeightRegular]
                                    range:NSMakeRange(0, finalString.length)];
        [mutAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:dateStringRange];
        [mutAttributedString endEditing];
        [_labelPaymentDate setAttributedText:mutAttributedString];
    }
}


-(NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

@end
