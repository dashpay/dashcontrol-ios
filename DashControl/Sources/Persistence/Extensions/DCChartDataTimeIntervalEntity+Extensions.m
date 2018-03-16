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

#import "DCChartDataTimeIntervalEntity+Extensions.h"

#import "NSManagedObject+DCExtensions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation DCChartDataTimeIntervalEntity (Extensions)

+ (NSPredicate *)predicateForExchangeIdentifier:(NSInteger)exchangeIdentifier
                               marketIdentifier:(NSInteger)marketIdentifier {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(exchangeIdentifier == %@) AND (marketIdentifier == %@)",
                              @(exchangeIdentifier),
                              @(marketIdentifier)];
    return predicate;
}

+ (nullable NSArray<DCChartDataTimeIntervalEntity *> *)timeIntervalsForExchangeIdentifier:(NSInteger)exchangeIdentifier
                                                                         marketIdentifier:(NSInteger)marketIdentifier
                                                                                inContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [self predicateForExchangeIdentifier:exchangeIdentifier marketIdentifier:marketIdentifier];
    return [self dc_objectsWithPredicate:predicate inContext:context requestConfigureBlock:^(NSFetchRequest *_Nonnull fetchRequest) {
        fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES] ];
    }];
}

@end

NS_ASSUME_NONNULL_END
