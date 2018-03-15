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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HTTPLoaderManager;
@class DCPersistenceStack;
@class DCExchangeEntity;
@class DCMarketEntity;
@class HTTPService;
@protocol HTTPLoaderOperationProtocol;

@interface APIPrice : NSObject

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;
@property (strong, nonatomic) InjectedClass(HTTPLoaderManager) httpManager;
@property (strong, nonatomic) InjectedClass(HTTPService) httpService;

- (id<HTTPLoaderOperationProtocol>)fetchMarketsCompletion:(void (^)(NSError *_Nullable error, NSInteger defaultExchangeIdentifier, NSInteger defaultMarketIdentifier))completion;
- (id<HTTPLoaderOperationProtocol>)fetchChartDataForExchange:(DCExchangeEntity *)exchange
                                                      market:(DCMarketEntity *)market
                                                       start:(NSUInteger)start
                                                         end:(NSUInteger)end
                                                  completion:(void (^)(BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
