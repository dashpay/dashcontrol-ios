//
//  DCServerBloomFilter.h
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

#import <Foundation/Foundation.h>
#import <DashSync/DashSync.h>

#define BLOOM_DEFAULT_FALSEPOSITIVE_RATE 0.0005 // same as bitcoinj, use 0.00005 for less data, 0.001 for good anonymity
#define BLOOM_REDUCED_FALSEPOSITIVE_RATE 0.05
#define BLOOM_MAX_FILTER_LENGTH          50000 // this allows for 10,000 elements with a <0.0001% false positive rate
#define BLOOM_FILTER_MAGIC 0xfba4c795

@interface DCServerBloomFilter : NSObject

@property (nonatomic, readonly) uint8_t flags;
@property (nonatomic, readonly, strong) NSMutableData *filterData;
@property (nonatomic, readonly) NSUInteger elementCount;
@property (nonatomic, assign, readonly) UInt160 filterHash;
@property (nonatomic, readonly) double falsePositiveRate;
@property (nonatomic, readonly) NSUInteger length;
@property (nonatomic, assign,readonly) uint32_t hashFuncs;

- (instancetype)initWithFalsePositiveRate:(double)fpRate forElementCount:(NSUInteger)count;
- (BOOL)containsData:(NSData *)data;
- (void)insertData:(NSData *)data;

@end
