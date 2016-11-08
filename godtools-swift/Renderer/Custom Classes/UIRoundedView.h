//
//  UIRoundedView.h
//  Snuffy
//
//  Created by Michael Harrison on 1/07/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIRoundedViewTapDelegate;

@interface UIRoundedView : UIView

@property (nonatomic, weak  ) id<UIRoundedViewTapDelegate> tapDelegate;
@property (nonatomic, strong) UIColor                  *BGColor;
@property (nonatomic, assign) CGFloat                  radius;

@property (nonatomic, assign) BOOL                     topleft;
@property (nonatomic, assign) BOOL                     topright;
@property (nonatomic, assign) BOOL                     bottomright;
@property (nonatomic, assign) BOOL                     bottomleft;

@property (nonatomic, strong) NSString                 *titleMode;

- (instancetype)initWithFrame:(CGRect)frame bgColor:(UIColor *)color radius:(CGFloat)rad tapDelegate:(id<UIRoundedViewTapDelegate>)tapDelegate;
- (instancetype)initWithFrame:(CGRect)frame bgColor:(UIColor *)color radius:(CGFloat)rad topleft:(BOOL)tl topright:(BOOL)tr bottomright:(BOOL)br bottomleft:(BOOL)bl tapDelegate:(id<UIRoundedViewTapDelegate>)tapDelegate;

-(void)reset;

@end

@protocol UIRoundedViewTapDelegate <NSObject>

- (CGRect)pageFrame;
- (UIView *)viewOfPageViewController;

@optional
- (void)didReceiveTapOnPeekPanel:(UIRoundedView *)peekPanel;

@end
