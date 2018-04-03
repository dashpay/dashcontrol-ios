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

#import "BaseFormCellModel.h"
#import "NamedObject.h"

NS_ASSUME_NONNULL_BEGIN

@class DCPersistenceStack;
@class APITrigger;
@class SelectorFormCellModel;
@class DCTriggerEntity;
@protocol ExchangeMarketPair;

@interface PriceTriggerViewModel : NSObject

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;
@property (strong, nonatomic) InjectedClass(APITrigger) apiTrigger;

@property (readonly, strong, nonatomic) NSArray<BaseFormCellModel *> *items;
@property (readonly, assign, nonatomic) BOOL deleteAvailable;

- (instancetype)initAsNewWithExchangeMarketPair:(nullable NSObject<ExchangeMarketPair> *)exchangeMarketPair;
- (instancetype)initWithTrigger:(DCTriggerEntity *)trigger;
- (instancetype)init NS_UNAVAILABLE;

- (nullable NSArray<id<NamedObject>> *)availableValuesForDetail:(SelectorFormCellModel *)detail;
- (void)selectValue:(id<NamedObject>)value forDetail:(SelectorFormCellModel *)detail;

- (NSInteger)indexOfInvalidDetail;
- (void)saveCurrentTriggerCompletion:(void(^)(NSString *_Nullable errorMessage))completion;
- (void)deleteTriggerCompletion:(void (^)(NSString *_Nullable errorMessage))completion;

@end

NS_ASSUME_NONNULL_END
