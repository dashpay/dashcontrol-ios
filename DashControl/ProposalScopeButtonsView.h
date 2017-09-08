//
//  ProposalScopeButtonsView.h
//  DashControl
//
//  Created by Manuel Boyer on 08/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProposalScopeButtonsView : UIView
@property (nonatomic, strong) IBOutlet UISegmentedControl *scopeSegmentedControl;
@property (strong, nonatomic) CALayer *bottomBorder;
@end
