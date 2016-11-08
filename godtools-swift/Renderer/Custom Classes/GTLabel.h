//
//  GTLabel.h
//  GTViewController
//
//  Created by Ryan Carlson on 4/8/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTPageStyle.h"

@interface GTLabel : UILabel

- (instancetype)initWithElement:(TBXMLElement *)element parentTextAlignment:(UITextAlignment)panelAlign xPos:(CGFloat)xpostion yPos:(CGFloat)ypostion container:(UIView *)container style:(GTPageStyle *)style;

- (instancetype)initWithFrame:(CGRect)frame autoResize:(BOOL)resize text:(NSString *)text color:(UIColor *)color bgColor:(UIColor *)bgColor alpha:(CGFloat)alpha alignment:(UITextAlignment)textAlignment font:(NSString *)font size:(NSUInteger)size;
@end