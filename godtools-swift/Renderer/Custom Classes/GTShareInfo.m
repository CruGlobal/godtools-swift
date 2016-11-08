//
//  GTShareInfo.m
//  GTViewController
//
//  Created by Michael Harrison on 8/28/15.
//  Copyright (c) 2015 Michael Harrison. All rights reserved.
//

#import "GTShareInfo.h"
#import <UIKit/UIKit.h>

@interface GTShareInfo ()

@property (nonatomic, strong) NSString *languageCode;
@property (nonatomic, strong) NSString *packageCode;
@property (nonatomic, strong) NSNumber *pageNumber;

@property (nonatomic, strong) NSString *campaign;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *medium;

@end

@implementation GTShareInfo

@synthesize shareURL = _shareURL;

- (instancetype)initWithBaseURL:(NSURL *)baseURL packageCode:(NSString *)packageCode languageCode:(NSString *)languageCode {
	
	self = [super init];
	if (self) {
	
		self.baseURL = baseURL;
		self.addCampaignInfo = NO;
		self.addPackageInfo = YES;
		[self setPackageCode:packageCode languageCode:languageCode pageNumber:@0];
		
	}
	
	return self;
}

- (void)setPackageCode:(NSString *)packageCode languageCode:(NSString *)languageCode pageNumber:(NSNumber *)pageNumber {
	
	self.packageCode = packageCode;
	self.languageCode = languageCode;
	self.pageNumber = pageNumber;
	
}

- (void)setGoogleAnalyticsCampaign:(NSString *)campaign source:(NSString *)source medium:(NSString *)medium {
	
	self.campaign = campaign;
	self.source = source;
	self.medium = medium;
	
}

- (NSURL *)shareURL {
	
	BOOL addPackageInfo = self.addPackageInfo &&
						(
						 ( self.languageCode ) ||
						 ( self.languageCode && self.packageCode ) ||
						 ( self.languageCode && self.packageCode && self.pageNumber)
						);
	BOOL addCampaignInfo = self.addCampaignInfo && self.campaign && self.source && self.medium;
	
	if (self.baseURL) {
		
		NSURL *link = self.baseURL.copy;
		
		if (addPackageInfo) {
			
			if (self.languageCode) {
				
				link = [link URLByAppendingPathComponent:self.languageCode];
				
				if (self.packageCode) {
					
					link = [link URLByAppendingPathComponent:self.packageCode];
					
					if (self.pageNumber && ![self.pageNumber isEqualToNumber:@0]) {
						
						link = [link URLByAppendingPathComponent:self.pageNumber.stringValue];
						
					}
					
				}
			}
			
		}
		
		if (addCampaignInfo) {
			
			NSString *appVersionNumber	= [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
			return [NSURL URLWithString:[link.absoluteString stringByAppendingFormat:@"?utm_source=%@&utm_medium=%@&utm_content=%@&utm_campaign=%@", self.source, self.medium, appVersionNumber, self.campaign]];
			
		}
		
		return link;
		
	} else {
		
		return [NSURL URLWithString:@""];
	}
	
}

- (NSString *)subject {
	
	return [self replaceTermsWithValuesInString:_subject];
	
}

- (NSString *)message {
	
	return [self replaceTermsWithValuesInString:_message];
	
}
	
- (NSString *)replaceTermsWithValuesInString:(NSString *)string {
	
	NSString *message = string;
	
	if (message) {
		
		if (self.shareURL) {
		
			message = [message stringByReplacingOccurrencesOfString:@"{{share_link}}" withString:self.shareURL.absoluteString];
		}
		
		if (self.appName) {
			
			message = [message stringByReplacingOccurrencesOfString:@"{{app_name}}" withString:self.appName];
		}
		
		if (self.packageName) {
			
			message = [message stringByReplacingOccurrencesOfString:@"{{package_name}}" withString:self.packageName];
		}
		
	}
	
	return message;
}

#pragma mark - UIActivityItemSource

#pragma mark required source methods

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
	
	return self.message;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
	
	
	return self.message;
}

#pragma mark optional source methods

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
	
	return self.subject;
}

@end
