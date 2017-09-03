//
//  DCCoreDataManager.m
//  DashControl
//
//  Created by Sam Westrich on 9/1/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCCoreDataManager.h"

@implementation DCCoreDataManager

#pragma mark - Singleton Init Methods

+ (id)sharedManager {
    static DCBackendManager *sharedChartDataImportManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedChartDataImportManager = [[self alloc] init];
    });
    return sharedChartDataImportManager;
}

- (id)init {
    if (self = [super init]) {
        self.mainObjectContext = [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer] viewContext];
    }
    return self;
}

-(NSArray *)fetchChartDataForExchange:(Exchange*)exchange forMarket:(Market*)market startTime:(NSDate*)startTime endTime:(NSDate*)endTime inContext:(NSManagedObjectContext *)context error:(NSError**)error {
    
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ChartDataEntry" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        NSMutableString * query = [@"(exchange == %d) AND (market == %d)" mutableCopy];
        if (startTime) {
            [query appendString:@" AND (time >= %@)"];
        }
        if (endTime) {
            [query appendString:@" AND (time <= %@)"];
        }
        NSPredicate * predicate = [NSPredicate predicateWithFormat:query, exchange, market, startTime,endTime];
        [request setPredicate:predicate];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching %@ with predicate %@", entityDescription.name, predicate);
        }
        return array;
    } else {
        return [self fetchChartDataForExchange:exchange forMarket:market startTime:startTime endTime:endTime inContext:self.mainObjectContext error:error];
    }
    
}

-(NSInteger)fetchAutoIncrementIdForExchangeinContext:(NSManagedObjectContext * _Nullable)context error:(NSError**)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Exchange" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        request.predicate = [NSPredicate predicateWithFormat:@"identifier==max(identifier)"];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching AI %@", entityDescription.name);
        }
        if (![array count]) return 1;
        return [(Exchange*)[array objectAtIndex:0] identifier] + 1;
    } else {
        return [self fetchAutoIncrementIdForExchangeinContext:self.mainObjectContext error:error];
    }
}

-(NSInteger)fetchAutoIncrementIdForMarketinContext:(NSManagedObjectContext * _Nullable)context error:(NSError**)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Market" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        request.predicate = [NSPredicate predicateWithFormat:@"identifier==max(identifier)"];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching AI %@", entityDescription.name);
        }
        if (![array count]) return 1;
        return [(Exchange*)[array objectAtIndex:0] identifier] + 1;
    } else {
        return [self fetchAutoIncrementIdForMarketinContext:self.mainObjectContext error:error];
    }
}

-(NSArray* _Nonnull)marketsForNames:(NSArray* _Nonnull)names inContext:(NSManagedObjectContext * _Nullable)context error:(NSError**)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Market" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        request.predicate = [NSPredicate predicateWithFormat:@"name IN %@",names];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching market names");
            return [NSArray array];
        }
        return array;
    } else {
        return [self marketsForNames:names inContext:self.mainObjectContext error:error];
    }
}

-(NSArray* _Nonnull)exchangesForNames:(NSArray* _Nonnull)names inContext:(NSManagedObjectContext * _Nullable)context error:(NSError**)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Exchange" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        request.predicate = [NSPredicate predicateWithFormat:@"name IN %@",names];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching exchange names");
            return [NSArray array];
        }
        return array;
    } else {
        return [self exchangesForNames:names inContext:self.mainObjectContext error:error];
    }
}

@end
