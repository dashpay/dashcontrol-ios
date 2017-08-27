//
//  Comment+CoreDataProperties.m
//  DashControl
//
//  Created by Manuel Boyer on 23/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "Comment+CoreDataProperties.h"

@implementation Comment (CoreDataProperties)

+ (NSFetchRequest<Comment *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Comment"];
}

@dynamic idComment;
@dynamic username;
@dynamic date;
@dynamic dateHuman;
@dynamic order;
@dynamic level;
@dynamic recentlyPosted;
@dynamic postedByOwner;
@dynamic replyUrl;
@dynamic content;
@dynamic proposal;

@end
