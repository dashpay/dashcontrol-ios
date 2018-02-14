//
//  DCNewsPostEntity+CoreDataProperties.h
//  
//
//  Created by Andrew Podkovyrin on 14/02/2018.
//
//

#import "DCNewsPostEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface DCNewsPostEntity (CoreDataProperties)

+ (NSFetchRequest<DCNewsPostEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *url;
@property (nullable, nonatomic, copy) NSString *imageURL;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *langCode;

@end

NS_ASSUME_NONNULL_END
