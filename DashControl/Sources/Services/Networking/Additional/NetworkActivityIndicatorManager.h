//
//  NetworkActivityIndicatorManager.h
//  DashPriceViewer
//
//  Created by Andrew Podkovyrin on 05/01/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkActivityIndicatorManager : NSObject

+ (void)increaseActivityCounter;
+ (void)decreaseActivityCounter;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
