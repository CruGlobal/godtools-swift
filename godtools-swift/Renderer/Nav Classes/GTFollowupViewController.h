//
//  GTFollowUpController.h
//  GTViewController
//
//  Created by Ryan Carlson on 4/12/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UISnuffleButton.h"

extern NSString *const GTFollowupViewControllerFieldSubscriptionNotificationName;
extern NSString *const GTFollowupViewControllerFieldSubscriptionEventName;
extern NSString *const GTFollowupViewControllerFieldKeyEmail;
extern NSString *const GTFollowupViewControllerFieldKeyName;
extern NSString *const GTFollowupViewControllerFieldKeyFollowupId;

@class GTFollowupModalView, GTFollowupThankYouView;

@interface GTFollowupViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate, UISnuffleButtonTapDelegate>

@property (strong,nonatomic) GTFollowupModalView *followupModalView;
@property (strong,nonatomic) GTFollowupThankYouView *followupThankYouView;

- (void)setFollowupView:(GTFollowupModalView *)followupModalView;
- (void)setFollowupView:(GTFollowupModalView *)followupModalView andThankYouView:(GTFollowupThankYouView *)thankYouView;
- (void)setPackageCode:(NSString *)packageCode andLanguageCode:(NSString *)languageCode;

- (void)transitionToThankYou;
@end
