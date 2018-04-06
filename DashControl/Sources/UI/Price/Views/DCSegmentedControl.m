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

#import "DCSegmentedControl.h"

#import "UIFont+DCStyle.h"

NS_ASSUME_NONNULL_BEGIN

static CGFloat LABEL_WIDTH() {
    if ([UIScreen mainScreen].bounds.size.width == 320.0) {
        return 28.0;
    }
    else {
        return 34.0;
    }
}
static CGFloat const PADDING() {
    if ([UIScreen mainScreen].bounds.size.width == 320.0) {
        return 3.0;
    }
    else {
        return 5.0;
    }
}

@interface DCSegmentedControl ()

@property (nullable, copy, nonatomic) NSArray<UILabel *> *labels;
@property (strong, nonatomic) UIView *selectedView;

@end

@implementation DCSegmentedControl

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setItems:(NSArray<NSString *> *_Nullable)items {
    _items = items;

    [self.labels makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSMutableArray *mutableLabels = [NSMutableArray array];
    for (NSString *item in items) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = item;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont dc_montserratRegularFontOfSize:11.0];
        label.userInteractionEnabled = YES;
        [self addSubview:label];
        [mutableLabels addObject:label];
    }
    self.labels = mutableLabels;
    
    _selectedIndex = 0;

    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self updateSelectedViewFrame];
    }];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.labels.count * LABEL_WIDTH() + (self.labels.count - 1) * PADDING(), 30.0);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self updateSelectedViewFrame];

    CGFloat left = 0.0;
    for (UILabel *label in self.labels) {
        label.frame = CGRectMake(left, 0.0, LABEL_WIDTH(), self.bounds.size.height);
        left += LABEL_WIDTH() + PADDING();
    }
}

#pragma mark - Private

- (void)setupView {
    _selectedView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, LABEL_WIDTH(), 18.0)];
    _selectedView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    _selectedView.layer.cornerRadius = 2.0;
    _selectedView.layer.masksToBounds = YES;
    _selectedView.userInteractionEnabled = NO;
    [self addSubview:_selectedView];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:gestureRecognizer];
}

- (void)updateSelectedViewFrame {
    CGRect selectedViewFrame = self.selectedView.frame;
    selectedViewFrame.origin.x = (LABEL_WIDTH() + PADDING()) * self.selectedIndex;
    selectedViewFrame.origin.y = (self.bounds.size.height - selectedViewFrame.size.height) / 2.0;
    self.selectedView.frame = selectedViewFrame;
}

- (void)tapAction:(UITapGestureRecognizer *)sender {
    UIView *view = sender.view;
    CGPoint location = [sender locationInView:view];
    UILabel *subview = (UILabel *)[view hitTest:location withEvent:nil];
    if (![subview isKindOfClass:[UILabel class]]) {
        return;
    }
    NSUInteger index = [self.labels indexOfObject:subview];
    NSAssert(index != NSNotFound, @"Internal inconsistency");
    
    if (self.selectedIndex == index) {
        return;
    }
    
    self.selectedIndex = index;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end

NS_ASSUME_NONNULL_END
