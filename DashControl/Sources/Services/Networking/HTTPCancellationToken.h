//
//  HTTPCancellationToken.h
//
//  Created by Andrew Podkovyrin on 07/02/2018.
//  Copyright © 2018 Dash Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HTTPCancellationToken;

@protocol HTTPCancellationTokenDelegate <NSObject>

- (void)cancellationTokenDidCancel:(id<HTTPCancellationToken>)cancellationToken;

@end

@protocol HTTPCancellationToken <NSObject>

@property (nonatomic, assign, readonly, getter=isCancelled) BOOL cancelled;
@property (nonatomic, weak, readonly, nullable) id<HTTPCancellationTokenDelegate> delegate;
@property (nonatomic, strong, readonly, nullable) id objectToCancel;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
