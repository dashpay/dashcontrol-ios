//
//  DCDataManager.m
//  DashControl
//
//  Created by Sam Westrich on 8/3/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCDataManager.h"
#import <Reachability/Reachability.h>
#import "DCWalletConstants.h"


#define BITCOIN_TICKER_URL  @"https://bitpay.com/rates"
#define POLONIEX_TICKER_URL  @"https://poloniex.com/public?command=returnOrderBook&currencyPair=BTC_DASH&depth=1"
#define DASHCENTRAL_TICKER_URL  @"https://www.dashcentral.org/api/v1/public"

#define DEFAULT_CURRENCY_CODE @"USD"

#define LOCAL_CURRENCY_CODE_KEY @"LOCAL_CURRENCY_CODE"
#define CURRENCY_CODES_KEY      @"CURRENCY_CODES"
#define CURRENCY_NAMES_KEY      @"CURRENCY_NAMES"
#define CURRENCY_PRICES_KEY     @"CURRENCY_PRICES"
#define POLONIEX_DASH_BTC_PRICE_KEY  @"POLONIEX_DASH_BTC_PRICE"
#define POLONIEX_DASH_BTC_UPDATE_TIME_KEY  @"POLONIEX_DASH_BTC_UPDATE_TIME"
#define DASHCENTRAL_DASH_BTC_PRICE_KEY @"DASHCENTRAL_DASH_BTC_PRICE"
#define DASHCENTRAL_DASH_BTC_UPDATE_TIME_KEY @"DASHCENTRAL_DASH_BTC_UPDATE_TIME"

#define TICKER_REFRESH_TIME 60.0

@interface DCDataManager()

@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) NSNumber * _Nullable bitcoinDashPrice; // exchange rate in bitcoin per dash
@property (nonatomic, strong) NSNumber * _Nullable localCurrencyBitcoinPrice; // exchange rate in local currency units per bitcoin
@property (nonatomic, strong) NSNumber * _Nullable localCurrencyDashPrice;
@property (nonatomic, strong) NSArray * currencyPrices;

@end

@implementation DCDataManager


- (instancetype)init
{
    if (! (self = [super init])) return nil;
    self.reachability = [Reachability reachabilityForInternetConnection];
    
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    
    _currencyCodes = [defs arrayForKey:CURRENCY_CODES_KEY];
    _currencyNames = [defs arrayForKey:CURRENCY_NAMES_KEY];
    _currencyPrices = [defs arrayForKey:CURRENCY_PRICES_KEY];
    self.localCurrencyCode = ([defs stringForKey:LOCAL_CURRENCY_CODE_KEY]) ?
    [defs stringForKey:LOCAL_CURRENCY_CODE_KEY] : [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
    return self;
}

-(NSNumber* _Nonnull)localCurrencyDashPrice {
    if (!_bitcoinDashPrice || !_localCurrencyBitcoinPrice) {
        return _localCurrencyDashPrice;
    } else {
        return @(_bitcoinDashPrice.doubleValue * _localCurrencyBitcoinPrice.doubleValue);
    }
}

-(NSNumber*)bitcoinDashPrice {
    if (_bitcoinDashPrice.doubleValue == 0) {
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        
        double poloniexPrice = [[defs objectForKey:POLONIEX_DASH_BTC_PRICE_KEY] doubleValue];
        double dashcentralPrice = [[defs objectForKey:DASHCENTRAL_DASH_BTC_PRICE_KEY] doubleValue];
        if (poloniexPrice > 0) {
            if (dashcentralPrice > 0) {
                _bitcoinDashPrice = @((poloniexPrice + dashcentralPrice)/2.0);
            } else {
                _bitcoinDashPrice = @(poloniexPrice);
            }
        } else if (dashcentralPrice > 0) {
            _bitcoinDashPrice = @(dashcentralPrice);
        }
    }
    return _bitcoinDashPrice;
}

- (void)refreshBitcoinDashPrice{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    double poloniexPrice = [[defs objectForKey:POLONIEX_DASH_BTC_PRICE_KEY] doubleValue];
    double dashcentralPrice = [[defs objectForKey:DASHCENTRAL_DASH_BTC_PRICE_KEY] doubleValue];
    NSNumber * newPrice = 0;
    if (poloniexPrice > 0) {
        if (dashcentralPrice > 0) {
            newPrice = @((poloniexPrice + dashcentralPrice)/2.0);
        } else {
            newPrice = @(poloniexPrice);
        }
    } else if (dashcentralPrice > 0) {
        newPrice = @(dashcentralPrice);
    }
    
    _bitcoinDashPrice = newPrice;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:BRWalletBalanceChangedNotification object:nil];
    });
}


