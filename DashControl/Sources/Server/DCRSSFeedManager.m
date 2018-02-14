//
//  DCRSSFeedManager.m
//  DashControl
//
//  Created by Manuel Boyer on 09/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCRSSFeedManager.h"

#import "Networking.h"

#define DASH_RSS_PREFIX_URL @"https://www.dash.org"
#define DASH_RSS_SUFFIX_URL @"rss/dash_blog_rss.xml"

#define LOCAL_USER_PREF_FEED_LANGUAGE_KEY @"LOCAL_USER_PREF_FEED_LANGUAGE_KEY"

#define TICKER_REFRESH_TIME 60.0

@interface DCRSSFeedManager ()
@property (nonatomic, strong) Reachability *reachability;
@end

@implementation DCRSSFeedManager
@synthesize managedObjectContext;
@synthesize feedAvailableLanguages, feedLanguage, feedURL;

#pragma mark - Singleton Init Methods

+ (id)sharedManager {
    static DCRSSFeedManager *sharedRSSFeedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRSSFeedManager = [[self alloc] init];
    });
    return sharedRSSFeedManager;
}

- (id)init {
    if (self = [super init]) {
        self.managedObjectContext = [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer] viewContext];
        self.reachability = [Reachability reachabilityForInternetConnection];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(localeChanged:)
                                                     name:NSCurrentLocaleDidChangeNotification
                                                   object:nil];
        
        feedAvailableLanguages = [[NSArray alloc] initWithObjects:
                                  NSLocalizedString(@"English", @"Available Languages List"),
                                  NSLocalizedString(@"Spanish", @"Available Languages List"),
                                  NSLocalizedString(@"French", @"Available Languages List"),
                                  NSLocalizedString(@"Portugese", @"Available Languages List"),
                                  NSLocalizedString(@"Chinese", @"Available Languages List"),
                                  NSLocalizedString(@"Russian", @"Available Languages List"),
                                  NSLocalizedString(@"Korean", @"Available Languages List"),
                                  nil];
        [self updateFeedURL];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Locale Notification

- (void)localeChanged:(NSNotification *)notification
{
    [self updateFeedURL];
}

#pragma mark - Update preferred Feed Language

-(void)updateFeedURL {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    feedLanguage = ([defs stringForKey:LOCAL_USER_PREF_FEED_LANGUAGE_KEY]) ? [defs stringForKey:LOCAL_USER_PREF_FEED_LANGUAGE_KEY] : [self feedLanguageBasedOnDevice];
    
    if (feedLanguage && [feedLanguage isEqualToString:@"en"]) {
        feedLanguage = nil;
        feedURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/%@", DASH_RSS_PREFIX_URL, DASH_RSS_SUFFIX_URL]];
    }
    else {
        feedURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/%@/%@", DASH_RSS_PREFIX_URL, feedLanguage, DASH_RSS_SUFFIX_URL]];
    }
    
    [self fetchRSSFeed];
}

-(NSString *)feedLanguageBasedOnDevice {
    NSString *feedLangBasedOnDevice = [[[NSLocale preferredLanguages] objectAtIndex:0] substringToIndex:2];
    
    if ([feedLangBasedOnDevice isEqualToString:@"zh"]) {
        feedLangBasedOnDevice = @"cn";
    }
    else if ([feedLangBasedOnDevice isEqualToString:@"ja"]) {
        feedLangBasedOnDevice = @"jp";
    }
    else if ([feedLangBasedOnDevice isEqualToString:@"ko"]) {
        feedLangBasedOnDevice = @"kr";
    }
    else if ([feedLangBasedOnDevice isEqualToString:@"es"] || [feedLangBasedOnDevice isEqualToString:@"pt"] || [feedLangBasedOnDevice isEqualToString:@"ru"] || [feedLangBasedOnDevice isEqualToString:@"fr"]) {
        //
    }

    return feedLangBasedOnDevice;
}

#pragma mark - Fetch and Persist Feed

- (void)fetchRSSFeed {
    return;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fetchRSSFeed) object:nil];
    [self performSelector:@selector(fetchRSSFeed) withObject:nil afterDelay:TICKER_REFRESH_TIME];
    if (self.reachability.currentReachabilityStatus == NotReachable) return;
    
    NSURL *URL = [NSURL URLWithString:feedURL.absoluteString];
    
    HTTPRequest *request = [HTTPRequest requestWithURL:URL method:HTTPRequestMethod_GET parameters:nil];
    __weak typeof(self) weakSelf = self;
    [self.httpManager sendRequest:request rawCompletion:^(BOOL success, BOOL cancelled, HTTPResponse * _Nullable response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        if (cancelled) {
            return;
        }
        
        if (success) {
            [strongSelf parseXML:response.body forLanguage:feedLanguage];
        }
        else {
            // TODO: display error state
        }
    }];

}

-(void)parseXML:(id)responseObject forLanguage:(NSString *)language {
    
    RXMLElement *rootXML;
    if ([responseObject isKindOfClass:[NSData class]]) {
        rootXML = [RXMLElement elementFromXMLData:responseObject];
    }
    
    if (rootXML) {
        
        NSPersistentContainer *container = [(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer];
        [container performBackgroundTask:^(NSManagedObjectContext *context) {
            
            NSDateFormatter *pubDateFormatter = [NSDateFormatter new];
            [pubDateFormatter setDateFormat:@"EEE, dd MMM yyy HH:mm:ss Z"];
            
            [rootXML iterate:@"channel.item" usingBlock: ^(RXMLElement *item) {
                
                DCPostEntity *post;
                NSMutableArray *existingPosts = [self fetchPostWithGUID:[item child:@"guid"].text inContext:context];
                if (!existingPosts.count) {
                    post = [NSEntityDescription insertNewObjectForEntityForName:@"DCPostEntity" inManagedObjectContext:context];
                } else {
                    post = existingPosts.firstObject;
                }
                
                post.lang = language ? language : @"en";
                post.title = [item child:@"title"].text;
                post.text = [item child:@"description"].text;
                post.pubDate = [pubDateFormatter dateFromString:[item child:@"pubDate"].text];
                post.guid = [item child:@"guid"].text;
                post.link = [item child:@"link"].text;
                post.content = [item child:@"encoded"].text;
            }];
             
            context.automaticallyMergesChangesFromParent = TRUE;
            context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
            
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
                abort();
            }
        }];
    }
    
}

#pragma mark - Core Data Utils Methods

-(NSMutableArray *)fetchPostWithGUID:(NSString *)guid inContext:(NSManagedObjectContext *)context {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCPostEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSPredicate *guidPredicate = [NSPredicate predicateWithFormat:@"guid == %@", guid];
        
        [request setPredicate:guidPredicate];
        
        NSError *error;
        NSArray *array = [context executeFetchRequest:request error:&error];
        if (array == nil)
        {
            NSLog(@"Error while festching %@ with predicate %@", entityDescription.name, guidPredicate);
        }
        return [array mutableCopy];
    } else {
        return  nil;
    }
    
}

@end
