//
//  DCWalletAccount.h
//  DashControl
//
//  Created by Sam Westrich on 10/24/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint32_t,WalletAccountState) {
    WalletAccountFailed = -1,
    WalletAccountStopped = 0,
    WalletAccountStarting = 1,
    WalletAccountActive = 2
};

@class DCWalletAccountEntity;
@class NSManagedObjectContext;

@interface DCWalletAccount : NSObject

@property (nonatomic,assign) WalletAccountState state;
@property (nonatomic, readonly) NSSet * _Nonnull allReceivingAddresses;
@property (nonatomic, readonly) NSSet * _Nonnull allChangeAddresses;

-(id _Nonnull)initWithAccountPublicKey:(NSData* _Nonnull)accountPublicKey hash:(NSString* _Nullable)hash inContext:(NSManagedObjectContext* _Nullable)context;

-(void)startUpWithWalletAccountEntity:(DCWalletAccountEntity* _Nonnull)walletAccountEntity;

-(NSArray * _Nonnull)addressesWithGapLimit:(NSUInteger)gapLimit internal:(BOOL)internal withWalletAccountEntity:(DCWalletAccountEntity* _Nullable)walletAccountEntity;

@end
