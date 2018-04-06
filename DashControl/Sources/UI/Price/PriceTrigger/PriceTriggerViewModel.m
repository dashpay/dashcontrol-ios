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

#import "DCExchangeEntity+CoreDataClass.h"
#import "DCMarketEntity+CoreDataClass.h"
#import "NSManagedObject+DCExtensions.h"
#import "NSManagedObjectContext+DCExtensions.h"
#import "APITrigger.h"
#import "ButtonFormCellModel.h"
#import "DCPersistenceStack.h"
#import "DCTrigger.h"
#import "DecimalTextFieldFormCellModel.h"
#import "ExchangeMarketPairObject.h"
#import "SelectorFormCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DCExchangeEntity (DCNamedObject) <NamedObject>
@end

@implementation DCExchangeEntity (DCNamedObject)
@end

@interface DCMarketEntity (DCNamedObject) <NamedObject>
@end

@implementation DCMarketEntity (DCNamedObject)
@end

@interface TriggerExchangeAnyValue : NSObject <NamedObject>
@end

@implementation TriggerExchangeAnyValue

- (nullable NSString *)name {
    return NSLocalizedString(@"Any", nil);
}

@end

@interface TriggerAlertTypeValue : NSObject <NamedObject>

@property (readonly, assign, nonatomic) DCTriggerType type;

@end

@implementation TriggerAlertTypeValue

+ (instancetype)type:(DCTriggerType)type {
    return [[self alloc] initWithType:type];
}

