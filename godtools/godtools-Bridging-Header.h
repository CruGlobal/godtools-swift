//
//  godtools-Bridging-Header.h
//  godtools
//
//  Created by Ryan Carlson on 7/4/17.
//  Copyright © 2017 Cru. All rights reserved.
//

#ifndef godtools_Bridging_Header_h
#define godtools_Bridging_Header_h

#import <GoogleConversionTracking/ACTReporter.h>

// The Google/Analytics pod has been deprecated. Since moving to the GoogleAnalytics pod, these need to be manually added to the bridging header.
#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIFields.h>
#import <GoogleAnalytics/GAILogger.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import <GoogleAnalytics/GAITrackedViewController.h>
#import <GoogleAnalytics/GAITracker.h>

#endif /* godtools_Bridging_Header_h */
