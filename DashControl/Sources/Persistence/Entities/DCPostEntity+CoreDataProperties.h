//
//  DCPostEntity+CoreDataProperties.h
//  DashControl
//
//  Created by Manuel Boyer on 09/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCPostEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCPostEntity (CoreDataProperties)

+ (NSFetchRequest<DCPostEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSDate *pubDate;
@property (nullable, nonatomic, copy) NSString *link;
@property (nullable, nonatomic, copy) NSString *guid;
@property (nullable, nonatomic, copy) NSString *lang;
@property (nullable, nonatomic, copy) NSString *content;

@end

NS_ASSUME_NONNULL_END
