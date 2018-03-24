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

#import "BaseTriggerDetail.h"

NS_ASSUME_NONNULL_BEGIN

@class DCPersistenceStack;
@class DCExchangeEntity;
@class DCMarketEntity;

@interface PriceTriggerViewModel : NSObject

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;

@property (readonly, strong, nonatomic) NSArray<BaseTriggerDetail *> *items;

- (instancetype)initAsNewWithExchange:(DCExchangeEntity *)exchange market:(DCMarketEntity *)market;

@end

NS_ASSUME_NONNULL_END
