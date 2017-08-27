//
//  Comment+CoreDataProperties.h
//  DashControl
//
//  Created by Manuel Boyer on 23/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "Comment+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Comment (CoreDataProperties)

+ (NSFetchRequest<Comment *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *idComment;
@property (nullable, nonatomic, copy) NSString *username;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *dateHuman;
@property (nonatomic) int32_t order;
@property (nullable, nonatomic, copy) NSString *level;
@property (nonatomic) BOOL recentlyPosted;
@property (nonatomic) BOOL postedByOwner;
@property (nullable, nonatomic, copy) NSString *replyUrl;
@property (nullable, nonatomic, copy) NSString *content;
@property (nullable, nonatomic, retain) Proposal *proposal;

@end

NS_ASSUME_NONNULL_END
