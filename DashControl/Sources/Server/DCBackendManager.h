//
//  ChartDataImportManager.h
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCServerBloomFilter.h"

NS_ASSUME_NONNULL_BEGIN

@class HTTPLoaderManager;
@class DCPersistenceStack;

@interface DCBackendManager : NSObject

@property (strong, nonatomic) InjectedClass(DCPersistenceStack) stack;
@property (strong, nonatomic) InjectedClass(HTTPLoaderManager) httpManager;

+ (id _Nonnull )sharedInstance;

-(void)updateBloomFilter:(DCServerBloomFilter* _Nonnull)filter completion:(void (^ _Nullable)(NSError * _Nullable error))completion;

-(void)getBalancesInAddresses:(NSArray* _Nonnull)addresses  completion:(void (^ _Nullable)(NSError * _Nullable error,NSUInteger statusCode, NSArray * _Nullable responseObject))completion;

@end

NS_ASSUME_NONNULL_END
