//
//  GTLanguage+CoreDataProperties.m
//  godtools-swift
//
//  Created by Ryan Carlson on 11/18/16.
//  Copyright © 2016 Cru. All rights reserved.
//

#import "GTLanguage+CoreDataProperties.h"

@implementation GTLanguage (CoreDataProperties)

+ (NSFetchRequest<GTLanguage *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"GTLanguage"];
}

@dynamic code;
@dynamic downloaded;
@dynamic name;
@dynamic status;
@dynamic updatesAvailable;
@dynamic packages;

@end
