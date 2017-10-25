//
//  ProposalDetailOneTimePayementTableViewCell.h
//  DashControl
//
//  Created by Manuel Boyer on 05/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProposalDetailOneTimePayementTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelOneTimePayment;
@property (strong, nonatomic) IBOutlet UILabel *labelOneTimePaymentDetail;

-(void)configureWithProposal:(DCProposalEntity*)proposal;

@end
