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

#import "DCBudgetInfoEntity+CoreDataClass.h"
#import "DCBudgetProposalCommentEntity+CoreDataClass.h"
#import "DCBudgetProposalEntity+CoreDataClass.h"
#import "NSManagedObject+DCExtensions.h"
#import "NSManagedObjectContext+DCExtensions.h"
#import "DCPersistenceStack.h"
#import "Networking.h"

NS_ASSUME_NONNULL_BEGIN

CGFloat const MASTERNODES_SUFFICIENT_VOTING_PERCENT = 0.1;

static NSString *const API_BASE_URL = @"https://www.dashcentral.org/api/v1";
static NSString *const MASTERNODES_COUNT_KEY = @"MasternodesCount";
static NSInteger const LAST_MASTERNODES_COUNT = 4756; // fallback

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
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_GET parameters:nil];
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

- (id<HTTPLoaderOperationProtocol>)fetchProposalDetails:(DCBudgetProposalEntity *)entity completion:(void (^)(BOOL success))completion {
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"proposal"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *parameters = @{ @"hash" : entity.proposalHash ?: @"0" };
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
    id orderValue = proposalDictionary[@"order"];
    if (orderValue && orderValue != [NSNull null]) {
        proposal.sortOrder = [orderValue intValue];
    }
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

@end

NS_ASSUME_NONNULL_END