- (instancetype)initWithType:(DCTriggerType)type {
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (nullable NSString *)name {
    switch (self.type) {
        case DCTriggerAbove:
            return NSLocalizedString(@"Alert when over", nil);
        case DCTriggerBelow:
            return NSLocalizedString(@"Alert when under", nil);
        case DCTriggerSpikeUp:
            return NSLocalizedString(@"Alert when price rises quickly", nil);
        case DCTriggerSpikeDown:
            return NSLocalizedString(@"Alert when price drops quickly", nil);
        default:
            NSAssert(NO, @"unsupported DCTriggerType");
            return nil;
    }
}

@end

#pragma mark - View Model

typedef NS_ENUM(NSUInteger, TriggerDetailType) {
    TriggerDetailType_Exchange,
    TriggerDetailType_Market,
    TriggerDetailType_Price,
    TriggerDetailType_AlertType,
    TriggerDetailType_AddButton,
};

@interface PriceTriggerViewModel ()

@property (strong, nonatomic) ExchangeMarketPairObject *exchangeMarketPair;
@property (strong, nonatomic) SelectorFormCellModel *exchangeDetail;
@property (strong, nonatomic) SelectorFormCellModel *marketDetail;
@property (strong, nonatomic) DecimalTextFieldFormCellModel *priceDetail;
@property (strong, nonatomic) SelectorFormCellModel *alertTypeDetail;

@property (nullable, strong, nonatomic) DCTriggerEntity *trigger;

@end

@implementation PriceTriggerViewModel

- (instancetype)initAsNewWithExchangeMarketPair:(nullable NSObject<ExchangeMarketPair> *)exchangeMarketPair {
    ExchangeMarketPairObject *exchangeMarketPairObject = exchangeMarketPair
                                                             ? [exchangeMarketPair copy]
                                                             : [[ExchangeMarketPairObject alloc] initWithExchange:nil market:nil];
    TriggerAlertTypeValue *alertTypeValue = [TriggerAlertTypeValue type:DCTriggerAbove];
    return [self initWithExchangeMarketPair:exchangeMarketPairObject
                                 priceValue:nil
                             alertTypeValue:alertTypeValue
                                    trigger:nil];
}

- (instancetype)initWithTrigger:(DCTriggerEntity *)trigger {
    ExchangeMarketPairObject *exchangeMarketPairObject =
        [[ExchangeMarketPairObject alloc] initWithExchange:trigger.exchange market:trigger.market];

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.roundingMode = NSNumberFormatterRoundHalfDown;
    numberFormatter.maximumFractionDigits = 6;
    numberFormatter.minimumFractionDigits = 0;
    numberFormatter.minimumSignificantDigits = 0;
    numberFormatter.maximumSignificantDigits = 6;
    numberFormatter.usesSignificantDigits = YES;
    NSString *priceValue = [numberFormatter stringFromNumber:@(trigger.value)];

    TriggerAlertTypeValue *alertTypeValue = [TriggerAlertTypeValue type:trigger.type];

    return [self initWithExchangeMarketPair:exchangeMarketPairObject
                                 priceValue:priceValue
                             alertTypeValue:alertTypeValue
                                    trigger:trigger];
}

- (instancetype)initWithExchangeMarketPair:(ExchangeMarketPairObject *)exchangeMarketPair
                                priceValue:(nullable NSString *)priceValue
                            alertTypeValue:(TriggerAlertTypeValue *)alertTypeValue
                                   trigger:(nullable DCTriggerEntity *)trigger {
    self = [super init];
    if (self) {
        _exchangeMarketPair = exchangeMarketPair;
        _trigger = trigger;

        NSMutableArray *items = [NSMutableArray array];
        {
            _exchangeDetail = [[SelectorFormCellModel alloc] initWithTitle:NSLocalizedString(@"Exchange", nil)];
            _exchangeDetail.tag = TriggerDetailType_Exchange;
            _exchangeDetail.selectedValue = _exchangeMarketPair.exchange ?: [[TriggerExchangeAnyValue alloc] init];
            [items addObject:_exchangeDetail];
        }
        {
            _marketDetail = [[SelectorFormCellModel alloc] initWithTitle:NSLocalizedString(@"Market", nil)];
            _marketDetail.tag = TriggerDetailType_Market;
            _marketDetail.selectedValue = _exchangeMarketPair.market;
            [items addObject:_marketDetail];
        }
        {
            _priceDetail = [[DecimalTextFieldFormCellModel alloc] initWithTitle:NSLocalizedString(@"Price", nil)
                                                                    placeholder:NSLocalizedString(@"required", nil)];
            _priceDetail.tag = TriggerDetailType_Price;
            _priceDetail.text = priceValue;
            _priceDetail.returnKeyType = UIReturnKeyDone;
            [items addObject:_priceDetail];
        }
        {
            _alertTypeDetail = [[SelectorFormCellModel alloc] initWithTitle:NSLocalizedString(@"Alert type", nil)];
            _alertTypeDetail.tag = TriggerDetailType_AlertType;
            _alertTypeDetail.selectedValue = alertTypeValue;
            [items addObject:_alertTypeDetail];
        }
        {
            NSString *title = _trigger ? NSLocalizedString(@"SAVE", nil) : NSLocalizedString(@"ADD", nil);
            ButtonFormCellModel *detail = [[ButtonFormCellModel alloc] initWithTitle:title];
            detail.tag = TriggerDetailType_AddButton;
            [items addObject:detail];
        }
        _items = [items copy];
    }
    return self;
}

- (BOOL)deleteAvailable {
    return (self.trigger != nil);
}

- (nullable NSArray<id<NamedObject>> *)availableValuesForDetail:(SelectorFormCellModel *)detail {
    if (detail.tag == TriggerDetailType_Exchange) {
        NSMutableArray<id<NamedObject>> *values = [[self.exchangeMarketPair availableExchanges] mutableCopy];
        [values addObject:[[TriggerExchangeAnyValue alloc] init]];
        return values;
    }
    else if (detail.tag == TriggerDetailType_Market) {
        return [self.exchangeMarketPair availableMarkets];
    }
    else if (detail.tag == TriggerDetailType_AlertType) {
        NSArray *values = @[
            [TriggerAlertTypeValue type:DCTriggerAbove],
            [TriggerAlertTypeValue type:DCTriggerBelow],
            [TriggerAlertTypeValue type:DCTriggerSpikeUp],
            [TriggerAlertTypeValue type:DCTriggerSpikeDown],
        ];
        return values;
    }

    NSAssert(NO, @"unhandled detail type");
    return nil;
}

- (void)selectValue:(id<NamedObject>)value forDetail:(SelectorFormCellModel *)detail {
    if (detail.tag == TriggerDetailType_Exchange) {
        NSAssert([value isKindOfClass:DCExchangeEntity.class] || [value isKindOfClass:TriggerExchangeAnyValue.class], nil);
        if ([value isKindOfClass:TriggerExchangeAnyValue.class]) {
            [self.exchangeMarketPair selectExchange:nil];
        }
        else {
            [self.exchangeMarketPair selectExchange:(DCExchangeEntity *)value];
        }

        self.exchangeDetail.selectedValue = value;
        self.marketDetail.selectedValue = self.exchangeMarketPair.market; // update market too, because it might be changed by settings new exchange
    }
    else if (detail.tag == TriggerDetailType_Market) {
        NSAssert([value isKindOfClass:DCMarketEntity.class], nil);
        [self.exchangeMarketPair selectMarket:(DCMarketEntity *)value];

        self.marketDetail.selectedValue = value;
    }
    else if (detail.tag == TriggerDetailType_AlertType) {
        NSAssert([value isKindOfClass:TriggerAlertTypeValue.class], nil);
        self.alertTypeDetail.selectedValue = value;
    }
    else {
        NSAssert(NO, @"unhandled detail type");
    }
}

- (NSInteger)indexOfInvalidDetail {
    for (NSInteger index = 0; index < self.items.count - 1; index++) {
        BaseFormCellModel *detail = self.items[index];
        if ([detail isKindOfClass:SelectorFormCellModel.class]) {
            if ([(SelectorFormCellModel *)detail selectedValue] == nil) {
                return index;
            }
        }
        else if ([detail isKindOfClass:DecimalTextFieldFormCellModel.class]) {
            if ([(DecimalTextFieldFormCellModel *)detail text].length == 0) {
                return index;
            }
        }
    }

    return NSNotFound;
}

- (void)saveCurrentTriggerCompletion:(void (^)(NSString *_Nullable errorMessage))completion {
    NSAssert([self indexOfInvalidDetail] == NSNotFound, @"Validate data before saving");

    TriggerAlertTypeValue *typeValue = self.alertTypeDetail.selectedValue;
    NSNumber *priceValue = @([self.priceDetail.text doubleValue]);
    NSAssert([typeValue isKindOfClass:TriggerAlertTypeValue.class], nil);
    NSString *exchangeName = nil;
    if ([self.exchangeDetail.selectedValue isKindOfClass:DCExchangeEntity.class]) {
        exchangeName = self.exchangeDetail.selectedValue.name;
    }
    NSString *marketName = self.marketDetail.selectedValue.name;

    DCTrigger *trigger = [[DCTrigger alloc] initWithType:typeValue.type
                                                   value:priceValue
                                                exchange:exchangeName
                                                  market:marketName];
    weakify;
    [self.apiTrigger postTrigger:trigger completion:^(NSError *_Nullable error) {
        strongify;
        if (!error && self.trigger) {
            int64_t triggerId = self.trigger.identifier;
            NSPersistentContainer *container = self.stack.persistentContainer;
            [container performBackgroundTask:^(NSManagedObjectContext *context) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %llu", triggerId];
                DCTriggerEntity *trigger = [DCTriggerEntity dc_objectWithPredicate:predicate inContext:context];
                if (trigger) {
                    [context deleteObject:trigger];
                }

                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
                [context dc_saveIfNeeded];

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(nil);
                    }
                });
            }];
        }
        else {
            if (completion) {
                completion(error.localizedDescription);
            }
        }
    }];
}

- (void)deleteTriggerCompletion:(void (^)(NSString *_Nullable errorMessage))completion {
    NSParameterAssert(self.trigger);

    [self.apiTrigger deleteTriggerWithId:self.trigger.identifier completion:^(NSError *_Nullable error) {
        if (completion) {
            completion(error.localizedDescription);
        }
    }];
}

@end

NS_ASSUME_NONNULL_END
