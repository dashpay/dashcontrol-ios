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

#import "DCChartDataEntryEntity+Extensions.h"

#import "NSManagedObject+DCExtensions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation DCChartDataEntryEntity (Extensions)

+ (nullable NSArray<DCChartDataEntryEntity *> *)chartDataForExchangeIdentifier:(NSInteger)exchangeIdentifier
                                                              marketIdentifier:(NSInteger)marketIdentifier
                                                                      interval:(ChartTimeInterval)timeInterval
                                                                     startTime:(nullable NSDate *)startTime
                                                                       endTime:(nullable NSDate *)endTime
                                                                     inContext:(NSManagedObjectContext *)context {
    NSMutableString *query = [@"(exchangeIdentifier == %@) AND (marketIdentifier == %@) AND (interval == %d)" mutableCopy];
    if (startTime) {
        [query appendString:@" AND (time >= %@)"];
    }
    if (endTime) {
        [query appendString:@" AND (time <= %@)"];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:query,
                                                              @(exchangeIdentifier),
                                                              @(marketIdentifier),
                                                              timeInterval,
                                                              startTime ?: endTime,
                                                              endTime];

    return [self dc_objectsWithPredicate:predicate inContext:context requestConfigureBlock:^(NSFetchRequest *_Nonnull fetchRequest) {
        fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES] ];
    }];
}

@end

NS_ASSUME_NONNULL_END
