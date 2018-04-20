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

@property (strong, nonatomic) UILabel *dummyTitleLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (assign, nonatomic) CGFloat contentOffset;

@end

@implementation ProposalDetailTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        UILabel *dummyTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dummyTitleLabel.font = [UIFont dc_montserratRegularFontOfSize:17.0];
        dummyTitleLabel.textColor = [UIColor whiteColor];
        dummyTitleLabel.userInteractionEnabled = NO;
        [self addSubview:dummyTitleLabel];
        _dummyTitleLabel = dummyTitleLabel;

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = [UIFont dc_montserratRegularFontOfSize:17.0];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.userInteractionEnabled = NO;
        titleLabel.hidden = YES;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return self;
}

#define HEIGHT 44.0

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat contentOffset = self.contentOffset;
    [self setContentOffset:contentOffset];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, HEIGHT);
}

- (nullable NSString *)dummyTitle {
    return self.dummyTitleLabel.text;
}

- (void)setDummyTitle:(nullable NSString *)dummyTitle {
    self.dummyTitleLabel.text = dummyTitle;
    [self.dummyTitleLabel sizeToFit];
    [self setNeedsLayout];
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
    self.contentOffset = scrollView.contentOffset.y + scrollView.contentInset.top - threshold;
}

#pragma mark Private

- (void)setContentOffset:(CGFloat)contentOffset {
    _contentOffset = contentOffset;

    CGFloat viewWidht = self.bounds.size.width;
    CGRect titleFrame = CGRectMake([self centeredHorizonatalViewPositionForWidth:self.titleLabel.bounds.size.width],
                                   [self titleVerticalPositionAdjustedBy:_contentOffset],
                                   MIN(self.titleLabel.bounds.size.width, viewWidht),
                                   HEIGHT);
    self.titleLabel.frame = titleFrame;
    self.titleLabel.hidden = (titleFrame.origin.y > self.bounds.size.height);
    
    CGRect dummyFrame = CGRectMake([self centeredHorizonatalViewPositionForWidth:self.dummyTitleLabel.bounds.size.width],
                                   titleFrame.origin.y - HEIGHT,
                                   MIN(self.dummyTitleLabel.frame.size.width, viewWidht),
                                   HEIGHT);
    self.dummyTitleLabel.frame = dummyFrame;
    self.dummyTitleLabel.hidden = (dummyFrame.origin.y < -HEIGHT);
}

- (CGFloat)titleVerticalPositionAdjustedBy:(CGFloat)offset {
    CGFloat midY = CGRectGetMidY(self.bounds) - self.titleLabel.bounds.size.height * 0.5;
    return round(MAX(MIN(CGRectGetMaxY(self.bounds) - offset, HEIGHT), midY));
}

- (CGFloat)centeredHorizonatalViewPositionForWidth:(CGFloat)width {
    CGFloat viewX = [self viewOriginXPositionInSuperview];
    CGFloat midX = round((self.bounds.size.width - width) / 2.0);
    CGFloat viewMidX = round(([UIScreen mainScreen].bounds.size.width - self.bounds.size.width) / 2.0);
    CGFloat offset = MAX(viewX - viewMidX, 0.0);
    return MAX(midX - offset, 0.0);
}

- (CGFloat)viewOriginXPositionInSuperview {
    UIView *view = self;
    while (view.superview != nil) {
        if (view.frame.origin.x > 0.0) {
            return view.frame.origin.x;
        }
        view = view.superview;
    }
    return 0.0;
}

@end

NS_ASSUME_NONNULL_END
