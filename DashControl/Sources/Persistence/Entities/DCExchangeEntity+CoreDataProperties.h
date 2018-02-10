//
//  DCExchangeEntity+CoreDataProperties.h
//  DashControl
//
//  Created by Sam Westrich on 9/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCExchangeEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCExchangeEntity (CoreDataProperties)

+ (NSFetchRequest<DCExchangeEntity *> *)fetchRequest;

@property (nonatomic) int16_t identifier;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSSet<DCMarketEntity *> *markets;
@property (nullable, nonatomic, retain) NSSet<DCChartDataEntryEntity *> *chartData;

@end

@interface DCExchangeEntity (CoreDataGeneratedAccessors)

- (void)addMarketsObject:(DCMarketEntity *)value;
- (void)removeMarketsObject:(DCMarketEntity *)value;
- (void)addMarkets:(NSSet<DCMarketEntity *> *)values;
- (void)removeMarkets:(NSSet<DCMarketEntity *> *)values;

- (void)addChartDataObject:(DCChartDataEntryEntity *)value;
- (void)removeChartDataObject:(DCChartDataEntryEntity *)value;
- (void)addChartData:(NSSet<DCChartDataEntryEntity *> *)values;
- (void)removeChartData:(NSSet<DCChartDataEntryEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
