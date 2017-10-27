//
//  DCPostEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Manuel Boyer on 09/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCPostEntity+CoreDataProperties.h"

@implementation DCPostEntity (CoreDataProperties)

+ (NSFetchRequest<DCPostEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCPostEntity"];
}

@dynamic title;
@dynamic text;
@dynamic pubDate;
@dynamic link;
@dynamic guid;
@dynamic lang;
@dynamic content;

@end
