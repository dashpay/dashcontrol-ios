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

#import "Pair.h"

NS_ASSUME_NONNULL_BEGIN

@implementation Pair

+ (instancetype)first:(nullable id)first second:(nullable id)second {
    return [[self alloc] initWithFirst:first second:second];
}

- (instancetype)initWithFirst:(nullable id)first second:(nullable id)second {
    self = [super init];
    if (self) {
        _first = first;
        _second = second;
    }
    return self;
}

- (BOOL)isEqualToPair:(Pair *)object {
    if (!object) {
        return NO;
    }

    BOOL haveEqualFirstObjects = (self.first == object.first) || [self.first isEqual:object.first];
    if (!haveEqualFirstObjects) {
        return NO;
    }

    BOOL haveEqualSecondObjects = (self.second == object.second) || [self.second isEqual:object.second];
    if (!haveEqualSecondObjects) {
        return NO;
    }

    return YES;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    return [self isEqualToPair:object];
}

- (NSUInteger)hash {
    return self.first.hash ^ self.second.hash;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, first: %@, second: %@>",
                                      NSStringFromClass([self class]), self,
                                      [self.first description] ?: @"nil",
                                      [self.second description] ?: @"nil"];
}

#pragma mark NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    id firstCopy = [self.first respondsToSelector:@selector(copyWithZone:)] ? [self.first copy] : self.first;
    id secondCopy = [self.second respondsToSelector:@selector(copyWithZone:)] ? [self.second copy] : self.second;
    __typeof(self) copy = [[self.class alloc] initWithFirst:firstCopy second:secondCopy];
    return copy;
}

@end

NS_ASSUME_NONNULL_END
