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

#import "ProposalDetailTableViewCell.h"

#import <WebKit/WebKit.h>

#import "UIFont+DCStyle.h"
#import "ProposalDetailTableViewCellModel.h"

NS_ASSUME_NONNULL_BEGIN

static CGSize const EXPAND_BUTTON_SIZE = {202.0, 35.0};
static CGFloat const EXPAND_BUTTON_PADDING = 24.0;

static CGFloat ContentShrinkedHeight(void) {
    return [UIScreen mainScreen].bounds.size.height;
}

@interface ProposalDetailTableViewCell () <WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) UIView *expandOverlayView;
@property (strong, nonatomic) UIButton *expandButton;
@property (assign, nonatomic) CGFloat expandedHeight;

@end

@implementation ProposalDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];

        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 1.0) configuration:configuration];
        webView.translatesAutoresizingMaskIntoConstraints = NO;
        webView.navigationDelegate = self;
        webView.backgroundColor = [UIColor whiteColor];
        webView.scrollView.backgroundColor = [UIColor whiteColor];
        webView.scrollView.scrollEnabled = NO;
        webView.scrollView.bounces = NO;
        if (@available(iOS 11.0, *)) {
            webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self.contentView addSubview:webView];
        _webView = webView;

        UIView *expandOverlayView = [[UIView alloc] initWithFrame:CGRectZero];
        expandOverlayView.translatesAutoresizingMaskIntoConstraints = NO;
        expandOverlayView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:expandOverlayView];
        _expandOverlayView = expandOverlayView;

        UIButton *expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
        expandButton.translatesAutoresizingMaskIntoConstraints = NO;
        expandButton.backgroundColor = [UIColor colorWithRed:106.0 / 255.0 green:120.0 / 255.0 blue:141.0 / 255.0 alpha:1.0];
        expandButton.layer.cornerRadius = 4.0;
        expandButton.layer.masksToBounds = YES;
        expandButton.titleLabel.font = [UIFont dc_montserratSemiBoldFontOfSize:11.0];
        [expandButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        NSString *expandButtonTitle = NSLocalizedString(@"Show full description", nil);
        [expandButton setTitle:expandButtonTitle.uppercaseString forState:UIControlStateNormal];
        [expandButton addTarget:self action:@selector(expandButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [expandOverlayView addSubview:expandButton];
        _expandButton = expandButton;

        [NSLayoutConstraint activateConstraints:@[
            [webView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
            [webView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [webView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
            [webView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
            [webView.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor],

            [expandOverlayView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [expandOverlayView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
            [expandOverlayView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],

            [expandButton.topAnchor constraintEqualToAnchor:expandOverlayView.topAnchor constant:EXPAND_BUTTON_PADDING],
            [expandButton.leadingAnchor constraintEqualToAnchor:expandOverlayView.leadingAnchor constant:EXPAND_BUTTON_PADDING],
            [expandButton.bottomAnchor constraintEqualToAnchor:expandOverlayView.bottomAnchor constant:-EXPAND_BUTTON_PADDING],
            [expandButton.widthAnchor constraintEqualToConstant:EXPAND_BUTTON_SIZE.width],
            [expandButton.heightAnchor constraintEqualToConstant:EXPAND_BUTTON_SIZE.height],
        ]];

        // KVO

        [self mvvm_observe:@"viewModel.html" with:^(typeof(self) self, NSString * value) {
            if (!value) {
                return;
            }
            self.expandOverlayView.hidden = YES;
            [self.webView loadHTMLString:self.viewModel.html baseURL:nil];
        }];
    }
    return self;
}

- (void)performSetNeedLayoutOnWebView {
    [self.webView setNeedsLayout];
}

- (void)expandButtonAction {
    self.expandOverlayView.hidden = YES;
    self.viewModel.expanded = YES;
    [self.delegate proposalDetailTableViewCell:self didUpdateHeight:self.expandedHeight];
}

#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    weakify;
    [webView evaluateJavaScript:@"document.readyState" completionHandler:^(id _Nullable result, NSError *_Nullable error) {
        strongify;
        if (!result) {
            return;
        }

        [self.webView evaluateJavaScript:@"document.documentElement.scrollHeight" completionHandler:^(id _Nullable result, NSError *_Nullable error) {
            strongify;

            CGFloat expandedHeight = [result doubleValue];
            CGFloat shrinkedHeight = ContentShrinkedHeight();
            BOOL canExpand = !self.viewModel.expanded && shrinkedHeight < expandedHeight;
            CGFloat height = canExpand ? shrinkedHeight : expandedHeight;
            self.expandedHeight = expandedHeight;
            self.expandOverlayView.hidden = !canExpand;
            [self.delegate proposalDetailTableViewCell:self didUpdateHeight:height];
        }];
    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated && navigationAction.request.URL) {
        [self.delegate proposalDetailTableViewCell:self openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

@end

NS_ASSUME_NONNULL_END
