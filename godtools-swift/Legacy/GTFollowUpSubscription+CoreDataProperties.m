//
//  GTFollowUpSubscription+CoreDataProperties.m
//  godtools-swift
//
//  Created by Ryan Carlson on 11/18/16.
//  Copyright © 2016 Cru. All rights reserved.
//

#import "GTFollowUpSubscription+CoreDataProperties.h"

@implementation GTFollowUpSubscription (CoreDataProperties)

+ (NSFetchRequest<GTFollowUpSubscription *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"GTFollowUpSubscription"];
}

@dynamic apiTransmissionSuccess;
@dynamic apiTransmissionTimestamp;
@dynamic contextId;
@dynamic emailAddress;
@dynamic followUpId;
@dynamic languageCode;
@dynamic name;
@dynamic recordedTimestamp;
@dynamic routeId;

@end
