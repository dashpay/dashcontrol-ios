//
//  RSSFeedListTableViewCell.h
//  DashControl
//
//  Created by Manuel Boyer on 09/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSFeedListTableViewCell : UITableViewCell

@property (nonatomic, retain) DCPostEntity *currentPost;

@property (weak, nonatomic) IBOutlet UILabel *lbPubDate;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbLink;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewIcon;

//More views...

-(void)cfgViews;

@end
