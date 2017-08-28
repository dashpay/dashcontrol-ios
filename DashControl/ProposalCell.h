//
//  ProposalCell.h
//  DashControl
//
//  Created by Manuel Boyer on 28/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProposalCell : UITableViewCell

@property (nonatomic, retain) Proposal *currentProposal;

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;

-(void)cfgViews;

@end
