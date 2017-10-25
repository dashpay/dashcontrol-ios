//
//  DCProposalEntity+CoreDataClass.m
//  DashControl
//
//  Created by Manuel Boyer on 23/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCProposalEntity+CoreDataClass.h"
#import "DCCommentEntity+CoreDataClass.h"

@implementation DCProposalEntity

-(void)willSave {
    [self setUpCoreSpotlight];
}

-(void)setUpCoreSpotlight {
    CSSearchableItemAttributeSet * attributeSet = [[CSSearchableItemAttributeSet alloc]
                                                   initWithItemContentType:(NSString *)kUTTypeItem];
    
    attributeSet.displayName = self.name;
    attributeSet.title = self.title;
    attributeSet.contentDescription = self.dwUrl;
    
    NSMutableArray *array = [NSMutableArray new];
    [array addObjectsFromArray:[self.title componentsSeparatedByString:@" "]];
    [array addObject:self.name];
    
    attributeSet.keywords = array;
    
    CSSearchableItem *item1 = [[CSSearchableItem alloc]
                               initWithUniqueIdentifier:[NSString stringWithFormat:@"%@/%@", @"proposal", self.hashProposal]
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
