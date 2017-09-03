//
//  Market+CoreDataProperties.h
//  DashControl
//
//  Created by Sam Westrich on 9/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "Market+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Market (CoreDataProperties)

+ (NSFetchRequest<Market *> *)fetchRequest;

@property (nonatomic) int16_t identifier;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Exchange *> *onExchanges;

@end

@interface Market (CoreDataGeneratedAccessors)

- (void)addOnExchangesObject:(Exchange *)value;
- (void)removeOnExchangesObject:(Exchange *)value;
- (void)addOnExchanges:(NSSet<Exchange *> *)values;
- (void)removeOnExchanges:(NSSet<Exchange *> *)values;

@end

NS_ASSUME_NONNULL_END
