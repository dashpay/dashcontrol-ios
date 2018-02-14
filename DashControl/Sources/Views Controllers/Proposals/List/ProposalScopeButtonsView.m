//
//  ProposalScopeButtonsView.m
//  DashControl
//
//  Created by Manuel Boyer on 08/09/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ProposalScopeButtonsView.h"

@implementation ProposalScopeButtonsView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    _bottomBorder = [CALayer layer];
    _bottomBorder.frame = CGRectMake(0.0f, self.bounds.size.height-0.5, self.bounds.size.width, 0.5f);
    _bottomBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.layer addSublayer:_bottomBorder];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _bottomBorder.frame = CGRectMake(0.0f, self.bounds.size.height-0.5, self.bounds.size.width, 0.5f);
}

@end
