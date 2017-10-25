//
//  DCChartDataEntryEntity+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 9/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "DCChartDataEntryEntity+CoreDataProperties.h"

@implementation DCChartDataEntryEntity (CoreDataProperties)

+ (NSFetchRequest<DCChartDataEntryEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"DCChartDataEntryEntity"];
}

@dynamic close;
@dynamic exchangeIdentifier;
@dynamic high;
@dynamic low;
@dynamic marketIdentifier;
@dynamic open;
@dynamic pairVolume;
@dynamic time;
@dynamic trades;
@dynamic volume;
@dynamic exchange;
@dynamic market;
@dynamic interval;

@end
