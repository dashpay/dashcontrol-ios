//
//  ChartDataEntry+CoreDataProperties.m
//  DashControl
//
//  Created by Sam Westrich on 9/4/17.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ChartDataEntry+CoreDataProperties.h"

@implementation ChartDataEntry (CoreDataProperties)

+ (NSFetchRequest<ChartDataEntry *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ChartDataEntry"];
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

@end
