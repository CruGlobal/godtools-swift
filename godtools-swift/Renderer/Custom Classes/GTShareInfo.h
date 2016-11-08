//
//  GTShareInfo.h
//  GTViewController
//
//  Created by Michael Harrison on 8/28/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GTShareInfo : NSObject <UIActivityItemSource>

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong, readonly) NSURL *shareURL;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, strong) NSString *packageName;
@property (nonatomic, assign) BOOL addPackageInfo;
@property (nonatomic, assign) BOOL addCampaignInfo;

- (instancetype)initWithBaseURL:(NSURL *)baseURL packageCode:(NSString *)packageCode languageCode:(NSString *)languageCode;
- (void)setPackageCode:(NSString *)packageCode languageCode:(NSString *)languageCode pageNumber:(NSNumber *)pageNumber;
- (void)setGoogleAnalyticsCampaign:(NSString *)campaign source:(NSString *)source medium:(NSString *)medium;

@end
