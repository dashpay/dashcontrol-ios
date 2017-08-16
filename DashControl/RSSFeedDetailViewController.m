//
//  RSSFeedDetailViewController.m
//  DashControl
//
//  Created by Manuel Boyer on 16/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "RSSFeedDetailViewController.h"
#import <WebKit/WebKit.h>

@interface RSSFeedDetailViewController ()

@end

@implementation RSSFeedDetailViewController
@synthesize currentPost, managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Content", nil);
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.view = webView;
    
    [webView loadHTMLString:self.currentPost.content baseURL:nil];
    
#warning TODO: Configure WebKit WebView
    //https://developer.apple.com/documentation/webkit/wkwebview
    
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
