//
//  GTPage.h
//  Snuffy
//
//  Created by Michael Harrison on 24/06/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "UISnuffleButton.h"
#import "UIRoundedView.h"
#import "GTFollowupViewController.h"

extern NSString * const GTPageNotificationEvent;
extern NSString * const GTPageNotificationEventKeyEventName;

@protocol GTPageDelegate;

@class GTFileLoader;

@interface GTPage : UIView < UIRoundedViewTapDelegate, UISnuffleButtonTapDelegate >

@property	BOOL	viewBeingMoved;

- (instancetype)initWithFilename:(NSString *)file frame:(CGRect)frame delegate:(id<GTPageDelegate>)delegate fileLoader:(GTFileLoader *)fileLoader;
- (void)cacheImages;
- (void)tapAnywhere;

- (BOOL)viewWillTransitionWithSwipe:(BOOL)swipe;
- (void)viewWillReturnToCenter;
- (void)viewWillTransitionOut;
- (void)viewHasTransitionedIn;
- (void)viewHasTransitionedOut;
- (void)viewHasReturnedToCenter;
- (BOOL)viewControllerWillBeReleased;

- (void)triggerEventWithName:(NSString *)eventName;

@end

@protocol GTPageDelegate <NSObject>

- (UIView *)viewOfPageViewController;

@optional
- (void)hideNavToolbar;
- (void)setActiveViewMasked:(BOOL)masked;
- (void)page:(GTPage *)page didReceiveTapOnURL:(NSURL *)url;
- (void)page:(GTPage *)page didReceiveTapOnPhoneNumber:(NSString *)phoneNumber;
- (void)page:(GTPage *)page didReceiveTapOnEmailAddress:(NSString *)emailAddress;
- (void)page:(GTPage *)page didReceiveTapOnAllUrls:(NSArray *)urlArray;

- (void)presentFollowupModal:(GTFollowupViewController *)followupViewController;
- (void)transitionFollowupToThankYou;
- (void)dismissFollowupModal;
- (NSString *)currentLanguageCode;
- (NSString *)currentPackageCode;
@end
