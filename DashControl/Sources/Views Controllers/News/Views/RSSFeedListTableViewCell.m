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
    static NSDataDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    });
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
        NSString *youtubeId = [self extractYoutubeID:url.absoluteString];
        if (youtubeId) {
            loadingImageFromText = YES;
            [self loadImageWithURL:[self youtubeIconURLFromYoutubeId:youtubeId]];
            
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

- (NSString *)extractYoutubeID:(NSString *)youtubeURL {
    if (!youtubeURL) {
        return nil;
    }
    static NSRegularExpression *regExp = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *regexString = @"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)";
        regExp = [NSRegularExpression regularExpressionWithPattern:regexString
                                                           options:NSRegularExpressionCaseInsensitive
                                                             error:nil];
    });
    
    NSArray *array = [regExp matchesInString:youtubeURL options:0 range:NSMakeRange(0, youtubeURL.length)];
    if (array.count > 0) {
        NSTextCheckingResult *result = array.firstObject;
        return [youtubeURL substringWithRange:result.range];
    }
    return nil;
}

-(NSURL *)youtubeIconURLFromYoutubeId:(NSString *)youtubeId {
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://img.youtube.com/vi/%@/default.jpg", youtubeId]];
}

@end
