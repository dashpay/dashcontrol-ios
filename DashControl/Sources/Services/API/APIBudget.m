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

#import "APIBudget.h"

#import <Godzippa/Godzippa.h>

#import "DCBudgetInfoEntity+CoreDataClass.h"
#import "DCBudgetProposalCommentEntity+CoreDataClass.h"
#import "DCBudgetProposalEntity+CoreDataClass.h"
#import "NSManagedObject+DCExtensions.h"
#import "NSManagedObjectContext+DCExtensions.h"
#import "DCPersistenceStack.h"
#import "DSNetworking.h"

NS_ASSUME_NONNULL_BEGIN

CGFloat const MASTERNODES_SUFFICIENT_VOTING_PERCENT = 0.1;

static NSString *const API_BASE_URL = @"https://www.dashcentral.org/api/v1";
static NSString *const API_PARTNER_KEY = @"3a726c82338a0df4e663cf6d58f578de";
static NSString *const MASTERNODES_COUNT_KEY = @"MasternodesCount";
static NSInteger const LAST_MASTERNODES_COUNT = 4756; // fallback

/**
 @discussion https://medium.com/hacking-and-gonzo/how-reddit-ranking-algorithms-work-ef111e33d0d9
 */
static int32_t RedditHotRanking(NSDate *date, int32_t upVotes, int32_t downVotes) {
    // 1390003200 == January 18, 2014, Dash release date
    NSTimeInterval seconds = [date timeIntervalSince1970] - 1390003200;
    int32_t score = upVotes - downVotes;
    double order = log10(MAX(ABS(score), 1.0));
    int8_t sign = 0;
    if (score > 0) {
        sign = 1;
    }
    else if (score < 0) {
        sign = -1;
    }
    int32_t sortOrder = round(sign * order + seconds / 45000.0);
    return sortOrder;
}

@interface APIBudget ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation APIBudget

- (instancetype)init {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        _dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    }
    return self;
}

+ (NSInteger)masternodesCount {
    NSNumber *masternodesCount = [[NSUserDefaults standardUserDefaults] objectForKey:MASTERNODES_COUNT_KEY];
    return masternodesCount ? masternodesCount.integerValue : LAST_MASTERNODES_COUNT;
}

- (void)updateMasternodesCount {
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"public"];
    NSURL *url = [NSURL URLWithString:urlString];
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_GET parameters:nil];
    request.maximumRetryCount = 2; // this request is important
    weakify;
    [self.httpManager sendRequest:request completion:^(id _Nullable parsedData, NSDictionary *_Nullable responseHeaders, NSInteger statusCode, NSError *_Nullable error) {
        strongify;
        NSAssert([NSThread isMainThread], nil);

        NSDictionary *dictionary = (NSDictionary *)parsedData;
        if (dictionary && [dictionary isKindOfClass:[NSDictionary class]]) {
            NSNumber *masternodesCount = dictionary[@"general"][@"consensus_masternodes"];
            if (masternodesCount) {
                [[NSUserDefaults standardUserDefaults] setObject:masternodesCount forKey:MASTERNODES_COUNT_KEY];
            }
        }
    }];
}

- (id<HTTPLoaderOperationProtocol>)fetchActiveProposalsCompletion:(void (^)(BOOL success))completion {
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"budget"];
    NSURL *url = [NSURL URLWithString:urlString];
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_GET parameters:[self authParameters]];
    weakify;
    return [self.httpManager sendRequest:request completion:^(id _Nullable parsedData, NSDictionary *_Nullable responseHeaders, NSInteger statusCode, NSError *_Nullable error) {
        strongify;
        NSAssert([NSThread isMainThread], nil);

        NSDictionary *dictionary = (NSDictionary *)parsedData;
        if (dictionary && [dictionary isKindOfClass:[NSDictionary class]]) {
            NSPersistentContainer *container = self.stack.persistentContainer;
            [container performBackgroundTask:^(NSManagedObjectContext *context) {
                NSDictionary *budgetDictionary = dictionary[@"budget"];
                if (budgetDictionary && [budgetDictionary isKindOfClass:[NSDictionary class]]) {
                    DCBudgetInfoEntity *budget = [DCBudgetInfoEntity dc_objectWithPredicate:nil inContext:context];
                    if (!budget) {
                        budget = [[DCBudgetInfoEntity alloc] initWithContext:context];
                    }

                    budget.totalAmount = [budgetDictionary[@"total_amount"] doubleValue];
                    budget.allotedAmount = [budgetDictionary[@"alloted_amount"] doubleValue];
                    NSString *dateString = budgetDictionary[@"payment_date"];
                    if (dateString) {
                        budget.paymentDate = [self.dateFormatter dateFromString:dateString];
                    }
                    budget.superblock = [budgetDictionary[@"superblock"] intValue];
                }

                NSArray<NSDictionary *> *proposals = dictionary[@"proposals"];
                if ([proposals.firstObject isKindOfClass:[NSDictionary class]]) {
                    for (NSDictionary *proposalDictionary in proposals) {
                        [self parseProposalForDictionary:proposalDictionary commentsArray:nil inContext:context];
                    }
                }

                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
                [context dc_saveIfNeeded];

                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES);
                    });
                }
            }];
        }
        else {
            if (completion) {
                completion(NO);
            }
        }
    }];
}

