//
//  DCCoreDataManager.m
//  DashControl
//
//  Created by Sam Westrich on 9/1/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCCoreDataManager.h"
#import "DCWalletEntity+CoreDataClass.h"


@implementation DCCoreDataManager

#pragma mark - Singleton Init Methods

+ (instancetype)sharedInstance {
    static DCCoreDataManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mainObjectContext = [[(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer] viewContext];
    }
    return self;
}

-(NSArray * _Nonnull)objectsWithEntityNamed:(NSString*)entityName predicate:(NSPredicate*)predicate inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        if (predicate) {
            [request setPredicate:predicate];
        }
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching wallet addresses");
            return @[];
        }
        return array;
    } else {
        return [self objectsWithEntityNamed:entityName predicate:predicate inContext:self.mainObjectContext error:error];
    }
}

-(id _Nonnull)objectWithEntityNamed:(NSString*)entityName predicate:(NSPredicate*)predicate inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setFetchLimit:1];
        if (predicate) {
            [request setPredicate:predicate];
        }
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching exchange names");
            return nil;
        }
        if (![array count]) return nil;
        return [array objectAtIndex:0];
    } else {
        return [self objectWithEntityNamed:entityName predicate:predicate inContext:self.mainObjectContext error:error];
    }
}


-(NSArray * _Nonnull)objectsWithEntityNamed:(NSString*)entityName inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return [self objectsWithEntityNamed:entityName predicate:nil inContext:context error:error];
}

-(NSUInteger)countObjectsWithEntityNamed:(NSString*)entityName predicate:(NSPredicate*)predicate inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        if (predicate) {
            [request setPredicate:predicate];
        }
        NSUInteger count = [context countForFetchRequest:request error:error];
        if (*error)
        {
            NSLog(@"Error while fetching masternode count");
            return NSUIntegerMax;
        }
        return count;
    } else {
        return [self countObjectsWithEntityNamed:entityName predicate:(NSPredicate*)predicate inContext:self.mainObjectContext error:error];
    }
}

-(NSUInteger)countObjectsWithEntityNamed:(NSString*)entityName inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return [self countObjectsWithEntityNamed:entityName predicate:nil inContext:context error:error];
}

// MARK: - Chart data

-(NSArray *)fetchChartDataForExchangeIdentifier:(NSUInteger)exchangeIdentifier forMarketIdentifier:(NSUInteger)marketIdentifier interval:(ChartTimeInterval)timeInterval startTime:(NSDate*)startTime endTime:(NSDate*)endTime inContext:(NSManagedObjectContext *)context error:(NSError**)error {
    
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCChartDataEntryEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        NSMutableString * query = [@"(exchangeIdentifier == %@) AND (marketIdentifier == %@) AND (interval == %d)" mutableCopy];
        if (startTime) {
            [query appendString:@" AND (time >= %@)"];
        }
        if (endTime) {
            [query appendString:@" AND (time <= %@)"];
        }
        NSPredicate * predicate = [NSPredicate predicateWithFormat:query, @(exchangeIdentifier), @(marketIdentifier),timeInterval, startTime,endTime];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:TRUE]];
        [request setPredicate:predicate];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching %@ with predicate %@", entityDescription.name, predicate);
            return [NSArray array];
        }
        return array;
    } else {
        return [self fetchChartDataForExchangeIdentifier:exchangeIdentifier forMarketIdentifier:marketIdentifier interval:timeInterval startTime:startTime endTime:endTime inContext:self.mainObjectContext error:error];
    }
    
}

-(NSInteger)fetchAutoIncrementIdForExchangeinContext:(NSManagedObjectContext * _Nullable)context error:(NSError**)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCExchangeEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        request.predicate = [NSPredicate predicateWithFormat:@"identifier==max(identifier)"];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching AI %@", entityDescription.name);
        }
        if (![array count]) return 1;
        return [(DCExchangeEntity*)[array objectAtIndex:0] identifier] + 1;
    } else {
        return [self fetchAutoIncrementIdForExchangeinContext:self.mainObjectContext error:error];
    }
}

-(NSInteger)fetchAutoIncrementIdForMarketInContext:(NSManagedObjectContext * _Nullable)context error:(NSError**)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCMarketEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        request.predicate = [NSPredicate predicateWithFormat:@"identifier==max(identifier)"];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching AI %@", entityDescription.name);
        }
        if (![array count]) return 1;
        return [(DCExchangeEntity*)[array objectAtIndex:0] identifier] + 1;
    } else {
        return [self fetchAutoIncrementIdForMarketInContext:self.mainObjectContext error:error];
    }
}

