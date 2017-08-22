//
//  ChartDataEntry+CoreDataProperties.m
//  DashControl
//
//  Created by Manuel Boyer on 22/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ChartDataEntry+CoreDataProperties.h"

@implementation ChartDataEntry (CoreDataProperties)

+ (NSFetchRequest<ChartDataEntry *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ChartDataEntry"];
}

@dynamic open;
@dynamic high;
@dynamic close;
@dynamic low;
@dynamic exchange;
@dynamic market;
@dynamic pairVolume;
@dynamic time;
@dynamic trades;
@dynamic volume;

@end
