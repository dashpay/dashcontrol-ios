//
//  Comment+CoreDataProperties.m
//  DashControl
//
//  Created by Manuel Boyer on 27/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "Comment+CoreDataProperties.h"

@implementation Comment (CoreDataProperties)

+ (NSFetchRequest<Comment *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Comment"];
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
