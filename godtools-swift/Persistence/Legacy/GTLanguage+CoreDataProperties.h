//
//  GTLanguage+CoreDataProperties.h
//  godtools-swift
//
//  Created by Ryan Carlson on 11/18/16.
//  Copyright © 2016 Cru. All rights reserved.
//

#import "GTLanguage+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface GTLanguage (CoreDataProperties)

+ (NSFetchRequest<GTLanguage *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *code;
@property (nullable, nonatomic, copy) NSNumber *downloaded;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, copy) NSNumber *updatesAvailable;
@property (nullable, nonatomic, retain) NSSet<GTPackage *> *packages;

@end

@interface GTLanguage (CoreDataGeneratedAccessors)

- (void)addPackagesObject:(GTPackage *)value;
- (void)removePackagesObject:(GTPackage *)value;
- (void)addPackages:(NSSet<GTPackage *> *)values;
- (void)removePackages:(NSSet<GTPackage *> *)values;

@end

NS_ASSUME_NONNULL_END
