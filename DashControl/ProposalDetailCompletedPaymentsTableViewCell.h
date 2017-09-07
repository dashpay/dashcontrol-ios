//
//  ProposalDetailCompletedPaymentsTableViewCell.h
//  DashControl
//
//  Created by Manuel Boyer on 05/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProposalDetailCompletedPaymentsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelCompletedPayments;
@property (strong, nonatomic) IBOutlet UILabel *labelCompletedPaymentsDetail;
@property (strong, nonatomic) IBOutlet UILabel *labelMonthRemaining;

-(void)configureWithProposal:(Proposal*)proposal;

@end
