//
//  GTShareViewController.m
//  GTViewController
//
//  Created by Michael Harrison on 5/20/14.
//  Copyright (c) 2014 Michael Harrison. All rights reserved.
//

#import "GTShareViewController.h"
#import "GTViewController.h"
#import "SSCWhatsAppActivity.h"

@interface GTShareViewController ()

@end

@implementation GTShareViewController

- (instancetype)initWithInfo:(GTShareInfo *)shareInfo {
	
	NSArray *shareArray = @[ ( shareInfo ? shareInfo : @"" ) ];
	GTShareViewController *shareViewController = [self initWithActivityItems:shareArray applicationActivities:nil];
	
	return shareViewController;
}

- (instancetype)initWithActivityItems:(NSArray *)activityItems applicationActivities:(NSArray *)applicationActivities {
	
	SSCWhatsAppActivity *whatsAppActivity	= [[SSCWhatsAppActivity alloc] init];
	NSArray *activities = ( applicationActivities ? [applicationActivities arrayByAddingObject:whatsAppActivity] : @[whatsAppActivity] );
	
	self = [super initWithActivityItems:activityItems applicationActivities:activities];
	
	if (self) {

		self.excludedActivityTypes	= @[//UIActivityTypePostToFacebook,
										//UIActivityTypePostToTwitter,
										//UIActivityTypePostToWeibo,
										//UIActivityTypeMessage,
										//UIActivityTypeMail,
										UIActivityTypePrint,
										//UIActivityTypeCopyToPasteboard,
										//UIActivityTypeAssignToContact,
										//UIActivityTypeSaveToCameraRoll,
										/////////UIActivityTypeAddToReadingList,    //iOS7
										/////////UIActivityTypePostToFlickr,        //iOS7
										////////UIActivityTypePostToVimeo,          //iOS7
										//UIActivityTypePostToTencentWeibo,         //iOS7
										/////////UIActivityTypeAirDrop              //iOS7
										];
        if(([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)){//if version is greater than or equal to 7.0
            
             NSMutableArray* excludedActivityForEqualOrGreaterThaniOS7 = [[NSMutableArray alloc]initWithArray:@[
                                                                                                                UIActivityTypeAddToReadingList,
                                                                                                                UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,
                                                                                                                //UIActivityTypePostToTencentWeibo,
                                                                                                                UIActivityTypeAirDrop]];

            
            [excludedActivityForEqualOrGreaterThaniOS7 addObjectsFromArray:self.excludedActivityTypes];
            self.excludedActivityTypes = [NSArray arrayWithArray:excludedActivityForEqualOrGreaterThaniOS7];
        }
		
	}
	
	return self;
}

@end
