//
//  Post+CoreDataClass.m
//  DashControl
//
//  Created by Manuel Boyer on 09/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "Post+CoreDataClass.h"

@implementation Post

-(void)willSave {
    [self setUpCoreSpotlight];
}

-(void)setUpCoreSpotlight {
    CSSearchableItemAttributeSet * attributeSet = [[CSSearchableItemAttributeSet alloc]
                                                   initWithItemContentType:(NSString *)kUTTypeItem];
    
    attributeSet.displayName = self.title;
    attributeSet.title = self.title;
    attributeSet.contentDescription = self.link;
    attributeSet.keywords = [self.title componentsSeparatedByString:@" "];
    
    CSSearchableItem *item1 = [[CSSearchableItem alloc]
                               initWithUniqueIdentifier:[NSString stringWithFormat:@"%@/%@", @"post", self.guid]
                               domainIdentifier:kDCCSSearchDomainIdentifierFeed
                               attributeSet:attributeSet];
    
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item1]
                                                   completionHandler: ^(NSError * __nullable error) {
                                                       if (!error) {
                                                           //NSLog(@"Search item(s) journaled for indexing.");
                                                       }
                                                   }];

}

-(void)updateCoreSpotlightWithImage:(UIImage*)image {
    CSSearchableItemAttributeSet * attributeSet = [[CSSearchableItemAttributeSet alloc]
                                                   initWithItemContentType:(NSString *)kUTTypeItem];
    
    attributeSet.displayName = self.title;
    attributeSet.title = self.title;
    attributeSet.contentDescription = self.link;
    attributeSet.keywords = [self.title componentsSeparatedByString:@" "];

    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
    attributeSet.thumbnailData = imageData;
    
    CSSearchableItem *item1 = [[CSSearchableItem alloc]
                               initWithUniqueIdentifier:[NSString stringWithFormat:@"%@/%@", @"post", self.guid]
                               domainIdentifier:kDCCSSearchDomainIdentifierFeed
                               attributeSet:attributeSet];
    
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item1]
                                                   completionHandler: ^(NSError * __nullable error) {
                                                       if (!error) {
                                                           //NSLog(@"Search item(s) journaled for indexing.");
                                                       }
                                                   }];
}

@end
