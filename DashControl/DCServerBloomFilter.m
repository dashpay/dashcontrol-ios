//
//  DCServerBloomFilter.m
//  DashControl
//
//  Heavily inspired by Aaron Voisine.
//  Copyright (c) 2017 Quantum Explorer <quantum@dash.org>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "DCServerBloomFilter.h"
#import "NSMutableData+Dash.h"
#import "NSData+Dash.h"

#define BLOOM_MAX_HASH_FUNCS 50

#define C1 0xcc9e2d51
#define C2 0x1b873593

// bitwise left rotation
#define rol32(a, b) (((a) << (b)) | ((a) >> (32 - (b))))

#define fmix32(h) (h ^= h >> 16, h *= 0x85ebca6b, h ^= h >> 13, h *= 0xc2b2ae35, h ^= h >> 16)

// murmurHash3 (x86_32): https://code.google.com/p/smhasher/
static uint32_t murmur3_32(const void *data, size_t len, uint32_t seed)
{
    uint32_t h = seed, k = 0;
    size_t i, count = len/4;
    
    for (i = 0; i < count; i++) {
        k = CFSwapInt32LittleToHost(((uint32_t *)data)[i])*C1;
        k = rol32(k, 15)*C2;
        h ^= k;
        h = rol32(h, 13)*5 + 0xe6546b64;
    }
    
    k = 0;
    
    switch (len & 3) {
        case 3: k ^= ((uint8_t *)data)[i*4 + 2] << 16; // fall through
        case 2: k ^= ((uint8_t *)data)[i*4 + 1] << 8; // fall through
        case 1: k ^= ((uint8_t *)data)[i*4], k *= C1, h ^= rol32(k, 15)*C2;
    }
    
    h ^= len;
    fmix32(h);
    return h;
}

// bloom filters are explained in BIP37: https://github.com/bitcoin/bips/blob/master/bip-0037.mediawiki
@interface DCServerBloomFilter ()

@property (nonatomic, strong) NSMutableData *filter;
@property (nonatomic, assign) uint32_t hashFuncs;

@end

@implementation DCServerBloomFilter

- (instancetype)initWithFalsePositiveRate:(double)fpRate forElementCount:(NSUInteger)count flags:(uint8_t)flags
{
    if (! (self = [self init])) return nil;

    NSUInteger length = (fpRate < DBL_EPSILON) ? BLOOM_MAX_FILTER_LENGTH : (-1.0/(M_LN2*M_LN2))*count*log(fpRate)/8.0;

    if (length > BLOOM_MAX_FILTER_LENGTH) length = BLOOM_MAX_FILTER_LENGTH;
    self.filter = [NSMutableData dataWithLength:(length < 1) ? 1 : length];
    self.hashFuncs = ((self.filter.length*8.0)/count)*M_LN2;
    if (self.hashFuncs > BLOOM_MAX_HASH_FUNCS) self.hashFuncs = BLOOM_MAX_HASH_FUNCS;
    _flags = flags;
    return self;
}

- (uint32_t)hash:(NSData *)data hashNum:(uint32_t)hashNum
{
    return murmur3_32(data.bytes, data.length, hashNum*0xfba4c795) % (self.filter.length*8);
}

- (BOOL)containsData:(NSData *)data
{
    const uint8_t *b = self.filter.bytes;
    
    for (uint32_t i = 0; i < self.hashFuncs; i++) {
        uint32_t idx = [self hash:data hashNum:i];
        
        if (! (b[idx >> 3] & (1 << (7 & idx)))) return NO;
    }

    return YES;
}

- (void)insertData:(NSData *)data
{
    uint8_t *b = self.filter.mutableBytes;

    for (uint32_t i = 0; i < self.hashFuncs; i++) {
        uint32_t idx = [self hash:data hashNum:i];

        b[idx >> 3] |= (1 << (7 & idx));
    }

    _elementCount++;
}

- (double)falsePositiveRate
{
    return pow(1 - pow(M_E, -1.0*self.hashFuncs*self.elementCount/(self.filter.length*8.0)), self.hashFuncs);
}

- (NSData *)toData
{
    NSMutableData *d = [NSMutableData data];
    
    [d appendVarInt:self.length];
    [d appendData:self.filter];
    [d appendUInt32:self.hashFuncs];
    [d appendUInt8:self.flags];
    return d;
}

- (NSUInteger)length
{
    return self.filter.length;
}

@end
