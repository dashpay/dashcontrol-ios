//
//  DCEnvironment.m
//  DashControl
//
//  Created by Sam Westrich on 10/26/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCEnvironment.h"
#import "NSData+Dash.h"
#import "NSString+Sugar.h"
#import "NSMutableData+Dash.h"
#import <LocalAuthentication/LocalAuthentication.h>

#define SEC_ATTR_SERVICE      @"org.dashfoundation.dash.Control"
#define DEVICE_ID @"DEVICE_ID"
#define DEVICE_PASSWORD @"DEVICE_PASSWORD"
#define DEVICE_HAS_REGISTERED @"DEVICE_REGISTERED"

static BOOL setKeychainData(NSData *data, NSString *key, BOOL authenticated)
{
    if (! key) return NO;
    
    id accessible = (authenticated) ? (__bridge id)kSecAttrAccessibleWhenUnlocked:(__bridge id)kSecAttrAccessibleAfterFirstUnlock;
    NSDictionary *query = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService:SEC_ATTR_SERVICE,
                            (__bridge id)kSecAttrAccount:key};
    
    if (SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL) == errSecItemNotFound) {
        if (! data) return YES;
        
        NSDictionary *item = @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                               (__bridge id)kSecAttrService:SEC_ATTR_SERVICE,
                               (__bridge id)kSecAttrAccount:key,
                               (__bridge id)kSecAttrAccessible:accessible,
                               (__bridge id)kSecValueData:data};
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)item, NULL);
        
        if (status == noErr) return YES;
        NSLog(@"SecItemAdd error: %@",
              [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil].localizedDescription);
        return NO;
    }
    
    if (! data) {
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
        
        if (status == noErr) return YES;
        NSLog(@"SecItemDelete error: %@",
              [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil].localizedDescription);
        return NO;
    }
    
    NSDictionary *update = @{(__bridge id)kSecAttrAccessible:accessible,
                             (__bridge id)kSecValueData:data};
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);
    
    if (status == noErr) return YES;
    NSLog(@"SecItemUpdate error: %@",
          [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil].localizedDescription);
    return NO;
}

static NSData *getKeychainData(NSString *key, NSError **error)
{
    NSDictionary *query = @{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService:SEC_ATTR_SERVICE,
                            (__bridge id)kSecAttrAccount:key,
                            (__bridge id)kSecReturnData:@YES};
    CFDataRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    
    if (status == errSecItemNotFound) return nil;
    if (status == noErr) return CFBridgingRelease(result);
    NSLog(@"SecItemCopyMatching error: %@",
          [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil].localizedDescription);
    if (error) *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    return nil;
}

static BOOL setKeychainInt(int64_t i, NSString *key, BOOL authenticated)
{
    @autoreleasepool {
        NSMutableData *d = [NSMutableData secureDataWithLength:sizeof(int64_t)];
        
        *(int64_t *)d.mutableBytes = i;
        return setKeychainData(d, key, authenticated);
    }
}

static int64_t getKeychainInt(NSString *key, NSError **error)
{
    @autoreleasepool {
        NSData *d = getKeychainData(key, error);
        
        return (d.length == sizeof(int64_t)) ? *(int64_t *)d.bytes : 0;
    }
}

static BOOL setKeychainBool(Boolean i, NSString *key, BOOL authenticated)
{
    @autoreleasepool {
        NSMutableData *d = [NSMutableData secureDataWithLength:sizeof(Boolean)];
        
        *(Boolean *)d.mutableBytes = i;
        return setKeychainData(d, key, authenticated);
    }
}

static Boolean getKeychainBool(NSString *key, NSError **error)
{
    @autoreleasepool {
        NSData *d = getKeychainData(key, error);
        
        return (d.length == sizeof(Boolean)) ? *(Boolean *)d.bytes : 0;
    }
}

static BOOL setKeychainString(NSString *s, NSString *key, BOOL authenticated)
{
    @autoreleasepool {
        NSData *d = (s) ? CFBridgingRelease(CFStringCreateExternalRepresentation(SecureAllocator(), (CFStringRef)s,
                                                                                 kCFStringEncodingUTF8, 0)) : nil;
        
        return setKeychainData(d, key, authenticated);
    }
}

static NSString *getKeychainString(NSString *key, NSError **error)
{
    @autoreleasepool {
        NSData *d = getKeychainData(key, error);
        
        return (d) ? CFBridgingRelease(CFStringCreateFromExternalRepresentation(SecureAllocator(), (CFDataRef)d,
                                                                                kCFStringEncodingUTF8)) : nil;
    }
}

static BOOL setKeychainDict(NSDictionary *dict, NSString *key, BOOL authenticated)
{
    @autoreleasepool {
        NSData *d = (dict) ? [NSKeyedArchiver archivedDataWithRootObject:dict] : nil;
        
        return setKeychainData(d, key, authenticated);
    }
}

static NSDictionary *getKeychainDict(NSString *key, NSError **error)
{
    @autoreleasepool {
        NSData *d = getKeychainData(key, error);
        
        return (d) ? [NSKeyedUnarchiver unarchiveObjectWithData:d] : nil;
    }
}

@interface DCEnvironment()

@property (nonatomic,copy) NSString * deviceId;
@property (nonatomic,copy) NSString * devicePassword;

@end

@implementation DCEnvironment

+ (id)sharedInstance {
    static DCEnvironment *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        [self deviceId];
        [self devicePassword];
    }
    return self;
}

-(void)setKeychainData:(NSData*)data forKey:(NSString*)key authenticated:(BOOL)authenticated {
    setKeychainData(data, key, authenticated);
}

-(NSData*)getKeychainDataForKey:(NSString*)key error:(NSError**)error {
    return getKeychainData(key, error);
}

-(void)setKeychainBoolean:(Boolean)value forKey:(NSString*)key authenticated:(BOOL)authenticated {
    setKeychainBool(value, key, authenticated);
}

-(Boolean)getKeychainBooleanForKey:(NSString*)key error:(NSError**)error {
    return getKeychainBool(key, error);
}


-(NSString*)deviceId {
    if (!_deviceId) {
        NSError * error = nil;
        self.deviceId = getKeychainString(DEVICE_ID, &error);
        if (!_deviceId && !error) {
            NSString * UUIDString = [[NSUUID UUID] UUIDString];
            setKeychainString(UUIDString, DEVICE_ID, NO);
            self.deviceId = UUIDString;
        }
    }
    return _deviceId;
}

-(NSString*)devicePassword {
    if (!_devicePassword) {
        NSError * error = nil;
        self.devicePassword = getKeychainString(DEVICE_PASSWORD, &error);
        if (!_devicePassword && !error) {
            NSString * password = [NSString randomStringWithLength:12];
            setKeychainString(password, DEVICE_PASSWORD, NO);
            _devicePassword = password;
        }
    }
    return _devicePassword;
}

-(void)setHasRegistered {
    [self setKeychainBoolean:TRUE forKey:DEVICE_HAS_REGISTERED authenticated:NO];
}

-(BOOL)hasRegisteredWithError:(NSError**)error {
    return [self getKeychainBooleanForKey:DEVICE_HAS_REGISTERED error:error];
}

@end
