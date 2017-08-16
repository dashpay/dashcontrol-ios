//
//  RSSFeedListTableViewCell.m
//  DashControl
//
//  Created by Manuel Boyer on 09/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "RSSFeedListTableViewCell.h"

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

-(void)cfgViews {
    _lbTitle.text = self.currentPost.title;
    
    /*
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    _lbLink.attributedText = [[NSAttributedString alloc] initWithData:[self.currentPost.text dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:NULL error:NULL];
     */
    
    _lbLink.text = self.currentPost.link;
    
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    _lbPubDate.text = [df stringFromDate:self.currentPost.pubDate];
}

@end
