//
//  RSSFeedListTableViewCell.h
//  DashControl
//
//  Created by Manuel Boyer on 09/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSFeedListTableViewCell : UITableViewCell

@property (nonatomic, retain) Post *currentPost;

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbText;

//More views...

-(void)cfgViews;

@end