-(NSArray* _Nonnull)marketsInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return [self objectsWithEntityNamed:@"DCMarketEntity" inContext:context error:error];
}

-(NSArray* _Nonnull)marketsForNames:(NSArray* _Nonnull)names inContext:(NSManagedObjectContext * _Nullable)context error:(NSError**)error {
    return [self objectsWithEntityNamed:@"DCMarketEntity" predicate:[NSPredicate predicateWithFormat:@"name IN %@",names] inContext:context error:error];
}

-(NSArray* _Nonnull)exchangesInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return [self objectsWithEntityNamed:@"DCExchangeEntity" inContext:context error:error];
}

-(NSArray* _Nonnull)exchangesForNames:(NSArray* _Nonnull)names inContext:(NSManagedObjectContext * _Nullable)context error:(NSError**)error {
    return [self objectsWithEntityNamed:@"DCExchangeEntity" predicate:[NSPredicate predicateWithFormat:@"name IN %@",names] inContext:context error:error];
}

-(DCMarketEntity* _Nullable)marketNamed:(NSString* _Nonnull)marketName inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return [self objectWithEntityNamed:@"DCMarketEntity" predicate:[NSPredicate predicateWithFormat:@"name = %@",marketName] inContext:context error:error];
}

-(DCExchangeEntity* _Nullable)exchangeNamed:(NSString* _Nonnull)exchangeName inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return [self objectWithEntityNamed:@"DCExchangeEntity" predicate:[NSPredicate predicateWithFormat:@"name = %@",exchangeName] inContext:context error:error];
}

-(DCMarketEntity* _Nullable)marketWithIdentifier:(NSUInteger)marketIdentifier inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error{
    return [self objectWithEntityNamed:@"DCMarketEntity" predicate:[NSPredicate predicateWithFormat:@"identifier = %d",marketIdentifier] inContext:context error:error];
}

-(DCExchangeEntity* _Nullable)exchangeWithIdentifier:(NSUInteger)exchangeIdentifier inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return [self objectWithEntityNamed:@"DCExchangeEntity" predicate:[NSPredicate predicateWithFormat:@"identifier = %d",exchangeIdentifier] inContext:context error:error];
}

// MARK: - Portfolio

-(DCWalletEntity*)walletHavingOneOfAccounts:(NSArray*)accounts withIdentifier:(NSString*)identifier inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return [self objectWithEntityNamed:@"DCWalletEntity" predicate:[NSPredicate predicateWithFormat:@"ANY accounts IN %@ AND identifier == %@",accounts,identifier] inContext:context error:error];
}

-(NSArray * _Nonnull)walletAddressesInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return [self objectsWithEntityNamed:@"DCWalletAddressEntity" inContext:context error:error];
}

-(NSArray * _Nonnull)masternodesInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return [self objectsWithEntityNamed:@"DCMasternodeEntity" inContext:context error:error];
}

-(NSUInteger)countMasternodesInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return [self countObjectsWithEntityNamed:@"DCMasternodeEntity" inContext:context error:error];
}

// MARK: - Wallet Accounts

-(BOOL)hasWalletAccount:(NSString* _Nonnull)accountPublicKeyHash inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return !![self countObjectsWithEntityNamed:@"DCWalletAccountEntity" predicate:[NSPredicate predicateWithFormat:@"hash160Key == %@",accountPublicKeyHash] inContext:context error:error];
}

-(NSArray * _Nonnull)walletAccountsInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return [self objectsWithEntityNamed:@"DCWalletAccountEntity" inContext:context error:error];
}

-(DCWalletAccountEntity*)walletAccountWithPublicKeyHash:(NSString*)publicKeyHash inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return [self objectWithEntityNamed:@"DCWalletAccountEntity" predicate:[NSPredicate predicateWithFormat:@"hash160Key == %@",publicKeyHash] inContext:context error:error];
}

// MARK: - Wallet

-(NSArray * _Nonnull)walletsWithIndentifier:(NSString*)sourceName inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return [self objectWithEntityNamed:@"DCWalletEntity" predicate:[NSPredicate predicateWithFormat:@"identifier ==[c] %@",sourceName] inContext:context error:error];
}

// MARK: - Triggers

-(NSArray * _Nonnull)triggersInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    return [self objectsWithEntityNamed:@"DCTriggerEntity" inContext:context error:error];
}

@end
