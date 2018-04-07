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

#import "NavigationTitleButton.h"

#import "UIFont+DCStyle.h"

NS_ASSUME_NONNULL_BEGIN

@interface NavigationTitleButton ()

@property (strong, nonatomic) UIImageView *arrowImageView;
@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation NavigationTitleButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosureIcon"]];
        arrowImageView.contentMode = UIViewContentModeCenter;
        arrowImageView.userInteractionEnabled = NO;
        [self addSubview:arrowImageView];
        _arrowImageView = arrowImageView;

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = [UIFont dc_montserratRegularFontOfSize:17.0];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.userInteractionEnabled = NO;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return self;
}

#define IMAGE_WIDTH 30.0
#define HEIGHT 44.0

- (void)layoutSubviews {
    [super layoutSubviews];

    self.arrowImageView.frame = CGRectMake(0.0, 0.0, IMAGE_WIDTH, HEIGHT);
    self.titleLabel.frame = CGRectMake(IMAGE_WIDTH, 0.0, self.titleLabel.bounds.size.width, HEIGHT);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(IMAGE_WIDTH + self.titleLabel.bounds.size.width + IMAGE_WIDTH, HEIGHT);
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    [UIView animateWithDuration:0.25 animations:^{
        CGFloat alpha = highlighted ? 0.5 : 1.0;
        self.arrowImageView.alpha = alpha;
        self.titleLabel.alpha = alpha;
    }];
}

- (nullable NSString *)title {
    return self.titleLabel.text;
}

- (void)setTitle:(nullable NSString *)title {
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    [self setNeedsLayout];
}

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

- (void)setOpened:(BOOL)opened {
    _opened = opened;

    [UIView animateWithDuration:0.25 animations:^{
        self.arrowImageView.transform = self.opened ? CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90)) : CGAffineTransformIdentity;
    }];
}

@end

NS_ASSUME_NONNULL_END
