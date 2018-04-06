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

#import "APIPortfolio.h"

#import "DCServerBloomFilter.h"
#import "Networking.h"

NS_ASSUME_NONNULL_BEGIN

@implementation APIPortfolio

- (id<HTTPLoaderOperationProtocol>)balanceSumInAddresses:(NSArray<NSString *> *)addresses
                                              completion:(void (^)(NSNumber *_Nullable balance))completion {
    NSParameterAssert(addresses);

    NSString *urlString = [self.baseURLString stringByAppendingString:@"address_info"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *parameters = @{ @"addresses" : addresses ?: @[] };
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_POST parameters:parameters];
    return [self.httpManager sendRequest:request completion:^(id _Nullable parsedData, NSDictionary *_Nullable responseHeaders, NSInteger statusCode, NSError *_Nullable error) {
        if (completion) {
            NSNumber *balance = nil;
            if (!error && [parsedData isKindOfClass:NSDictionary.class]) {
                balance = [(NSDictionary *)parsedData objectForKey:@"balance"];
            }
            completion(balance);
        }
    }];
}

- (id<HTTPLoaderOperationProtocol>)balanceAtAddress:(NSString *)address
                                         completion:(void (^)(NSNumber *_Nullable balance))completion {
    NSParameterAssert(address);

    NSString *urlString = [NSString stringWithFormat:@"https://insight.dash.org/insight-api-dash/addr/%@", address];
    NSURL *url = [NSURL URLWithString:urlString];
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_GET parameters:nil];
    return [self.httpManager sendRequest:request completion:^(id _Nullable parsedData, NSDictionary *_Nullable responseHeaders, NSInteger statusCode, NSError *_Nullable error) {
        if (completion) {
            NSNumber *balance = nil;
            if (!error && [parsedData isKindOfClass:NSDictionary.class]) {
                balance = [(NSDictionary *)parsedData objectForKey:@"balanceSat"];
            }
            completion(balance);
        }
    }];
}

- (id<HTTPLoaderOperationProtocol>)updateBloomFilter:(DCServerBloomFilter *)filter
                                          completion:(void (^)(NSError *_Nullable error))completion {
    NSParameterAssert(filter);

    NSString *urlString = [self.baseURLString stringByAppendingString:@"filter"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSDictionary *parameters = @{
        @"filter" : [filter.filterData base64EncodedStringWithOptions:kNilOptions] ?: @"",
        @"filter_length" : @(filter.length),
        @"hash_count" : @(filter.hashFuncs),
    };
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_POST parameters:parameters];
    return [self sendAuthorizedRequest:request completion:^(id _Nullable parsedData, NSDictionary *_Nullable responseHeaders, NSInteger statusCode, NSError *_Nullable error) {
        if (completion) {
            completion(error);
        }
    }];
}

@end

NS_ASSUME_NONNULL_END
