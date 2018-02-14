//
//  DCWalletEntity+CoreDataProperties.h
//  DashControl
//
//  Created by Sam Westrich on 10/27/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//
//

#import "DCWalletEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCWalletEntity (CoreDataProperties)

+ (NSFetchRequest<DCWalletEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *dateAdded;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, retain) NSSet<DCWalletAccountEntity *> *accounts;

@end

@interface DCWalletEntity (CoreDataGeneratedAccessors)

- (void)addAccountsObject:(DCWalletAccountEntity *)value;
- (void)removeAccountsObject:(DCWalletAccountEntity *)value;
- (void)addAccounts:(NSSet<DCWalletAccountEntity *> *)values;
- (void)removeAccounts:(NSSet<DCWalletAccountEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
