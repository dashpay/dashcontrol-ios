//
//  DCDataManager.h
//  DashControl
//
//  Created by Sam Westrich on 8/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCDataManager : NSObject

@property (nonatomic, copy) NSString * _Nullable localCurrencyCode; // local currency ISO code
@property (nonatomic, readonly) NSNumber * _Nullable bitcoinDashPrice; // exchange rate in bitcoin per dash
@property (nonatomic, readonly) NSNumber * _Nullable localCurrencyBitcoinPrice; // exchange rate in local currency units per bitcoin
@property (nonatomic, readonly) NSNumber * _Nonnull localCurrencyDashPrice;
@property (nonatomic, readonly) NSArray * _Nullable currencyCodes; // list of supported local currency codes
@property (nonatomic, readonly) NSArray * _Nullable currencyNames; // names for local currency codes

@end
