//
//  DCNewsPostEntity+CoreDataProperties.m
//  
//
//  Created by Andrew Podkovyrin on 14/02/2018.
//
//

#import "DCNewsPostEntity+CoreDataProperties.h"

@implementation DCNewsPostEntity (CoreDataProperties)

+ (NSFetchRequest<DCNewsPostEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCNewsPostEntity"];
}

@dynamic title;
@dynamic url;
@dynamic imageURL;
@dynamic date;
@dynamic langCode;

@end
