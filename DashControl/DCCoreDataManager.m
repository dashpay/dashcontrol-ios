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

-(NSArray *)fetchChartDataForExchange:(DCExchangeSource)exchange forMarket:(DCMarketSource)market startTime:(NSDate*)startTime endTime:(NSDate*)endTime inContext:(NSManagedObjectContext *)context {
    
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
        // [request setPredicate:predicate];
        
        NSError *error;
        NSArray *array = [context executeFetchRequest:request error:&error];
        if (error || array == nil)
        {
            NSLog(@"Error while festching %@ with predicate %@", entityDescription.name, predicate);
        }
        return array;
    } else {
        return [self fetchChartDataForExchange:exchange forMarket:market startTime:startTime endTime:endTime inContext:self.mainObjectContext];
    }
    
}

@end
