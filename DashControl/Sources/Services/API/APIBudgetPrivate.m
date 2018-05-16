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

#import "APIBudgetPrivate.h"

#import "DCPersistenceStack.h"
#import "Networking.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const API_BASE_URL = @"https://www.dashcentral.org/api/v1";
static NSString *const USER_API_KEY_KEY = @"DC_USER_API_KEY";

@implementation APIBudgetPrivate

- (instancetype)init {
    self = [super init];
    if (self) {
        _userAPIKey = [[NSUserDefaults standardUserDefaults] objectForKey:USER_API_KEY_KEY];
    }
    return self;
}

- (void)setUserAPIKey:(nullable NSString *)userAPIKey {
    _userAPIKey = userAPIKey;

    [[NSUserDefaults standardUserDefaults] setObject:userAPIKey forKey:USER_API_KEY_KEY];
}

- (id<HTTPLoaderOperationProtocol>)postComment:(NSString *)comment
                                  proposalHash:(NSString *)proposalHash
                              replyToCommentId:(nullable NSString *)replyToCommentId
                                    completion:(void (^)(BOOL success))completion {
    NSParameterAssert(self.userAPIKey);

    NSString *urlString = [NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"setappdata"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"api_key"] = self.userAPIKey;
    parameters[@"do"] = @"post_proposal_comment";
    parameters[@"comment"] = comment;
    parameters[@"proposal_hash"] = proposalHash;
    parameters[@"comment_identifier"] = replyToCommentId;
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_POST parameters:parameters];
    weakify;
    return [self.httpManager sendRequest:request completion:^(id _Nullable parsedData, NSDictionary *_Nullable responseHeaders, NSInteger statusCode, NSError *_Nullable error) {
        strongify;
        NSAssert([NSThread isMainThread], nil);

        NSDictionary *dictionary = (NSDictionary *)parsedData;
        if (dictionary && [dictionary isKindOfClass:[NSDictionary class]]) {
            if (completion) {
                completion(YES);
            }
        }
        else {
            if (completion) {
                completion(NO);
            }
        }
    }];
}

@end

NS_ASSUME_NONNULL_END