#define PAST_PROPOSALS_ETAG_KEY @"PastProposalsEtag"

- (id<HTTPLoaderOperationProtocol>)fetchPastProposalsCompletion:(void (^)(BOOL success))completion {
    NSURL *url = [NSURL URLWithString:@"https://proposalhistory.dashpay.info/proposal-history"];
    NSParameterAssert(url);

    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_GET parameters:nil];
    request.downloadTaskPolicy = HTTPRequestDownloadTaskPolicyAlways;
    request.downloadLocationPath = [[[self.class workingDirectory] stringByAppendingPathComponent:[NSUUID UUID].UUIDString] stringByAppendingPathExtension:@"zip"];
    NSString *etag = [[NSUserDefaults standardUserDefaults] objectForKey:PAST_PROPOSALS_ETAG_KEY];
    if (etag) {
        [request addValue:etag forHeader:@"If-None-Match"];
    }

    weakify;
    return [self.httpManager sendRequest:request rawCompletion:^(BOOL success, BOOL cancelled, HTTPResponse *_Nullable response) {
        if (response.statusCode == HTTPResponseStatusCode_NotModified) {
            if (completion) {
                completion(YES);
            }

            return;
        }

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *compressedFilePath = response.request.downloadLocationPath;
        if (!success || ![fileManager fileExistsAtPath:compressedFilePath]) {
            if (completion) {
                completion(NO);
            }

            return;
        }

        void (^completionOnMainThread)(BOOL success) = ^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(success);
                }
            });
        };

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            strongify;

            NSString *decompressedFilePath = [[self.class workingDirectory] stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
            NSURL *compressedFileURL = [NSURL fileURLWithPath:compressedFilePath];
            NSURL *decompressedFileURL = [NSURL fileURLWithPath:decompressedFilePath];
            BOOL success = [fileManager GZipDecompressFile:compressedFileURL
                                     writingContentsToFile:decompressedFileURL
                                                     error:nil];
            [fileManager removeItemAtPath:compressedFilePath error:nil];
            if (!success) {
                completionOnMainThread(NO);

                return;
            }

            NSData *data = [NSData dataWithContentsOfFile:decompressedFilePath];
            [fileManager removeItemAtPath:decompressedFilePath error:nil];
            if (!data) {
                completionOnMainThread(NO);

                return;
            }

            NSArray<NSDictionary *> *proposals = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (!proposals || ![proposals isKindOfClass:NSArray.class]) {
                completionOnMainThread(NO);

                return;
            }

            if (proposals.count == 0) {
                completionOnMainThread(YES);

                return;
            }

            if (![proposals.firstObject isKindOfClass:NSDictionary.class]) {
                completionOnMainThread(NO);

                return;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                NSPersistentContainer *container = self.stack.persistentContainer;
                [container performBackgroundTask:^(NSManagedObjectContext *context) {
                    for (NSDictionary *proposalDictionary in proposals) {
                        [self parseProposalForDictionary:proposalDictionary commentsArray:nil inContext:context];
                    }

                    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
                    [context dc_saveIfNeeded];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary *responseHeaders = response.responseHeaders;
                        NSString *etag = responseHeaders[@"Etag"];
                        [[NSUserDefaults standardUserDefaults] setObject:etag forKey:PAST_PROPOSALS_ETAG_KEY];

                        if (completion) {
                            completion(YES);
                        }
                    });
                }];
            });
        });
    }];
}

