//
//  ProposalDetailNameTableViewCell.h
//  DashControl
//
//  Created by Manuel Boyer on 05/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBCircularProgressBarView.h"

@interface ProposalDetailNameTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelProposalId;
@property (strong, nonatomic) IBOutlet UILabel *labelProposalName;
@property (strong, nonatomic) IBOutlet MBCircularProgressBarView *progressView;

-(void)configureWithProposal:(DCProposalEntity*)proposal;

@end
