//
//  DCCommentEntity+CoreDataProperties.h
//  DashControl
//
//  Created by Manuel Boyer on 27/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCCommentEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCCommentEntity (CoreDataProperties)

+ (NSFetchRequest<DCCommentEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *content;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *dateHuman;
@property (nullable, nonatomic, copy) NSString *idComment;
@property (nullable, nonatomic, copy) NSString *level;
@property (nonatomic) int32_t order;
@property (nonatomic) BOOL postedByOwner;
@property (nonatomic) BOOL recentlyPosted;
@property (nullable, nonatomic, copy) NSString *replyUrl;
@property (nullable, nonatomic, copy) NSString *username;
@property (nullable, nonatomic, copy) NSString *hashProposal;
@property (nullable, nonatomic, retain) Proposal *proposal;

@end

NS_ASSUME_NONNULL_END
