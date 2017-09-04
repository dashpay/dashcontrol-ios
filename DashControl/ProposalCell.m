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
    [[_buttonComments imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [[_buttonMonths imageView] setContentMode: UIViewContentModeScaleAspectFit];
    
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

-(void)cfgViews {
    
    //Name string
    if (TRUE) {
        NSString *nameString = self.currentProposal.name;

        NSString *finalString = [NSString stringWithFormat:@"%@", nameString];
        NSMutableAttributedString *mutAttributedString = [[NSMutableAttributedString alloc] initWithString:finalString];
        
        NSRange nameStringRange = [finalString rangeOfString:nameString];
        
        [mutAttributedString beginEditing];
        [mutAttributedString addAttribute:NSFontAttributeName
                                    value:[UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]
                                    range:nameStringRange];

        [mutAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:nameStringRange];

        [mutAttributedString endEditing];
        
        [_labelName setAttributedText:mutAttributedString];
    }
    
    //Title string
    if (TRUE) {
        NSString *titleString = self.currentProposal.title;
        
        NSString *finalString = [NSString stringWithFormat:@"%@", titleString];
        NSMutableAttributedString *mutAttributedString = [[NSMutableAttributedString alloc] initWithString:finalString];
        
        NSRange titleStringRange = [finalString rangeOfString:titleString];
        
        [mutAttributedString beginEditing];
        [mutAttributedString addAttribute:NSFontAttributeName
                                    value:[UIFont systemFontOfSize:13 weight:UIFontWeightRegular]
                                    range:titleStringRange];
        
        [mutAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:titleStringRange];
        
        [mutAttributedString endEditing];
        
        [_labelTitle setAttributedText:mutAttributedString];
    }
    
    //Dash
    if (TRUE) {
        NSString *dashMonthlyAmountString = [NSString stringWithFormat:@"%d", self.currentProposal.monthlyAmount];
        NSString *dashString = NSLocalizedString(@"Dash", nil);

        
        NSString *finalString = [NSString stringWithFormat:@"%@ %@", dashMonthlyAmountString, dashString];
        NSMutableAttributedString *mutAttributedString = [[NSMutableAttributedString alloc] initWithString:finalString];
        
        NSRange dashMonthlyAmountStringRange = [finalString rangeOfString:dashMonthlyAmountString];
        NSRange dashStringRange = [finalString rangeOfString:dashString];
        
        [mutAttributedString beginEditing];
        [mutAttributedString addAttribute:NSFontAttributeName
                                    value:[UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]
                                    range:dashMonthlyAmountStringRange];
        [mutAttributedString addAttribute:NSFontAttributeName
                                    value:[UIFont systemFontOfSize:17 weight:UIFontWeightThin]
                                    range:dashStringRange];
        
        [mutAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:dashMonthlyAmountStringRange];
        [mutAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:dashStringRange];
        
        [mutAttributedString endEditing];
        
        [_labelDashNumber setAttributedText:mutAttributedString];
    }
    if (TRUE) {
        NSString *perMonthString = NSLocalizedString(@"per month", nil);
        
        NSString *finalString = [NSString stringWithFormat:@"%@", perMonthString];
        NSMutableAttributedString *mutAttributedString = [[NSMutableAttributedString alloc] initWithString:finalString];
        
        NSRange perMonthStringRange = [finalString rangeOfString:perMonthString];
        
        [mutAttributedString beginEditing];
        [mutAttributedString addAttribute:NSFontAttributeName
                                    value:[UIFont systemFontOfSize:13 weight:UIFontWeightRegular]
                                    range:perMonthStringRange];
        
        [mutAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:perMonthStringRange];
        
        [mutAttributedString endEditing];
        
        [_labelDashPerMonth setAttributedText:mutAttributedString];
    }
    
    //By username string
    if (TRUE) {
        NSString *byUsernameString = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"by", @"As in 'by Username'"), self.currentProposal.ownerUsername];
        NSMutableAttributedString *mutAttributedString = [[NSMutableAttributedString alloc] initWithString:byUsernameString];
        NSRange byUsernameRange = [byUsernameString rangeOfString:byUsernameString];
        NSRange usernameRange = [byUsernameString rangeOfString:self.currentProposal.ownerUsername];
        [mutAttributedString beginEditing];
        
        [mutAttributedString addAttribute:NSFontAttributeName
                                    value:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular]
                                    range:byUsernameRange];
        [mutAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:byUsernameRange];
        [mutAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:usernameRange];
        [mutAttributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:usernameRange];
        
        [mutAttributedString endEditing];
        
        [_labelByUsername setAttributedText:mutAttributedString];
    }
    
    [_buttonMonths setTitle:[NSString stringWithFormat:@"%d %@ %@", self.currentProposal.remainingPaymentCount, self.currentProposal.remainingPaymentCount > 1 ? NSLocalizedString(@"months", nil) : NSLocalizedString(@"month", nil), NSLocalizedString(@"remaining", nil)] forState:UIControlStateNormal];
    [_buttonComments setTitle:[NSString stringWithFormat:@"%d %@", self.currentProposal.commentAmount, self.currentProposal.commentAmount > 1 ? NSLocalizedString(@"comments", nil) : NSLocalizedString(@"comment", nil)] forState:UIControlStateNormal];
    
    //progressView;
}
@end
