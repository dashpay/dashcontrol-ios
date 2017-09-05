//
//  ChartDataImportManager.h
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CURRENT_EXCHANGE_MARKET_PAIR @"CURRENT_EXCHANGE_MARKET_PAIR"

@interface DCBackendManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext * _Nullable mainObjectContext;

+ (id _Nonnull )sharedManager;

@end
