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

@interface DCWalletAccount : NSObject

@property (nonatomic,assign) WalletAccountState state;
@property (nonatomic, readonly) NSSet * _Nonnull allReceivingAddresses;
@property (nonatomic, readonly) NSSet * _Nonnull allChangeAddresses;

-(id _Nonnull)initWithAccountPublicKey:(NSData* _Nonnull)accountPublicKey;

-(void)startUpInContext:(NSManagedObjectContext* _Nullable)context;

-(NSArray * _Nonnull)addressesWithGapLimit:(NSUInteger)gapLimit internal:(BOOL)internal inContext:(NSManagedObjectContext* _Nullable)context;

@end
