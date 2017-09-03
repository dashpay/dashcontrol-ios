//
//  Exchange+CoreDataProperties.h
//  DashControl
//
//  Created by Sam Westrich on 9/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "Exchange+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Exchange (CoreDataProperties)

+ (NSFetchRequest<Exchange *> *)fetchRequest;

@property (nonatomic) int16_t identifier;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Market *> *markets;

@end

@interface Exchange (CoreDataGeneratedAccessors)

- (void)addMarketsObject:(Market *)value;
- (void)removeMarketsObject:(Market *)value;
- (void)addMarkets:(NSSet<Market *> *)values;
- (void)removeMarkets:(NSSet<Market *> *)values;

@end

NS_ASSUME_NONNULL_END
