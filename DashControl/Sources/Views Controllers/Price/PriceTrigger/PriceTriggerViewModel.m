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

#import "PriceTriggerViewModel.h"

#import "TextFieldTriggerDetail.h"
#import "ValueTriggerDetail.h"
#import "DCExchangeEntity+CoreDataClass.h"
#import "DCMarketEntity+CoreDataClass.h"
#import "NSManagedObject+DCExtensions.h"
#import "DCPersistenceStack.h"

NS_ASSUME_NONNULL_BEGIN

@interface PriceTriggerViewModel ()

@property (copy, nonatomic) NSArray<NSSortDescriptor *> *defaultSortDescriptors;

@end

@implementation PriceTriggerViewModel

- (instancetype)initAsNewWithExchange:(DCExchangeEntity *)exchange market:(DCMarketEntity *)market {
    self = [super init];
    if (self) {
        _defaultSortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];
        
        NSMutableArray *items = [NSMutableArray array];
        {
            ValueTriggerDetail *detail = [[ValueTriggerDetail alloc] initWithType:BaseTriggerDetailType_Exchange
                                                                            title:NSLocalizedString(@"Exchange", nil)];
            detail.value = exchange;
            detail.detail = exchange.name;
            [items addObject:detail];
        }
        {
            ValueTriggerDetail *detail = [[ValueTriggerDetail alloc] initWithType:BaseTriggerDetailType_Market
                                                                            title:NSLocalizedString(@"Market", nil)];
            detail.value = market;
            detail.detail = market.name;
            [items addObject:detail];
        }
        {
            TextFieldTriggerDetail *detail = [[TextFieldTriggerDetail alloc] initWithType:BaseTriggerDetailType_Price
                                                                                    title:NSLocalizedString(@"Price", nil)];
            [items addObject:detail];
        }
        {
            ValueTriggerDetail *detail = [[ValueTriggerDetail alloc] initWithType:BaseTriggerDetailType_AlertType
                                                                            title:NSLocalizedString(@"Alert type", nil)];
            [items addObject:detail];
        }
        _items = [items copy];
    }
    return self;
}

- (nullable NSArray<DCExchangeEntity *> *)availableExchanges {
    NSManagedObjectContext *viewContext = self.stack.persistentContainer.viewContext;
    NSArray<DCExchangeEntity *> *entities = [DCExchangeEntity dc_objectsWithPredicate:nil
                                                                             inContext:viewContext
                                                                 requestConfigureBlock:^(NSFetchRequest *_Nonnull fetchRequest) {
                                                                     fetchRequest.sortDescriptors = self.defaultSortDescriptors;
                                                                 }];
    return entities;
}

- (nullable NSArray<DCMarketEntity *> *)availableMarkets {
    NSManagedObjectContext *viewContext = self.stack.persistentContainer.viewContext;
    NSArray<DCMarketEntity *> *entities = [DCMarketEntity dc_objectsWithPredicate:nil
                                                                             inContext:viewContext
                                                                 requestConfigureBlock:^(NSFetchRequest *_Nonnull fetchRequest) {
                                                                     fetchRequest.sortDescriptors = self.defaultSortDescriptors;
                                                                 }];
    return entities;
}


@end

NS_ASSUME_NONNULL_END
