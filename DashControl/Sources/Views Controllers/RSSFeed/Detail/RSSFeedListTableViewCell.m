//
//  RSSFeedListTableViewCell.m
//  DashControl
//
//  Created by Manuel Boyer on 09/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "RSSFeedListTableViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>

@implementation RSSFeedListTableViewCell
@synthesize currentPost;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


-(void)loadImageWithURL:(NSURL*)url {
    
    if (!url) {
        [self.imageViewIcon setImage:[UIImage imageNamed:@"dash_icon_tmp"]];
    }
    
    __weak UIImageView *weakImageView = self.imageViewIcon;
    __weak DCPostEntity *weakPost = self.currentPost;
    [self.imageViewIcon sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"dash_icon_tmp"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (!image) {
            return;
        }
        
        UIImageView *strongImageView = weakImageView;
        if (!strongImageView) {
            return;
        }
        
        [weakPost updateCoreSpotlightWithImage:image];
        
        [UIView transitionWithView:strongImageView
                          duration:cacheType == SDImageCacheTypeNone ? 0.3 : 0.0
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            strongImageView.image = image;
                        }
                        completion:nil];
    }];
}

-(void)cfgViews {
    _lbTitle.text = self.currentPost.title;

    BOOL loadingImageFromText = NO;
    NSDataDetector* detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray* matches = [detector matchesInString:self.currentPost.text options:0 range:NSMakeRange(0, [self.currentPost.text length])];
    NSArray *imageExtensions = @[@"png", @"jpg", @"jpeg", @"gif"];
    for (NSTextCheckingResult *match in matches) {
        NSURL *url = [match URL];
        NSString *extension = [url pathExtension];
        if ([imageExtensions containsObject:extension]) {
            loadingImageFromText = YES;
            [self loadImageWithURL:url];
            break;
        }
        if ([url.absoluteString containsString:@"youtube"] || [url.absoluteString containsString:@"youtu.be"]) {
            NSString *youtubeId = [self extractYoutubeID:url.absoluteString];
            if (youtubeId) {
                loadingImageFromText = YES;
                [self loadImageWithURL:[self youtubeIconURLFromYoutubeId:youtubeId]];
            }
            break;
        }
    }
    if (!loadingImageFromText) {
        [self loadImageWithURL:nil];
    }
    
    _lbLink.text = self.currentPost.link;
    
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    _lbPubDate.text = [df stringFromDate:self.currentPost.pubDate];
}

-(NSString *)extractYoutubeID:(NSString *)youtubeURL
{
    NSString *pattern = @"(?:(?:\.be\/|embed\/|v\/|\\?v=|\&v=|\/videos\/)|(?:[\\w+]+#\\w\/\\w(?:\/[\\w]+)?\/\\w\/))([\\w-_]+)";
    
    NSError *error = NULL;
    NSRegularExpression *regex  = [NSRegularExpression regularExpressionWithPattern: pattern
                                                                            options: NSRegularExpressionCaseInsensitive
                                                                              error: &error];
    NSTextCheckingResult *match = [regex firstMatchInString: youtubeURL
                                                    options: 0
                                                      range: NSMakeRange(0, [youtubeURL length])];
    if ( match ) {
        NSRange videoIDRange             = [match rangeAtIndex:1];
        NSString *substringForFirstMatch = [youtubeURL substringWithRange:videoIDRange];
        
        //NSLog(@"url: %@, Youtube ID: %@", youtubeURL, substringForFirstMatch);
        return substringForFirstMatch;
    } else {
        //NSLog(@"No string matched! %@", youtubeURL);
        return nil;
    }
}

-(NSURL *)youtubeIconURLFromYoutubeId:(NSString *)youtubeId {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", youtubeId]];
}

@end
