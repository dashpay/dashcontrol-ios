//
//  RSSFeedDetailViewController.m
//  DashControl
//
//  Created by Manuel Boyer on 16/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "RSSFeedDetailViewController.h"

@interface RSSFeedDetailViewController ()
@property(strong,nonatomic) WKWebView *webView;
@end

@implementation RSSFeedDetailViewController
@synthesize currentPost, managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Content", nil);
    
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.view = _webView;
    
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;

    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.currentPost.link]]];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"webView.loading"]) {
        [self fillNavBar];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fillNavBar];

    [self addObserver:self forKeyPath:@"webView.loading" options:NSKeyValueObservingOptionNew context:NULL];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeObserver:self forKeyPath:@"webView.loading"];
}

-(void)fillNavBar {
    
    if (!_webView) {
        return;
    }
    
    NSMutableArray *buttonsArray = [NSMutableArray new];
    
    if (self.webView.isLoading) {
        UIBarButtonItem *stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopBarButton:)];
        [buttonsArray insertObject:stopButton atIndex:0];
    } else {
        UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadBarButton:)];
        [buttonsArray insertObject:refreshButton atIndex:0];
    }
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"<" style:UIBarButtonItemStylePlain target:self action:@selector(goBackBarButton:)];
    [backButton setEnabled:_webView.canGoBack];
    [buttonsArray addObject:backButton];
    
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@">" style:UIBarButtonItemStylePlain target:self action:@selector(goNextBarButton:)];
    [nextButton setEnabled:_webView.canGoForward];
    [buttonsArray insertObject:nextButton atIndex:0];
    
    [self.navigationItem setRightBarButtonItems:buttonsArray];
}

-(void)goBackBarButton:(UIBarButtonItem*)sender {
    [_webView goBack];
}

-(void)goNextBarButton:(UIBarButtonItem*)sender {
    [_webView goForward];
}

-(void)reloadBarButton:(UIBarButtonItem*)sender {
    [_webView reload];
}

- (void)stopBarButton:(UIBarButtonItem *)sender
{
    [_webView stopLoading];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
