//
//  NSData+Dash.h
//  BreadWallet
//
//  Created by Sam Westrich on 1/31/17.
//  Copyright © 2017 Dash Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IntTypes.h"

#define RMD160_DIGEST_LENGTH (160/8)
#define MD5_DIGEST_LENGTH    (128/8)

#define VAR_INT16_HEADER 0xfd
#define VAR_INT32_HEADER 0xfe
#define VAR_INT64_HEADER 0xff

// dash script opcodes: https://en.bitcoin.it/wiki/Script#Constants
#define OP_PUSHDATA1   0x4c
#define OP_PUSHDATA2   0x4d
#define OP_PUSHDATA4   0x4e
#define OP_DUP         0x76
#define OP_EQUAL       0x87
#define OP_EQUALVERIFY 0x88
#define OP_HASH160     0xa9
#define OP_CHECKSIG    0xac
#define OP_RETURN      0x6a

#define OP_SHAPESHIFT  0xb1 //not a dash op code, used to identify shapeshift when placed after OP_RETURN

void SHA1(void *_Nonnull md, const void *_Nonnull data, size_t len);
void SHA256(void *_Nonnull md, const void *_Nonnull data, size_t len);
void SHA512(void *_Nonnull md, const void *_Nonnull data, size_t len);
void RMD160(void *_Nonnull md, const void *_Nonnull data, size_t len);
void MD5(void *_Nonnull md, const void *_Nonnull data, size_t len);
void HMAC(void *_Nonnull md, void (*_Nonnull hash)(void *_Nonnull , const void *_Nonnull , size_t), size_t hlen,
          const void *_Nonnull key, size_t klen, const void *_Nonnull data, size_t dlen);
void PBKDF2(void *_Nonnull dk, size_t dklen, void (*_Nonnull hash)(void *_Nonnull , const void *_Nonnull , size_t),
            size_t hlen, const void *_Nonnull pw, size_t pwlen, const void *_Nonnull salt, size_t slen,
            unsigned rounds);

// poly1305 authenticator: https://tools.ietf.org/html/rfc7539
// must use constant time mem comparison when verifying mac to defend against timing attacks
void poly1305(void *_Nonnull mac16, const void *_Nonnull key32, const void *_Nonnull data, size_t len);

// chacha20 stream cypher: https://cr.yp.to/chacha.html
void chacha20(void *_Nonnull out, const void *_Nonnull key32, const void *_Nonnull iv8, const void *_Nonnull data,
              size_t len, uint64_t counter);

// chacha20-poly1305 authenticated encryption with associated data (AEAD): https://tools.ietf.org/html/rfc7539
size_t chacha20Poly1305AEADEncrypt(void *_Nullable out, size_t outLen, const void *_Nonnull key32,
                                   const void *_Nonnull nonce12, const void *_Nonnull data, size_t dataLen,
                                   const void *_Nonnull ad, size_t adLen);

size_t chacha20Poly1305AEADDecrypt(void *_Nullable out, size_t outLen, const void *_Nonnull key32,
                                   const void *_Nonnull nonce12, const void *_Nonnull data, size_t dataLen,
                                   const void *_Nonnull ad, size_t adLen);

@interface NSData (Dash)

-(UInt256)x11;
-(UInt512)blake512;
-(UInt512)bmw512;
-(UInt512)groestl512;
-(UInt512)skein512;
-(UInt512)jh512;
-(UInt512)keccak512;
-(UInt512)luffa512;
-(UInt512)cubehash512;
-(UInt512)shavite512;
-(UInt512)simd512;
-(UInt512)echo512;

+ (NSData *)dataFromHexString:(NSString *)string;

+ (nonnull instancetype)dataWithUInt256:(UInt256)n;
+ (nonnull instancetype)dataWithUInt160:(UInt160)n;
+ (nonnull instancetype)dataWithUInt128:(UInt128)n;
+ (nonnull instancetype)dataWithBase58String:(NSString *_Nonnull)b58str;

- (UInt160)SHA1;
- (UInt256)SHA256;
- (UInt256)SHA256_2;
- (UInt512)SHA512;
- (UInt160)RMD160;
- (UInt160)hash160;
- (NSString*)hash160String;
- (UInt128)MD5;
- (NSData * _Nonnull)reverse;

- (uint8_t)UInt8AtOffset:(NSUInteger)offset;
- (uint16_t)UInt16AtOffset:(NSUInteger)offset;
- (uint32_t)UInt32AtOffset:(NSUInteger)offset;
- (uint64_t)UInt64AtOffset:(NSUInteger)offset;
- (uint64_t)varIntAtOffset:(NSUInteger)offset length:(NSNumber * _Nonnull * _Nullable)length;
- (UInt256)hashAtOffset:(NSUInteger)offset;
- (NSString *_Nullable)stringAtOffset:(NSUInteger)offset length:(NSNumber * _Nonnull * _Nullable)length;
- (NSData *_Nonnull)dataAtOffset:(NSUInteger)offset length:(NSNumber * _Nonnull * _Nullable)length;

- (NSArray *_Nonnull)scriptElements; // an array of NSNumber and NSData objects representing each script element
- (int)intValue; // returns the opcode used to store the receiver in a script (i.e. OP_PUSHDATA1)

- (NSString *_Nonnull)base58String;

@end


@interface NSValue (Utils)

+ (nonnull instancetype)valueWithUInt256:(UInt256)uint;

@end
