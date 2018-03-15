//
//  Created by Andrew Podkovyrin
//  Copyright © 2018 dashfoundation. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ProposalDetailTitleView.h"

#import "UIFont+DCStyle.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalDetailTitleView ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (assign, nonatomic) CGFloat contentOffset;

@end

@implementation ProposalDetailTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = [UIFont dc_montserratRegularFontOfSize:17.0];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.userInteractionEnabled = NO;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return self;
}

#define HEIGHT 44.0

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat y = self.contentOffset == 0.0 ? CGRectGetMaxY(self.bounds) : [self titleVerticalPositionAdjustedBy:self.contentOffset];
    self.titleLabel.frame = CGRectMake(0.0, y, self.bounds.size.width, HEIGHT);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.titleLabel.bounds.size.width, HEIGHT);
}

- (nullable NSString *)title {
    return self.titleLabel.text;
}

- (void)setTitle:(nullable NSString *)title {
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView threshold:(CGFloat)threshold {
    self.contentOffset = scrollView.contentOffset.y - threshold;
}

#pragma mark Private

- (void)setContentOffset:(CGFloat)contentOffset {
    _contentOffset = contentOffset;

    CGRect frame = self.titleLabel.frame;
    frame.origin.y = [self titleVerticalPositionAdjustedBy:_contentOffset];
    self.titleLabel.frame = frame;
}

- (CGFloat)titleVerticalPositionAdjustedBy:(CGFloat)offset {
    CGFloat midY = CGRectGetMidY(self.bounds) - self.titleLabel.bounds.size.height * 0.5;
    return round(MAX(CGRectGetMaxY(self.bounds) - offset, midY));
}

@end

NS_ASSUME_NONNULL_END
