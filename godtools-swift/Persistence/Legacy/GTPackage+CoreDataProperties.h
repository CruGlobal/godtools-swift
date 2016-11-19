//
//  GTPackage+CoreDataProperties.h
//  godtools-swift
//
//  Created by Ryan Carlson on 11/18/16.
//  Copyright © 2016 Cru. All rights reserved.
//

#import "GTPackage+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface GTPackage (CoreDataProperties)

+ (NSFetchRequest<GTPackage *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *code;
@property (nullable, nonatomic, copy) NSString *configFile;
@property (nullable, nonatomic, copy) NSString *icon;
@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, copy) NSNumber *latestMajorVersion;
@property (nullable, nonatomic, copy) NSNumber *latestMinorVersion;
@property (nullable, nonatomic, copy) NSString *latestSemanticVersion;
@property (nullable, nonatomic, copy) NSNumber *localMajorVersion;
@property (nullable, nonatomic, copy) NSNumber *localMinorVersion;
@property (nullable, nonatomic, copy) NSString *localSemanticVersion;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, retain) GTLanguage *language;

@end

NS_ASSUME_NONNULL_END
