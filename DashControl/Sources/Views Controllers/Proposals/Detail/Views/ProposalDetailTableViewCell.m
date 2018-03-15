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
#import "ProposalDetailTableViewCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProposalDetailTableViewCell () <WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;

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

        [@[
            [webView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
            [webView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [webView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
            [webView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
            [webView.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor],
        ] enumerateObjectsUsingBlock:^(NSLayoutConstraint *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            obj.active = YES;
        }];

        // KVO

        [self mvvm_observe:@"viewModel.html" with:^(typeof(self) self, NSString * value) {
            if (!value) {
                return;
            }
            [self.webView loadHTMLString:self.viewModel.html baseURL:nil];
        }];
    }
    return self;
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

            CGFloat height = [result doubleValue];
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
