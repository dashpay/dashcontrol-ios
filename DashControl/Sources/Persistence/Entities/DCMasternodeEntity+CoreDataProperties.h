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
//

#import "DCMasternodeEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCMasternodeEntity (CoreDataProperties)

+ (NSFetchRequest<DCMasternodeEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *address;
@property (nonatomic) int64_t amount;
@property (nullable, nonatomic, copy) NSString *secureVotingKeyPath;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSSet<DCMasternodePaymentEntity *> *payments;

@end

@interface DCMasternodeEntity (CoreDataGeneratedAccessors)

- (void)addPaymentsObject:(DCMasternodePaymentEntity *)value;
- (void)removePaymentsObject:(DCMasternodePaymentEntity *)value;
- (void)addPayments:(NSSet<DCMasternodePaymentEntity *> *)values;
- (void)removePayments:(NSSet<DCMasternodePaymentEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
