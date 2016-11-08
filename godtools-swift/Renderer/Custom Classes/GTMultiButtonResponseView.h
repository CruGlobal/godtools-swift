//
//  UIMultiButtonResponseView.h
//  GTViewController
//
//  Created by Ryan Carlson on 4/6/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBXML.h"

#import "UISnuffleButton.h"
#import "GTPageStyle.h"

@interface GTMultiButtonResponseView : UIView

@property (strong, nonatomic) UISnuffleButton *positiveButton;
@property (strong, nonatomic) UISnuffleButton *negativeButton;

- (instancetype) initWithFirstElement:(TBXMLElement *)firstElement secondElement:(TBXMLElement *)secondElement parentElement:(TBXMLElement *) parentElement yPosition:(CGFloat)y containerView:(UIView *)container withStyle:(GTPageStyle *) pageStyle buttonTapDelegate:(id<UISnuffleButtonTapDelegate>)tapDelegate ;

@end