// until there is a public api for dash prices among multiple currencies it's better that we pull Bitcoin prices per currency and convert it to dash
- (void)updatePoloniexExchangeRate
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updatePoloniexExchangeRate) object:nil];
    [self performSelector:@selector(updatePoloniexExchangeRate) withObject:nil afterDelay:TICKER_REFRESH_TIME];
    if (self.reachability.currentReachabilityStatus == NotReachable) return;
    
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:POLONIEX_TICKER_URL]
                                         cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:req
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
                                         if (((((NSHTTPURLResponse*)response).statusCode /100) != 2) || connectionError) {
                                             NSLog(@"connectionError %@ (status %ld)", connectionError,(long)((NSHTTPURLResponse*)response).statusCode);
                                             return;
                                         }
                                         NSError *error = nil;
                                         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                         NSArray * asks = [json objectForKey:@"asks"];
                                         NSArray * bids = [json objectForKey:@"bids"];
                                         if ([asks count] && [bids count] && [[asks objectAtIndex:0] count] && [[bids objectAtIndex:0] count]) {
                                             NSString * lastTradePriceStringAsks = [[asks objectAtIndex:0] objectAtIndex:0];
                                             NSString * lastTradePriceStringBids = [[bids objectAtIndex:0] objectAtIndex:0];
                                             if (lastTradePriceStringAsks && lastTradePriceStringBids) {
                                                 NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                                                 NSLocale *usa = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                                                 numberFormatter.locale = usa;
                                                 numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
                                                 NSNumber *lastTradePriceNumberAsks = [numberFormatter numberFromString:lastTradePriceStringAsks];
                                                 NSNumber *lastTradePriceNumberBids = [numberFormatter numberFromString:lastTradePriceStringBids];
                                                 NSNumber * lastTradePriceNumber = @((lastTradePriceNumberAsks.floatValue + lastTradePriceNumberBids.floatValue) / 2);
                                                 NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
                                                 [defs setObject:lastTradePriceNumber forKey:POLONIEX_DASH_BTC_PRICE_KEY];
                                                 [defs setObject:[NSDate date] forKey:POLONIEX_DASH_BTC_UPDATE_TIME_KEY];
                                                 [defs synchronize];
                                                 [self refreshBitcoinDashPrice];
                                             }
                                         }
                                     }
      ] resume];
    
}


// until there is a public api for dash prices among multiple currencies it's better that we pull Bitcoin prices per currency and convert it to dash
- (void)updateDashCentralExchangeRate
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateDashCentralExchangeRate) object:nil];
    [self performSelector:@selector(updateDashCentralExchangeRate) withObject:nil afterDelay:TICKER_REFRESH_TIME];
    if (self.reachability.currentReachabilityStatus == NotReachable) return;
    
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:DASHCENTRAL_TICKER_URL]
                                         cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:req
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
                                         if (((((NSHTTPURLResponse*)response).statusCode /100) != 2) || connectionError) {
                                             NSLog(@"connectionError %@ (status %ld)", connectionError,(long)((NSHTTPURLResponse*)response).statusCode);
                                             return;
                                         }
                                         NSError *error = nil;
                                         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                         if (!error) {
                                             NSNumber * dash_usd = @([[[json objectForKey:@"exchange_rates"] objectForKey:@"btc_dash"] doubleValue]);
                                             if (dash_usd && [dash_usd doubleValue] > 0) {
                                                 NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
                                                 
                                                 [defs setObject:dash_usd forKey:DASHCENTRAL_DASH_BTC_PRICE_KEY];
                                                 [defs setObject:[NSDate date] forKey:DASHCENTRAL_DASH_BTC_UPDATE_TIME_KEY];
                                                 [defs synchronize];
                                                 [self refreshBitcoinDashPrice];
                                             }
                                         }
                                     }
      ] resume];
    
}

- (void)updateBitcoinExchangeRate
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateBitcoinExchangeRate) object:nil];
    [self performSelector:@selector(updateBitcoinExchangeRate) withObject:nil afterDelay:TICKER_REFRESH_TIME];
    if (self.reachability.currentReachabilityStatus == NotReachable) return;
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:BITCOIN_TICKER_URL]
                                         cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (((((NSHTTPURLResponse*)response).statusCode /100) != 2) || connectionError) {
            NSLog(@"connectionError %@ (status %ld)", connectionError,(long)((NSHTTPURLResponse*)response).statusCode);
            return;
        }
        
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSMutableArray *codes = [NSMutableArray array], *names = [NSMutableArray array], *rates =[NSMutableArray array];
        
        if (error || ! [json isKindOfClass:[NSDictionary class]] || ! [json[@"data"] isKindOfClass:[NSArray class]]) {
            NSLog(@"unexpected response from %@:\n%@", req.URL.host,
                  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return;
        }
        
        for (NSDictionary *d in json[@"data"]) {
            if (! [d isKindOfClass:[NSDictionary class]] || ! [d[@"code"] isKindOfClass:[NSString class]] ||
                ! [d[@"name"] isKindOfClass:[NSString class]] || ! [d[@"rate"] isKindOfClass:[NSNumber class]]) {
                NSLog(@"unexpected response from %@:\n%@", req.URL.host,
                      [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                return;
            }
            
            if ([d[@"code"] isEqual:@"BTC"]) continue;
            [codes addObject:d[@"code"]];
            [names addObject:d[@"name"]];
            [rates addObject:d[@"rate"]];
        }
        
        self->_currencyCodes = codes;
        self->_currencyNames = names;
        self.currencyPrices = rates;
        self.localCurrencyCode = self.localCurrencyCode; // update localCurrencyPrice and localFormat.maximum
        [defs setObject:self.currencyCodes forKey:CURRENCY_CODES_KEY];
        [defs setObject:self.currencyNames forKey:CURRENCY_NAMES_KEY];
        [defs setObject:self.currencyPrices forKey:CURRENCY_PRICES_KEY];
        [defs synchronize];
    }
      
      
      ] resume];
    
}



@end
