//
//  NSArray+Additions.m
//
//  Created by Samuel Westrich on 3/7/12.
//  Copyright (c) 2017 Samuel Westrich. All rights reserved.
//

#import "NSArray+SWAdditions.h"

#import <CoreData/CoreData.h>

@implementation NSArray (SWAdditions)


- (NSMutableDictionary *)mutableDictionaryOfMutableArraysReferencedByKeyPath:(NSString*)key {
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    for (NSManagedObject * object in self) {
        if ([object valueForKey:key]) {
            id lKey = [[object valueForKey:key] copy];
            NSMutableArray * arrayOfPreviousObjects = [mutableDictionary objectForKey:lKey];
            if (arrayOfPreviousObjects) {
                [arrayOfPreviousObjects addObject:object];
            } else {
                [mutableDictionary setObject:[NSMutableArray arrayWithObject:object] forKey:lKey];
            }
        }
    }
    return mutableDictionary;
}

- (NSDictionary *)dictionaryReferencedByKeyPath:(NSString*)key {
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    for (NSManagedObject * object in self) {
        if ([object valueForKey:key]) {
            id lKey = [[object valueForKey:key] copy];
            [mutableDictionary setObject:object forKey:lKey];
        }
    }
    NSDictionary * rDictionary = [NSDictionary dictionaryWithDictionary:mutableDictionary];
    return rDictionary;
    
}

- (NSDictionary *)dictionaryReferencedByKeyPath:(NSString*)key objectPath:(NSString*)objectPath {
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    NSString * realObjectPath = objectPath;
    NSString * operator = nil;
    if ([objectPath hasPrefix:@"@"] && [objectPath containsString:@"."]) {
        NSArray * components = [objectPath componentsSeparatedByString:@"."];
        realObjectPath = [components objectAtIndex:1];
        operator = [components objectAtIndex:0];
        operator = [operator stringByAppendingString:@".self"];
    }
    for (NSManagedObject * object in self) {
        if ([object valueForKey:key]) {
            id lKey = [[object valueForKey:key] copy];
            id valueToInsert = [object valueForKey:realObjectPath];
            if ([mutableDictionary objectForKey:lKey]) {
                [[mutableDictionary objectForKey:lKey] addObject:valueToInsert];
            } else {
                [mutableDictionary setObject:[[NSMutableArray alloc] initWithObjects:valueToInsert, nil] forKey:lKey];
            }
        }
    }
    if (operator) {
        for (NSString * lKey in [mutableDictionary allKeys]) {
            [mutableDictionary setObject:[[mutableDictionary objectForKey:lKey] valueForKeyPath:operator] forKey:lKey];
        }
    } else {
        for (NSString * lKey in [mutableDictionary allKeys]) {
            [mutableDictionary setObject:[[mutableDictionary objectForKey:lKey] copy] forKey:lKey];
        }
    }
    NSDictionary * rDictionary = [NSDictionary dictionaryWithDictionary:mutableDictionary];
    return rDictionary;
}

- (NSMutableDictionary *)mutableDictionaryReferencedByKeyPath:(NSString*)key objectPathMakeMutable:(NSString*)objectPath {
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    NSString * realObjectPath = objectPath;
    NSString * operator = nil;
    if ([objectPath hasPrefix:@"@"] && [objectPath containsString:@"."]) {
        NSArray * components = [objectPath componentsSeparatedByString:@"."];
        realObjectPath = [components objectAtIndex:1];
        operator = [components objectAtIndex:0];
        operator = [operator stringByAppendingString:@".self"];
    }
    for (NSManagedObject * object in self) {
        if ([object valueForKey:key]) {
            id lKey = [[object valueForKey:key] copy];
            id valueToInsert = [object valueForKey:realObjectPath];
            if ([mutableDictionary objectForKey:lKey]) {
                [[mutableDictionary objectForKey:lKey] addObject:valueToInsert];
            } else {
                [mutableDictionary setObject:[[NSMutableArray alloc] initWithObjects:valueToInsert, nil] forKey:lKey];
            }
        }
    }
    if (operator) {
        for (NSString * lKey in [mutableDictionary allKeys]) {
            [mutableDictionary setObject:[[[mutableDictionary objectForKey:lKey] valueForKeyPath:operator] mutableCopy] forKey:lKey];
        }
    }
    return mutableDictionary;
}

