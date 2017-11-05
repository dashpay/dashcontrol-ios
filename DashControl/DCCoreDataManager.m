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

+ (id)sharedInstance {
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

-(NSInteger)fetchAutoIncrementIdForMarketinContext:(NSManagedObjectContext * _Nullable)context error:(NSError**)error {
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
        return [self fetchAutoIncrementIdForMarketinContext:self.mainObjectContext error:error];
    }
}

-(NSArray* _Nonnull)allMarketsInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCMarketEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching market names");
            return [NSArray array];
        }
        return array;
    } else {
        return [self allMarketsInContext:self.mainObjectContext error:error];
    }
}

-(NSArray* _Nonnull)marketsForNames:(NSArray* _Nonnull)names inContext:(NSManagedObjectContext * _Nullable)context error:(NSError**)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCMarketEntity" inManagedObjectContext:context];
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
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCExchangeEntity" inManagedObjectContext:context];
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

-(DCMarketEntity* _Nullable)marketNamed:(NSString* _Nonnull)marketName inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCMarketEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@",marketName];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching exchange names");
            return nil;
        }
        if (![array count]) return nil;
        return [array objectAtIndex:0];
    } else {
        return [self marketNamed:marketName inContext:self.mainObjectContext error:error];
    }
}

-(DCExchangeEntity* _Nullable)exchangeNamed:(NSString* _Nonnull)exchangeName inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCExchangeEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@",exchangeName];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching exchange names");
            return nil;
        }
        if (![array count]) return nil;
        return [array objectAtIndex:0];
    } else {
        return [self exchangeNamed:exchangeName inContext:self.mainObjectContext error:error];
    }
}

-(DCMarketEntity* _Nullable)marketWithIdentifier:(NSUInteger)marketIdentifier inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error{
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCMarketEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        request.predicate = [NSPredicate predicateWithFormat:@"identifier = %d",marketIdentifier];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching exchange names");
            return nil;
        }
        if (![array count]) return nil;
        return [array objectAtIndex:0];
    } else {
        return [self marketWithIdentifier:marketIdentifier inContext:self.mainObjectContext error:error];
    }
}

-(DCExchangeEntity* _Nullable)exchangeWithIdentifier:(NSUInteger)exchangeIdentifier inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCExchangeEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        request.predicate = [NSPredicate predicateWithFormat:@"identifier = %d",exchangeIdentifier];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching exchange names");
            return nil;
        }
        if (![array count]) return nil;
        return [array objectAtIndex:0];
    } else {
        return [self exchangeWithIdentifier:exchangeIdentifier inContext:self.mainObjectContext error:error];
    }
}

// MARK: - Portfolio

-(BOOL)hasWalletAccount:(NSString* _Nonnull)accountPublicKeyHash inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCWalletAccountEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setPredicate:[NSPredicate predicateWithFormat:@"hash160Key == %@",accountPublicKeyHash]];
        NSUInteger count = [context countForFetchRequest:request error:error];
        if (*error)
        {
            NSLog(@"Error while fetching wallet addresses");
            return FALSE;
        }
        return !!count;
    } else {
        return [self hasWalletAccount:accountPublicKeyHash inContext:self.mainObjectContext error:error];
    }
}

-(DCWalletEntity*)walletHavingOneOfAccounts:(NSArray*)accounts withIdentifier:(NSString*)identifier inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCWalletEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setPredicate:[NSPredicate predicateWithFormat:@"ANY accounts IN %@ AND identifier == %@",accounts,identifier]];
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching wallet addresses");
            return nil;
        }
        
        return array.count?array[0]:nil;
    } else {
        return [self walletHavingOneOfAccounts:accounts withIdentifier:identifier inContext:self.mainObjectContext error:error];
    }
}

-(NSArray * _Nonnull)walletAddressesInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCWalletAddressEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching wallet addresses");
            return @[];
        }
        return array;
    } else {
        return [self walletAddressesInContext:self.mainObjectContext error:error];
    }
}

-(NSArray * _Nonnull)masternodesInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCMasternodeEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching masternodes");
            return @[];
        }
        return array;
    } else {
        return [self masternodesInContext:self.mainObjectContext error:error];
    }
}

-(NSUInteger)countMasternodesInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCMasternodeEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSUInteger count = [context countForFetchRequest:request error:error];
        if (*error)
        {
            NSLog(@"Error while fetching masternode count");
            return NSUIntegerMax;
        }
        return count;
    } else {
        return [self countMasternodesInContext:self.mainObjectContext error:error];
    }
}

// MARK: - Wallet Accounts

-(NSArray * _Nonnull)walletAccountsInContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCWalletAccountEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching wallet addresses");
            return @[];
        }
        return array;
    } else {
        return [self walletAccountsInContext:self.mainObjectContext error:error];
        
    }
}

-(DCWalletAccountEntity*)walletAccountWithPublicKeyHash:(NSString*)publicKeyHash inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCWalletAccountEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setPredicate:[NSPredicate predicateWithFormat:@"hash160Key == %@",publicKeyHash]];
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching wallet addresses");
            return nil;
        }
        
        return array.count?array[0]:nil;
    } else {
        return [self walletAccountWithPublicKeyHash:publicKeyHash inContext:self.mainObjectContext error:error];
        
    }
}

// MARK: - Wallet

-(NSArray * _Nonnull)walletsWithIndentifier:(NSString*)sourceName inContext:(NSManagedObjectContext * _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    if (context) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DCWalletEntity" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        [request setPredicate:[NSPredicate predicateWithFormat:@"identifier ==[c] %@",sourceName]];
        NSArray *array = [context executeFetchRequest:request error:error];
        if (*error || array == nil)
        {
            NSLog(@"Error while fetching wallet addresses");
            return @[];
        }
        return array;
    } else {
        return [self walletsWithIndentifier:sourceName inContext:self.mainObjectContext error:error];
        
    }
}

@end
