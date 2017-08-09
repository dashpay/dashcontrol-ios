//
//  RSSFeedManager.m
//  DashControl
//
//  Created by Manuel Boyer on 09/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "RSSFeedManager.h"

#define DASH_RSS_PREFIX_URL @"https://www.dash.org"
#define DASH_RSS_SUFFIX_URL @"rss/dash_blog_rss.xml"

#define LOCAL_USER_PREF_FEED_LANGUAGE_KEY @"LOCAL_USER_PREF_FEED_LANGUAGE_KEY"

#define TICKER_REFRESH_TIME 60.0

@interface RSSFeedManager ()
@property (nonatomic, strong) Reachability *reachability;
@end

@implementation RSSFeedManager
@synthesize managedObjectContext;
@synthesize feedAvailableLanguages, feedLanguage, feedURL;

#pragma mark - Singleton Init Methods

+ (id)sharedManager {
    static RSSFeedManager *sharedRSSFeedManager = nil;
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
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fetchRSSFeed) object:nil];
    [self performSelector:@selector(fetchRSSFeed) withObject:nil afterDelay:TICKER_REFRESH_TIME];
    if (self.reachability.currentReachabilityStatus == NotReachable) return;
    
    NSURL *URL = [NSURL URLWithString:feedURL.absoluteString];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //manager.responseSerializer.acceptableContentTypes =  [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/xml"];
    [manager GET:URL.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [self parseXML:responseObject forLanguage:feedLanguage];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        /*
         NSHTTPURLResponse *response = (NSHTTPURLResponse *) [operation response];
         NSInteger statusCode = [response statusCode];
         if (statusCode == 404) {
         //We may want to remove feedLanguage from available languages array
         }
         */
    }];
}

-(void)parseXML:(id)responseObject forLanguage:(NSString *)language {
    
    RXMLElement *rootXML;
    if ([responseObject isKindOfClass:[NSData class]]) {
        rootXML = [RXMLElement elementFromXMLData:responseObject];
    }
    
    if (rootXML) {
        
        NSDateFormatter *pubDateFormatter = [NSDateFormatter new];
        [pubDateFormatter setDateFormat:@"EEE, dd MMM yyy HH:mm:ss Z"];
        
        [rootXML iterate:@"channel.item" usingBlock: ^(RXMLElement *item) {
            
            if (![self fetchPostWithGUID:[item child:@"guid"].text].count) {
                Post *post = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.managedObjectContext];
                post.lang = language;
                post.title = [item child:@"title"].text;
                post.text = [item child:@"description"].text;
                post.pubDate = [pubDateFormatter dateFromString:[item child:@"pubDate"].text];
                post.guid = [item child:@"guid"].text;
                post.link = [item child:@"link"].text;
                post.content = [item child:@"encoded"].text;
            }
            
        }];
        
        NSError *error;
        [self.managedObjectContext save:&error];
    }
    
    //NSLog(@"Total Posts: %ld", [[self fetchAllObjectsForEntity:@"Post"] count]);
}

#pragma mark - Core Data Utils Methods

-(NSMutableArray *)fetchPostWithGUID:(NSString *)guid {
    if ([self managedObjectContext]) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSPredicate *guidPredicate = [NSPredicate predicateWithFormat:@"guid == %@", guid];
        
        [request setPredicate:guidPredicate];
        
        NSError *error;
        NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
        if (array == nil)
        {
            NSLog(@"Error while festching %@ with predicate %@", entityDescription.name, guidPredicate);
        }
        return [array mutableCopy];
    } else {
        return  nil;
    }
    
}

-(NSMutableArray*)fetchAllObjectsForEntity:(NSString*)entityName {
    if (self.managedObjectContext) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entity];
        NSError *error = nil;
        NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        if (mutableFetchResults == nil) {
            // Handle the error.
            NSLog(@"Error while fetching all %@ from DB", entityName);
        }
        return mutableFetchResults;
    } else {
        return nil;
    }
}

@end
