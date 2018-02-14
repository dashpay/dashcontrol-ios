//
//  DCCommentEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Manuel Boyer on 27/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCCommentEntity+CoreDataProperties.h"

@implementation DCCommentEntity (CoreDataProperties)

+ (NSFetchRequest<DCCommentEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCCommentEntity"];
}

@dynamic content;
@dynamic date;
@dynamic dateHuman;
@dynamic idComment;
@dynamic level;
@dynamic order;
@dynamic postedByOwner;
@dynamic recentlyPosted;
@dynamic replyUrl;
@dynamic username;
@dynamic hashProposal;
@dynamic proposal;

@end
