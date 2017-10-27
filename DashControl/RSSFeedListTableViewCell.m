//
//  RSSFeedListTableViewCell.m
//  DashControl
//
//  Created by Manuel Boyer on 09/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "RSSFeedListTableViewCell.h"
#import "UIImageView+AFNetworking.h"

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
    
    // You should not call an ivar from a block (so get a weak reference to the imageView)
    __weak UIImageView *weakImageView = self.imageViewIcon;
    __weak DCPostEntity *weakPost = self.currentPost;
    [self.imageViewIcon setImageWithURLRequest:[NSURLRequest requestWithURL:url] placeholderImage:[UIImage imageNamed:@"dash_icon_tmp"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        UIImageView *strongImageView = weakImageView; // make local strong reference to protect against race conditions
        if (!strongImageView) return;
        
        [weakPost updateCoreSpotlightWithImage:image];
        
        [UIView transitionWithView:strongImageView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            strongImageView.image = image;
                        }
                        completion:NULL];
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];
}



-(void)cfgViews {
    _lbTitle.text = self.currentPost.title;
    //_lbLink.text = self.currentPost.link;
    
    
    /*
     NSRange range = [self.currentPost.text rangeOfString:@"src="];
     NSString *substring = [[[self.currentPost.text substringFromIndex:NSMaxRange(range)] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] firstObject];
     _lbLink.text = substring;
     _lbLink.numberOfLines = 1;
     */
    
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
    
    /*
    [CATransaction setCompletionBlock:^{
        CGFloat detailLabelFontSize = 14.0f;
        NSDictionary *dictAttrib = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,  NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)};
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                       initWithData: [self.currentPost.text dataUsingEncoding:NSUnicodeStringEncoding]
                                                       options: dictAttrib
                                                       documentAttributes: nil
                                                       error: nil];
//         If we want to keep originals style.
//         [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleNone] range:NSMakeRange(0, attributedString.length)];
//         [attributedString beginEditing];
//         [attributedString enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
//         if (value) {
//         UIFont *oldFont = (UIFont *)value;
//         
//         [attributedString removeAttribute:NSFontAttributeName range:range];
//         
//         if ([oldFont.fontName isEqualToString:@"TimesNewRomanPSMT"])
//         [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:detailLabelFontSize weight:UIFontWeightRegular] range:range];
//         else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-BoldMT"])
//         [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:detailLabelFontSize] range:range];
//         else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-ItalicMT"])
//         [attributedString addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:detailLabelFontSize] range:range];
//         else if([oldFont.fontName isEqualToString:@"TimesNewRomanPS-BoldItalicMT"])
//         [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:detailLabelFontSize weight:UIFontWeightSemibold] range:range];
//         else
//         [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:detailLabelFontSize weight:UIFontWeightRegular] range:range];
//         
//         [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:range];
//         }
//         }];
//         [attributedString endEditing];
        
        
        [attributedString setAttributes:@{
                                          NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleNone],
                                          NSFontAttributeName:[UIFont systemFontOfSize:detailLabelFontSize weight:UIFontWeightRegular],
                                          NSForegroundColorAttributeName:[UIColor darkGrayColor]
                                          } range:NSMakeRange(0, attributedString.length)];
        
        _lbLink.attributedText = attributedString;
        _lbLink.numberOfLines = 3;
        //_lbLink.lineBreakMode = NSLineBreakByTruncatingTail;
        
        NSInteger lineCount = 0;
        CGSize labelSize = (CGSize){_lbLink.frame.size.width, MAXFLOAT};
        CGRect requiredSize = [_lbLink.text boundingRectWithSize:labelSize  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _lbLink.font} context:nil];
        
        int charSize = (int)lroundf(_lbLink.font.lineHeight);
        int rHeight = (int)lroundf(requiredSize.size.height);
        lineCount = rHeight/charSize;
        
        if (lineCount < _lbLink.numberOfLines) _lbLink.numberOfLines = lineCount;
    }];
*/
    

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