- (NSDictionary *)dictionaryReferencedByKeyPath:(NSString*)key objectPaths:(NSArray*)objectPaths {
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    for (NSManagedObject * object in self) {
        if ([object valueForKey:key]) {
            id lKey = [[object valueForKey:key] copy];
            NSMutableArray * mArray = [NSMutableArray array];
            for (NSString * keyValues in objectPaths) {
                [mArray addObject:[object valueForKey:keyValues]];
            }
            [mutableDictionary setObject:mArray forKey:lKey];
        }
    }
    NSDictionary * rDictionary = [NSDictionary dictionaryWithDictionary:mutableDictionary];
    return rDictionary;
}


- (NSMutableDictionary *)mutableDictionaryReferencedByKeyPath:(NSString*)key {
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    for (NSManagedObject * object in self) {
        if ([object valueForKey:key]) {
            id lKey = [[object valueForKey:key] copy];
            [mutableDictionary setObject:object forKey:lKey];
        }
    }
    return mutableDictionary;
    
}

- (NSArray *)arrayReferencedByKeyPath:(NSString*)key {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (NSObject * object in self) {
        if ([object valueForKey:key]) {
            id lObject = [object valueForKey:key];
            if ([lObject respondsToSelector:@selector(copyWithZone:)]) {
                lObject = [lObject copy];
            }
            [mutableArray addObject:lObject];
        }
    }
    NSArray * array = [NSArray arrayWithArray:mutableArray];
    return array;
}


- (NSArray *)arrayOfArraysReferencedByKeyPaths:(NSArray*)keyPaths requiredKeyPaths:(NSArray*)requiredKeyPaths {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (NSObject * object in self) {
        NSMutableArray *subMutableArray = [NSMutableArray array];
        NSMutableArray *keysUsedArray = [NSMutableArray array];
        for (NSString * key in keyPaths) {
            if ([object valueForKey:key]) {
                id lObject = [[object valueForKey:key] copy];
                [subMutableArray addObject:lObject];
                [keysUsedArray addObject:key];
            }
        }
        if ([subMutableArray count]) {
            BOOL requirementsSatisfied = TRUE;
            for (NSString * key in requiredKeyPaths) {
                if (![keysUsedArray containsObject:key])
                    requirementsSatisfied = FALSE;
            }
            if (requirementsSatisfied) {
                [mutableArray addObject:subMutableArray];
            }
        }
    }
    NSArray * array = [NSArray arrayWithArray:mutableArray];
    return array;
}

- (NSArray *)arrayOfDictionariesReferencedByKeyPaths:(NSArray*)keyPaths {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (NSObject * object in self) {
        NSMutableDictionary *subMutableDictionary = [NSMutableDictionary dictionary];
        for (id keyAttr in keyPaths) {
            NSString * key;
            id comparingObject;
            if ([keyAttr isKindOfClass:[NSString class]] || [keyAttr isKindOfClass:[NSNumber class]]) {
                key = keyAttr;
                comparingObject = [object valueForKey:key];
            } else if ([keyAttr isKindOfClass:[NSArray class]]) {
                key = [keyAttr objectAtIndex:0];
                comparingObject = [object valueForKey:key];
            } else {
                key = keyAttr;
                comparingObject = [object valueForKey:key];
            }
            if (comparingObject) {
                id lObject;
                if ([comparingObject isKindOfClass:[NSString class]] || [comparingObject isKindOfClass:[NSNumber class]]) {
                    lObject = [comparingObject copy];
                } else if ([comparingObject isKindOfClass:[NSDate class]]) {
                    lObject = [comparingObject copy];
                } else if ([comparingObject isKindOfClass:[NSManagedObject class]]) {
                    lObject = [comparingObject valueForKey:[keyAttr objectAtIndex:1]];
                } else {
                    lObject = comparingObject;
                }
                
                [subMutableDictionary setObject:lObject forKey:key];
                
            }
        }
        [mutableArray addObject:subMutableDictionary];
    }
    NSArray * array = [NSArray arrayWithArray:mutableArray];
    return array;
}

