//
//  Post+CoreDataProperties.m
//  DashControl
//
//  Created by Manuel Boyer on 09/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "Post+CoreDataProperties.h"

@implementation Post (CoreDataProperties)

+ (NSFetchRequest<Post *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Post"];
}

@dynamic title;
@dynamic text;
@dynamic pubDate;
@dynamic link;
@dynamic guid;
@dynamic lang;
@dynamic content;

@end
