//
//  DCPortfolioManager.m
//  DashControl
//
//  Created by Sam Westrich on 10/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCPortfolioManager.h"
#import "DCCoreDataManager.h"
#import "NSArray+SWAdditions.h"
#import <AFNetworking/AFNetworking.h>
#import "DCWalletAddressEntity+CoreDataClass.h"
#import "DCBackendManager.h"
#import "Networking.h"

#define INSIGHT_API_URL @"https://insight.dash.org/insight-api-dash"

@implementation DCPortfolioManager

+ (id)sharedInstance {
    static DCPortfolioManager *sharedPortfolioManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPortfolioManager = [[self alloc] init];
    });
    return sharedPortfolioManager;
}


-(uint64_t)totalWorthInContext:(NSManagedObjectContext* _Nullable)context error:(NSError*_Nullable* _Nullable)error {
    uint64_t total = 0;
    NSArray * walletAddresses = [[DCCoreDataManager sharedInstance] walletAddressesInContext:context error:error];
    if (*error) return 0;
    NSNumber * walletSum =  [walletAddresses valueForKeyPath:@"@sum.amount"];
    total += [walletSum longLongValue];
    
    NSArray * masternodes = [[DCCoreDataManager sharedInstance] masternodesInContext:context error:error];
    if (*error) return 0;
    NSNumber * masternodeSum =  [masternodes valueForKeyPath:@"@sum.amount"];
    total += [masternodeSum longLongValue];
    
    return total;
}

-(void)amountAtAddress:(NSString*)address clb:(void (^)(uint64_t amount,NSError * _Nullable error))clb {
    NSString *urlString = [NSString stringWithFormat:@"%@/addr/%@",INSIGHT_API_URL,address];
    NSURL *url = [NSURL URLWithString:urlString];
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_GET parameters:nil];
    [self.httpManager sendRequest:request completion:^(id  _Nullable parsedData, NSDictionary * _Nullable responseHeaders, NSInteger statusCode, NSError * _Nullable error) {
        if (clb) {
            clb(0, error);
        }
    }];
}

-(void)updateAmounts {
    NSPersistentContainer *container = [(AppDelegate*)[[UIApplication sharedApplication] delegate] persistentContainer];
    [container performBackgroundTask:^(NSManagedObjectContext *context) {
        NSError * error = nil;
        NSArray * walletAddresses = [[DCCoreDataManager sharedInstance] walletAddressesInContext:context error:&error];
        if (error) return;
        
        NSArray * masternodes = [[DCCoreDataManager sharedInstance] masternodesInContext:context error:&error];
        if (error) return;
        
        
        NSArray * addresses = [[walletAddresses arrayReferencedByKeyPath:@"address"] arrayByAddingObjectsFromArray:[masternodes arrayReferencedByKeyPath:@"address"]];
        
        if ([addresses count]) {
            [[DCBackendManager sharedInstance] getBalancesInAddresses:addresses completion:^(NSError * _Nullable error, NSUInteger statusCode, NSArray * _Nullable responseObject) {
                if (!error && statusCode / 100 == 2) {
                    NSDictionary * addressAmountDictionary = [((NSArray*)responseObject) dictionaryReferencedByKeyPath:@"address" objectPath:@"@sum.satoshis"];
                    BOOL updatedAmounts = FALSE;
                    for (DCWalletAddressEntity * address in walletAddresses) {
                        if ([addressAmountDictionary objectForKey:address.address]) {
                            updatedAmounts = TRUE;
                            [address setAmount:[[addressAmountDictionary objectForKey:address.address] longLongValue]];
                        }
                    }
                    context.automaticallyMergesChangesFromParent = TRUE;
                    context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
                    
                    NSError *error = nil;
                    if (![context save:&error]) {
                        NSLog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
                        abort();
                    }
                    else {
                        
                        if (updatedAmounts) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                                [notificationCenter postNotificationName:PORTFOLIO_DID_UPDATE_NOTIFICATION
                                                                  object:nil
                                                                userInfo:nil];
                            });
                        }
                    }
                }
            }];
        }
    }];
}

@end
