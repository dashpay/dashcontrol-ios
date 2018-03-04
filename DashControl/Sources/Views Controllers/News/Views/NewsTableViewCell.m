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

NS_ASSUME_NONNULL_BEGIN

@interface NewsTableViewCell ()

@property (weak, nullable, nonatomic) IBOutlet UIImageView *newsImageView;
@property (weak, nullable, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (weak, nullable, nonatomic) IBOutlet UILabel *newsDateLabel;

@end

@implementation NewsTableViewCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    if (highlighted) {
        self.contentView.alpha = 0.65;
    }
    else {
        self.contentView.alpha = 1.0;
    }
}

- (void)configureWithTitle:(NSString *_Nullable)title
                dateString:(NSString *_Nullable)dateString
                  imageURL:(NSURL *_Nullable)imageURL {
    self.newsTitleLabel.text = title;
    self.newsDateLabel.text = dateString;
    [self loadImageWithURL:imageURL];
}

- (void)loadImageWithURL:(NSURL *_Nullable)url {
    UIImage *placeholderImage = [UIImage imageNamed:@"dashLogoPlaceholder"];
    weakify;
    [self.newsImageView sd_setImageWithURL:url placeholderImage:placeholderImage completed:^(UIImage *_Nullable image, NSError *_Nullable error, SDImageCacheType cacheType, NSURL *_Nullable imageURL) {
        strongify;
        
        if (!image) {
            return;
        }

        [UIView transitionWithView:self.newsImageView
                          duration:cacheType == SDImageCacheTypeNone ? 0.3 : 0.0
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.newsImageView.image = image;
                        }
                        completion:nil];
    }];
}

@end

NS_ASSUME_NONNULL_END
