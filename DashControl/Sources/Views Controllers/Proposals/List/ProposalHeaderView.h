//
//  BudgetView.h
//  DashControl
//
//  Created by Manuel Boyer on 06/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProposalHeaderView : UIView
@property (strong, nonatomic) IBOutlet UILabel *labelTotal;
@property (strong, nonatomic) IBOutlet UILabel *labelTotalValue;
@property (strong, nonatomic) IBOutlet UILabel *labelAlloted;
@property (strong, nonatomic) IBOutlet UILabel *labelAllotedValue;
@property (strong, nonatomic) IBOutlet UILabel *labelSuperblock;
@property (strong, nonatomic) IBOutlet UILabel *labelPaymentDate;
@property (strong, nonatomic) CALayer *bottomBorder;
@property (strong, nonatomic) CALayer *nearBottomBorder;
-(void)configureWithBudget:(DCBudgetEntity*)budget;
@end
