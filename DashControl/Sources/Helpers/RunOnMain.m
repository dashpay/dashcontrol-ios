//
//  RunOnMain.h
//
//  Created by Andrew Podkovyrin on 06/12/2017.
//  Copyright © 2017. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

void RunOnMainThread(dispatch_block_t block) {
    NSCParameterAssert(block);
    if (!block) {
        return;
    }

    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

NS_ASSUME_NONNULL_END
