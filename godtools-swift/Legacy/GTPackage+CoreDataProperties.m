//
//  GTPackage+CoreDataProperties.m
//  godtools-swift
//
//  Created by Ryan Carlson on 11/18/16.
//  Copyright © 2016 Cru. All rights reserved.
//

#import "GTPackage+CoreDataProperties.h"

@implementation GTPackage (CoreDataProperties)

+ (NSFetchRequest<GTPackage *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"GTPackage"];
}

@dynamic code;
@dynamic configFile;
@dynamic icon;
@dynamic identifier;
@dynamic latestMajorVersion;
@dynamic latestMinorVersion;
@dynamic latestSemanticVersion;
@dynamic localMajorVersion;
@dynamic localMinorVersion;
@dynamic localSemanticVersion;
@dynamic name;
@dynamic status;
@dynamic type;
@dynamic language;

@end
