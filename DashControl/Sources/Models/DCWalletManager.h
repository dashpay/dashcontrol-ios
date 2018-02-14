//
//  DCWalletManager.h
//  DashControl
//
//  Created by Sam Westrich on 10/23/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DCWalletManager : NSObject

+ (id _Nonnull )sharedInstance;

-(void)importWalletMasterAddressFromSource:(NSString* _Nonnull)source withExtended32PublicKey:(NSString* _Nullable)extended32PublicKey extended44PublicKey:(NSString* _Nullable)extended44PublicKey completion:(void (^ _Nullable)(BOOL success))completion;

- (void)updateBloomFilter;

@end
