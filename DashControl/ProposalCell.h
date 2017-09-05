//
//  ProposalCell.h
//  DashControl
//
//  Created by Manuel Boyer on 28/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBCircularProgressBarView.h>

@interface ProposalCell : UITableViewCell

@property (nonatomic, retain) Proposal *currentProposal;

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelDashNumber;
@property (strong, nonatomic) IBOutlet UILabel *labelDashPerMonth;
@property (strong, nonatomic) IBOutlet UILabel *labelByUsername;

@property (strong, nonatomic) IBOutlet UIButton *buttonMonths;
@property (strong, nonatomic) IBOutlet UIButton *buttonComments;
@property (strong, nonatomic) IBOutlet MBCircularProgressBarView *progressView;


-(void)cfgViews;

@end
