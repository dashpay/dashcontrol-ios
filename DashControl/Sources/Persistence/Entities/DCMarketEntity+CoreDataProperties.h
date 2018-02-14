//
//  DCMarketEntity+CoreDataProperties.h
//  DashControl
//
//  Created by Sam Westrich on 9/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCMarketEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCMarketEntity (CoreDataProperties)

+ (NSFetchRequest<DCMarketEntity *> *)fetchRequest;

@property (nonatomic) int16_t identifier;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSSet<DCExchangeEntity *> *onExchanges;
@property (nullable, nonatomic, retain) NSSet<DCChartDataEntryEntity *> *chartData;

@end

@interface DCMarketEntity (CoreDataGeneratedAccessors)

- (void)addOnExchangesObject:(DCExchangeEntity *)value;
- (void)removeOnExchangesObject:(DCExchangeEntity *)value;
- (void)addOnExchanges:(NSSet<DCExchangeEntity *> *)values;
- (void)removeOnExchanges:(NSSet<DCExchangeEntity *> *)values;

- (void)addChartDataObject:(DCChartDataEntryEntity *)value;
- (void)removeChartDataObject:(DCChartDataEntryEntity *)value;
- (void)addChartData:(NSSet<DCChartDataEntryEntity *> *)values;
- (void)removeChartData:(NSSet<DCChartDataEntryEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