-(NSArray *)arrayByRemovingObjectsFromArray:(NSArray*)arrayOfElementsToRemove {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (NSObject * object in self) {
        if (![arrayOfElementsToRemove containsObject:object]) {
            [mutableArray addObject:object];
        }
    }
    NSArray * array = [NSArray arrayWithArray:mutableArray];
    return array;
}

- (NSArray *)arrayByCrushingSubArrays {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (NSArray * subArray in self) {
        if ([subArray isKindOfClass:[NSArray class]] && [subArray count]) {
            [mutableArray addObjectsFromArray:subArray];
        }
    }
    NSArray * array = [NSArray arrayWithArray:mutableArray];
    return array;
}

- (NSArray *)arrayByCrushingSubSets {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (NSSet * subArray in self) {
        if ([subArray isKindOfClass:[NSSet class]] && [subArray count]) {
            [mutableArray addObjectsFromArray:[subArray allObjects]];
        }
    }
    NSArray * array = [NSArray arrayWithArray:mutableArray];
    return array;
}

- (NSMutableArray *)mutableArrayReferencedByKeyPath:(NSString*)key {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (NSObject * object in self) {
        if ([object valueForKey:key]) {
            id lObject = [[object valueForKey:key] copy];
            [mutableArray addObject:lObject];
        }
    }
    return mutableArray;
}

- (NSInteger)indexForInsertionOfObject:(id)object keyPathAndOrderOfKeyPathArrays:(NSArray*)keyPathAndOrderOfKeyPathArrays {
    NSMutableArray * mArray = [[NSMutableArray alloc] initWithArray:self];
    [mArray addObject:object];
    NSMutableArray * sortDescriptors = [[NSMutableArray alloc] init];
    for (NSArray * keyPathAndOrderOfKeyPathArray in keyPathAndOrderOfKeyPathArrays) {
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:[keyPathAndOrderOfKeyPathArray objectAtIndex:0] ascending:[[keyPathAndOrderOfKeyPathArray objectAtIndex:1] boolValue]];
        [sortDescriptors addObject:descriptor];
    }
    [mArray sortUsingDescriptors:sortDescriptors];
    NSInteger objectIndex = [mArray indexOfObject:object];
    return objectIndex;
    
}

- (BOOL)isSortedOnKeyPath:(NSString*)key {
    for (int i = 0; i < [self count] - 1; i++)
    {
        if ([[[self objectAtIndex:i] valueForKey:key] compare:[[self objectAtIndex:i + 1] valueForKey:key]] != NSOrderedDescending)
        {
            return FALSE;
        }
    }
    return TRUE;
}

-(NSString *)stringByJoiningOnProperty:(NSString *)property separator:(NSString *)separator
{
    NSMutableString *res = [NSMutableString string];
    BOOL firstTime = YES;
    for (NSObject *obj in self)
    {
        if (!firstTime) {
            [res appendString:separator];
        }
        else{
            firstTime = NO;
        }
        id val = [obj valueForKey:property];
        if ([val isKindOfClass:[NSString class]])
        {
            [res appendString:val];
        }
        else
        {
            [res appendString:[val stringValue]];
        }
    }
    return [NSString stringWithString:res];
}

-(NSString *)stringByJoiningOnObject:(NSString *)objectString subProperty:(NSString*)subProperty separator:(NSString *)separator
{
    NSMutableString *res = [NSMutableString string];
    BOOL firstTime = YES;
    for (NSObject *obj in self)
    {
        id object = [obj valueForKey:objectString];
        id val = [object valueForKey:subProperty];
        if (val) {
            if (!firstTime) {
                [res appendString:separator];
            }
            else{
                firstTime = NO;
            }
            
            if ([val isKindOfClass:[NSString class]])
            {
                [res appendString:val];
            }
            else
            {
                [res appendString:[val stringValue]];
            }
        }
    }
    return [NSString stringWithString:res];
}


@end
