//
//  RSSFeedDetailViewController.m
//  DashControl
//
//  Created by Manuel Boyer on 16/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "RSSFeedDetailViewController.h"
#import <WebKit/WebKit.h>

@interface RSSFeedDetailViewController () <TTTAttributedLabelDelegate, UIActionSheetDelegate>
@property (nonatomic) TTTAttributedLabel *attributedLabel;
@end

@implementation RSSFeedDetailViewController
@synthesize currentPost, managedObjectContext;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Content", nil);
    
    
    self.attributedLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectInset(self.view.bounds, 10.0f, 70.0f)];
    self.attributedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.attributedLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.attributedLabel.numberOfLines = 0;
    
    self.attributedLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink; // Automatically detect links when the label text is subsequently changed
    self.attributedLabel.delegate = self; // Delegate methods are called when the user taps on a link (see `TTTAttributedLabelDelegate` protocol)
    
    [self.view addSubview:self.attributedLabel];
    self.attributedLabel.text = [self attributedStringWithHTML:self.currentPost.content];
    
}

-(NSAttributedString *)attributedStringWithHTML:(NSString *)HTMLString {
    NSDictionary *options = @{
                              NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType
                              };
    return [[NSAttributedString alloc] initWithData:[HTMLString dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:NULL error:NULL];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    [[[UIActionSheet alloc] initWithTitle:[url absoluteString] delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open Link in Safari", nil), nil] showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
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
