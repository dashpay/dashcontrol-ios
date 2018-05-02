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

#import "NewsTableViewCell.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIView+WebCache.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewsTableViewCell ()

@property (weak, nullable, nonatomic) IBOutlet UIImageView *newsImageView;
@property (weak, nullable, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (weak, nullable, nonatomic) IBOutlet UILabel *newsDateLabel;

@end

@implementation NewsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.newsImageView.sd_imageTransition = SDWebImageTransition.fadeTransition;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.alpha = highlighted ? 0.65 : 1.0;
    }];
}

- (void)configureWithTitle:(NSString *_Nullable)title
                dateString:(NSString *_Nullable)dateString
                  imageURL:(NSURL *_Nullable)imageURL {
    self.newsTitleLabel.text = title;
    self.newsDateLabel.text = dateString;
    UIImage *placeholderImage = [UIImage imageNamed:@"dashLogoPlaceholder"];
    [self.newsImageView sd_setImageWithURL:imageURL placeholderImage:placeholderImage];
}

@end

NS_ASSUME_NONNULL_END
