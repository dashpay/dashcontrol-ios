//
//  DCPostEntity+CoreDataClass.h
//  DashControl
//
//  Created by Manuel Boyer on 09/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCPostEntity : NSManagedObject
-(void)updateCoreSpotlightWithImage:(UIImage*)image;
@end

NS_ASSUME_NONNULL_END

#import "DCPostEntity+CoreDataProperties.h"
