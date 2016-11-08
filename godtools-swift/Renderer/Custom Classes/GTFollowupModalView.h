//
//  GTFollowupModalView.h
//  GTViewController
//
//  Created by Ryan Carlson on 4/7/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBXML.h"

#import "GTPageStyle.h"
#import "GTPageInterpreter.h"
#import "GTFollowupThankYouView.h"

@interface GTFollowupModalView : UIView<UITextFieldDelegate>

@property (strong, nonatomic) NSArray *listeners;
@property (strong, nonatomic) GTFollowupThankYouView *thankYouView;

@property (strong, nonatomic) NSMutableArray *inputFieldViews;
@property (strong, nonatomic) NSString *followupId;

- (instancetype)initFromElement:(TBXMLElement *)element withStyle:(GTPageStyle*)style presentingView:(UIView *)presentingView interpreterDelegate:(id<GTInterpreterDelegate>)interpreterDelegate buttonTapDelegate:(id<UISnuffleButtonTapDelegate>)tapDelegate;

- (void)setWatermark:(UIImageView *) watermarkImageView;
@end