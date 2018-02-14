//
//  HTTPLoaderOperationProtocol.h
//  DashPriceViewer
//
//  Created by Andrew Podkovyrin on 08/02/2018.
//  Copyright © 2018 Andrew Podkovyrin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HTTPLoaderOperationProtocol <NSObject>

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
