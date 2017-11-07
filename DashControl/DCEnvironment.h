//
//  DCEnvironment.h
//  DashControl
//
//  Created by Sam Westrich on 10/26/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCEnvironment : NSObject

@property (nonatomic,copy,readonly,nonnull) NSString * deviceId;
@property (nonatomic,copy,readonly,nonnull) NSString * devicePassword;


+ (id _Nonnull )sharedInstance;

-(void)setKeychainData:(NSData* _Nullable)data forKey:(NSString* _Nonnull)key authenticated:(BOOL)authenticated;

-(NSData* _Nullable)getKeychainDataForKey:(NSString* _Nonnull)key error:(NSError* _Nullable * _Nullable)error;

-(void)setHasRegistered;

-(BOOL)hasRegisteredWithError:(NSError**)error;

@end
