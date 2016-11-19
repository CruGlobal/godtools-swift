//
//  GTFollowUpSubscription+CoreDataProperties.h
//  godtools-swift
//
//  Created by Ryan Carlson on 11/18/16.
//  Copyright © 2016 Cru. All rights reserved.
//

#import "GTFollowUpSubscription+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface GTFollowUpSubscription (CoreDataProperties)

+ (NSFetchRequest<GTFollowUpSubscription *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *apiTransmissionSuccess;
@property (nullable, nonatomic, copy) NSDate *apiTransmissionTimestamp;
@property (nullable, nonatomic, copy) NSString *contextId;
@property (nullable, nonatomic, copy) NSString *emailAddress;
@property (nullable, nonatomic, copy) NSString *followUpId;
@property (nullable, nonatomic, copy) NSString *languageCode;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSDate *recordedTimestamp;
@property (nullable, nonatomic, copy) NSString *routeId;

@end

NS_ASSUME_NONNULL_END
