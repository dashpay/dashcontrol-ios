//
//  RSSFeedDetailViewController.h
//  DashControl
//
//  Created by Manuel Boyer on 16/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSFeedDetailViewController : UIViewController

@property (nonatomic, retain) Post *currentPost;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;

@end
