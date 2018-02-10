//
//  DCRSSFeedManager.h
//  DashControl
//
//  Created by Manuel Boyer on 09/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCRSSFeedManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext * _Nullable managedObjectContext;

@property (nonatomic, copy) NSArray * _Nullable feedAvailableLanguages; // List of available languages for the feed.
@property (nonatomic, copy) NSString * _Nullable feedLanguage; // By default based on device, can be overridden by user preference (LOCAL_USER_PREF_FEED_LANGUAGE_KEY).
@property (nonatomic, copy) NSURL * _Nullable feedURL; // final source URL for rss feed (DASH_RSS_PREFIX_URL/lang/DASH_RSS_SUFFIX)

+ (id _Nonnull )sharedManager;

@end
