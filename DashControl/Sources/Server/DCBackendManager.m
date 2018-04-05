//
//  ChartDataImportManager.m
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCBackendManager.h"

#import <Reachability/Reachability.h>
#import "NSURL+Sugar.h"
#import "DCEnvironment.h"
#import "Networking.h"
#import "DCPersistenceStack.h"

#define DASHCONTROL_SERVER_VERSION 0

#define PRODUCTION_URL @"https://dashpay.info"

#define DEVELOPMENT_URL @"https://dev.dashpay.info"

#define USE_PRODUCTION 1

#define DASHCONTROL_SERVER [NSString stringWithFormat:@"%@/api/v%d/",USE_PRODUCTION?PRODUCTION_URL:DEVELOPMENT_URL,DASHCONTROL_SERVER_VERSION]

#define DASHCONTROL_URL(x)  [DASHCONTROL_SERVER stringByAppendingString:x]
#define DASHCONTROL_MODIFY_URL(x,y) [NSString stringWithFormat:@"%@%@/%@",DASHCONTROL_SERVER,x,y]

@interface DCBackendManager ()
@property (nonatomic, strong) Reachability *reachability;
@end

@implementation DCBackendManager

#pragma mark - Singleton Init Methods

+ (id)sharedInstance {
    static DCBackendManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.reachability = [Reachability reachabilityForInternetConnection];
    }
    return self;
}

#pragma mark - Balances

-(void)getBalancesInAddresses:(NSArray* _Nonnull)addresses  completion:(void (^ _Nullable)(NSError * _Nullable error,NSUInteger statusCode, NSArray * _Nullable responseObject))completion {
    NSURL *url = [NSURL URLWithString:DASHCONTROL_URL(@"address_info")];
    NSDictionary* parameters =@{
                                @"addresses": addresses,
                                };
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_POST parameters:parameters];
    [self.httpManager sendRequest:request completion:^(id  _Nullable parsedData, NSDictionary * _Nullable responseHeaders, NSInteger statusCode, NSError * _Nullable error) {
        if (completion) {
            completion(error, statusCode, parsedData);
        }
    }];
}

#pragma mark - Notifications

-(void)updateBloomFilter:(DCServerBloomFilter*)filter completion:(void (^)(NSError * error))completion {
    NSURL *url = [NSURL URLWithString:DASHCONTROL_URL(@"filter")];
    NSDictionary *parameters = @{
                                 @"filter": [filter.filterData base64EncodedStringWithOptions:kNilOptions],
                                 @"filter_length": @(filter.length),
                                 @"hash_count": @(filter.hashFuncs),
                                 };
    
    HTTPRequest *request = [HTTPRequest requestWithURL:url method:HTTPRequestMethod_POST parameters:parameters];
    [self sendAuthorizedRequest:request completion:^(id  _Nullable parsedData, NSDictionary * _Nullable responseHeaders, NSInteger statusCode, NSError * _Nullable error) {
        if (completion) {
            completion(error);
        }
    }];
}

#pragma mark - Private

- (void)sendAuthorizedRequest:(HTTPRequest *)request completion:(HTTPLoaderCompletionBlock)completion {
    NSString *username = [[DCEnvironment sharedInstance] deviceId];
    NSString *password = [[DCEnvironment sharedInstance] devicePassword];
    NSData *basicAuthCredentials = [[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64AuthCredentials = [basicAuthCredentials base64EncodedStringWithOptions:kNilOptions];
    [request addValue:[NSString stringWithFormat:@"Basic %@", base64AuthCredentials] forHeader:@"Authorization"];
    [self.httpManager sendRequest:request completion:completion];
}

@end
