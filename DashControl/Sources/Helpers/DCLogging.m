//
//  Created by Andrew Podkovyrin
//  Copyright © 2018 dashfoundation. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "DCLogging.h"

NS_ASSUME_NONNULL_BEGIN

extern void DCDebugLog(Class contextClass, NSString *formatString, ...) {
#ifdef DEBUG
    va_list args;
    va_start(args, formatString);
    DCLog(contextClass, formatString, args);
    va_end(args);
#endif
}

void DCLog(Class contextClass, NSString *formatString, ...) {
    va_list args;
    va_start(args, formatString);
    NSString *logMessage = ([formatString isKindOfClass:[NSString class]]
                                ? [[NSString alloc] initWithFormat:formatString arguments:args]
                                : [NSString stringWithFormat:@"%@", formatString]);
    va_end(args);

    NSLog(@"%@: %@", NSStringFromClass(contextClass), logMessage);
}

NS_ASSUME_NONNULL_END
