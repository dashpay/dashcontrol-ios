//
//  ChartDataEntry+CoreDataProperties.m
//  DashControl
//
//  Created by Manuel Boyer on 23/08/2017.
//  Copyright © 2017 dashfoundation. All rights reserved.
//

#import "ChartDataEntry+CoreDataProperties.h"

@implementation ChartDataEntry (CoreDataProperties)

+ (NSFetchRequest<ChartDataEntry *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ChartDataEntry"];
}

@dynamic close;
@dynamic exchange;
@dynamic high;
@dynamic low;
@dynamic market;
@dynamic open;
@dynamic pairVolume;
@dynamic time;
@dynamic trades;
@dynamic volume;

@end
