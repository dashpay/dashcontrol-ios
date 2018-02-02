//
//  DashControlTests.m
//  DashControlTests
//
//  Created by Sam Westrich on 11/16/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BRBIP32Sequence.h"
#import "BRKey+BIP38.h"
#import "BRKey.h"
#import "BRBIP39Mnemonic.h"
#import "DCWalletAccount.h"
#import "DCServerBloomFilter.h"
#import "NSString+Dash.h"

@interface DashControlTests : XCTestCase

@end

@implementation DashControlTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testServerBloomFilters {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    BRBIP39Mnemonic * mnemonic = [[BRBIP39Mnemonic alloc] init];
    NSString * seedPhrase = [mnemonic generateRandomSeed];
    BRBIP32Sequence * sequence = [[BRBIP32Sequence alloc] init];
    DCWalletAccount * walletAccount = [[DCWalletAccount alloc] initWithAccountPublicKey:[sequence extendedPublicKeyForAccount:0 fromSeed:[mnemonic deriveKeyFromPhrase:seedPhrase withPassphrase:nil] purpose:44] hash:nil inContext:nil];
    for (int i = 1;i<1000;i++) {
    NSArray * addresses = [walletAccount addressesWithGapLimit:i internal:FALSE withWalletAccountEntity:nil];
    DCServerBloomFilter * serverBloomFilter = [[DCServerBloomFilter alloc] initWithFalsePositiveRate:BLOOM_REDUCED_FALSEPOSITIVE_RATE forElementCount:[addresses count]];
    for (NSString * address in addresses) {
        NSData *hash = address.addressToHash160;
        [serverBloomFilter insertData:hash];
    }
        NSLog(@"element count : %lu - length : %lu - hash count : %d - fp rate : %.5f",(unsigned long)addresses.count,(unsigned long)serverBloomFilter.length,serverBloomFilter.hashFuncs,serverBloomFilter.falsePositiveRate);
    }
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
