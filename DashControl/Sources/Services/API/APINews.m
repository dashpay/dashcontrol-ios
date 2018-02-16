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

#import "APINews.h"

#import "Networking.h"
#import "DCNewsPostEntity+CoreDataClass.h"
#import "DCPersistenceStack.h"

NS_ASSUME_NONNULL_BEGIN

NSInteger const APINEWS_PAGE_SIZE = 50;

static NSString *const API_BASE_URL = @"https://www2.dash.org/";
static NSString *const API_ENDPOINT = @"blogapi/feed-%@.json";

@interface APINews ()

@property (copy, nonatomic) NSString *apiURLFormat;
@property (copy, nonatomic) NSString *langCode;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation APINews

- (instancetype)init {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(currentLocaleDidChangeNotification:)
                                                     name:NSCurrentLocaleDidChangeNotification
                                                   object:nil];
        [self updateAPIURL];
    }
    return self;
}

- (id<HTTPLoaderOperationProtocol>)fetchNewsForPage:(NSInteger)page completion:(void(^)(BOOL success, BOOL isLastPage))completion {
    NSString *urlString = [NSString stringWithFormat:self.apiURLFormat, @(page)];
    NSURL *url = [NSURL URLWithString:urlString];
    
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_GET parameters:nil];
    return [self.httpManager sendRequest:request completion:^(id _Nullable parsedData, NSDictionary * _Nullable responseHeaders, NSInteger statusCode, NSError * _Nullable error) {
        NSAssert([NSThread isMainThread], nil);
        
        NSArray *items = (NSArray *)parsedData;
        if (items && [items isKindOfClass:[NSArray class]]) {
            if (items.count == 0) {
                if (completion) {
                    completion(YES, YES);
                }

                return;
            }
            
            NSPersistentContainer *container = self.stack.persistentContainer;
            [container performBackgroundTask:^(NSManagedObjectContext * _Nonnull context) {
                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
                
                for (NSDictionary *item in items) {
                    DCNewsPostEntity *entity = [[DCNewsPostEntity alloc] initWithContext:context];
                    entity.langCode = self.langCode;
                    entity.url = [NSString stringWithFormat:@"%@%@", API_BASE_URL, item[@"url"]];
                    entity.title = item[@"title"];
                    entity.date = [self.dateFormatter dateFromString:item[@"date"]];
                    NSString *imageURLPart = item[@"image"];
                    if (imageURLPart) {
                        entity.imageURL = [NSString stringWithFormat:@"%@%@", API_BASE_URL, imageURLPart];
                    }
                }
                
                if (context.hasChanges) {
                    NSError *error = nil;
                    if (![context save:&error]) {
                        DCDebugLog([self class], error);
                    }
                    else {
                        [context reset];
                    }
                }
                
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES, items.count < APINEWS_PAGE_SIZE);
                    });
                }
            }];
        }
        else {
            if (completion) {
                completion(NO, NO);
            }
        }
    }];
}

#pragma mark Private

- (void)updateAPIURL {
    self.langCode = [self preferredLangCode];
    
    if ([self.langCode isEqualToString:@"en"]) {
        self.apiURLFormat = [NSString stringWithFormat:@"%@/%@", API_BASE_URL, API_ENDPOINT];
    }
    else {
        self.apiURLFormat = [NSString stringWithFormat:@"%@/%@/%@", API_BASE_URL, self.langCode, API_ENDPOINT];
    }
}

- (void)currentLocaleDidChangeNotification:(NSNotification *)n {
    [self updateAPIURL];
}

- (NSString *)preferredLangCode {
    NSString *langCode = nil;
    
    NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject;
    if (preferredLanguage.length >= 2) {
        NSString *langCode = [preferredLanguage substringToIndex:2];
        
        if ([langCode isEqualToString:@"zh"]) {
            langCode = @"cn";
        }
        else if ([langCode isEqualToString:@"ja"]) {
            langCode = @"jp";
        }
        else if ([langCode isEqualToString:@"ko"]) {
            langCode = @"kr";
        }
        else if ([langCode isEqualToString:@"es"] || [langCode isEqualToString:@"pt"] || [langCode isEqualToString:@"ru"] || [langCode isEqualToString:@"fr"]) {
            //
        }
    }
    
    if (!langCode) {
        langCode = @"en";
    }
    
    return langCode;
}

@end

NS_ASSUME_NONNULL_END
