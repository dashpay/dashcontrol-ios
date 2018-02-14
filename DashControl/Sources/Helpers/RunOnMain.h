//
//  RunOnMain.h
//
//  Created by Andrew Podkovyrin on 06/12/2017.
//  Copyright © 2017. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#if __cplusplus
extern "C" {
#endif /* __cplusplus */

extern void RunOnMainThread(dispatch_block_t block);

#if __cplusplus
}
#endif /* __cplusplus */

NS_ASSUME_NONNULL_END