- (id<HTTPLoaderOperationProtocol>)fetchProposalDetails:(DCBudgetProposalEntity *)entity completion:(void (^)(BOOL success))completion {
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"proposal"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableDictionary *parameters = [@{ @"hash" : entity.proposalHash ?: @"0" } mutableCopy];
    [parameters addEntriesFromDictionary:[self authParameters]];
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_GET parameters:parameters];
    weakify;
    return [self.httpManager sendRequest:request completion:^(id _Nullable parsedData, NSDictionary *_Nullable responseHeaders, NSInteger statusCode, NSError *_Nullable error) {
        strongify;
        NSAssert([NSThread isMainThread], nil);

        NSDictionary *dictionary = (NSDictionary *)parsedData;
        if (dictionary && [dictionary isKindOfClass:[NSDictionary class]]) {
            NSPersistentContainer *container = self.stack.persistentContainer;
            [container performBackgroundTask:^(NSManagedObjectContext *context) {
                NSDictionary *proposalDictionary = dictionary[@"proposal"];
                NSArray *commentsArray = dictionary[@"comments"];
                [self parseProposalForDictionary:proposalDictionary commentsArray:commentsArray inContext:context];

                context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
                [context dc_saveIfNeeded];

                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(YES);
                    });
                }
            }];
        }
        else {
            if (completion) {
                completion(NO);
            }
        }
    }];
}

#pragma mark - Private

- (NSDictionary *)authParameters {
    return @{ @"partner" : API_PARTNER_KEY };
}

- (void)parseProposalForDictionary:(NSDictionary *)proposalDictionary
                     commentsArray:(nullable NSArray<NSDictionary *> *)commentsArray
                         inContext:(NSManagedObjectContext *)context {
    DCBudgetProposalEntity *proposal = [[DCBudgetProposalEntity alloc] initWithContext:context];
    proposal.proposalHash = proposalDictionary[@"hash"];
    proposal.name = proposalDictionary[@"name"];
    proposal.title = proposalDictionary[@"title"];
    NSString *dateAddedString = proposalDictionary[@"date_added"];
    if (dateAddedString) {
        proposal.dateAdded = [self.dateFormatter dateFromString:dateAddedString];
    }
    NSString *dateEndString = proposalDictionary[@"date_end"];
    if (dateEndString) {
        proposal.dateEnd = [self.dateFormatter dateFromString:dateEndString];
    }
    NSString *votingDeadline = proposalDictionary[@"voting_deadline"];
    if (votingDeadline) {
        proposal.votingDeadline = [self.dateFormatter dateFromString:votingDeadline];
    }
    proposal.willBeFunded = [proposalDictionary[@"will_be_funded"] boolValue];
    proposal.remainingYesVotesUntilFunding = [proposalDictionary[@"remaining_yes_votes_until_funding"] intValue];
    proposal.inNextBudget = [proposalDictionary[@"in_next_budget"] boolValue];
    proposal.monthlyAmount = [proposalDictionary[@"monthly_amount"] intValue];
    proposal.totalPaymentCount = [proposalDictionary[@"total_payment_count"] intValue];
    proposal.remainingPaymentCount = [proposalDictionary[@"remaining_payment_count"] intValue];
    proposal.yesVotesCount = [proposalDictionary[@"yes"] intValue];
    proposal.noVotesCount = [proposalDictionary[@"no"] intValue];
    proposal.abstainVotesCount = [proposalDictionary[@"abstain"] intValue];
    proposal.commentsCount = [proposalDictionary[@"comment_amount"] intValue];
    proposal.ownerUsername = proposalDictionary[@"owner_username"];
    proposal.sortOrder = RedditHotRanking(proposal.dateAdded, proposal.yesVotesCount, proposal.noVotesCount);
    id descriptionHTML = proposalDictionary[@"description_base64_html"];
    if (descriptionHTML) {
        proposal.descriptionHTML = descriptionHTML;
    }

    if ([commentsArray isKindOfClass:NSArray.class] && [commentsArray.firstObject isKindOfClass:NSDictionary.class]) {
        for (NSDictionary *commentDictionary in commentsArray) {
            DCBudgetProposalCommentEntity *comment = [[DCBudgetProposalCommentEntity alloc] initWithContext:context];
            comment.identifier = commentDictionary[@"id"];
            comment.username = commentDictionary[@"username"];
            NSString *dateString = commentDictionary[@"date"];
            if (dateString) {
                comment.date = [self.dateFormatter dateFromString:dateString];
            }
            comment.sortOrder = [commentDictionary[@"order"] intValue];
            comment.level = [commentDictionary[@"level"] intValue];
            comment.recentlyPosted = [commentDictionary[@"recently_posted"] boolValue];
            comment.postedByOwner = [commentDictionary[@"posted_by_owner"] boolValue];
            comment.content = commentDictionary[@"content"];

            if (![proposal.comments containsObject:comment]) {
                [proposal addCommentsObject:comment];
            }
        }
    }
}

+ (NSString *)workingDirectory {
    static NSString *_workingDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _workingDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"dc.files.budget"];
        [[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:_workingDirectory]
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:nil];
    });
    return _workingDirectory;
}

@end

NS_ASSUME_NONNULL_END
