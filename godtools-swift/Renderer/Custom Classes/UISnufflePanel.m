//
//  UISnufflePanel.m
//  Snuffy
//
//  Created by Michael Harrison on 27/07/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "UISnufflePanel.h"


@implementation UISnufflePanel


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
 - (void)drawRect:(CGRect)drawingBoundary {
 CGRect rect = [self bounds];
 CGContextRef context = UIGraphicsGetCurrentContext();
 
 //draw boundary
 CGContextBeginPath(context);
 
 //CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:0.5] CGColor]);
 CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:(0.0/255.0) green:(0.0/255.0) blue:(0.0/255.0) alpha:0.6] CGColor]);
 CGContextSetLineWidth(context, 1.0);
 
 CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
 
 CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
 CGContextMoveToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect)+1);
 CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
 CGContextMoveToPoint(context, CGRectGetMaxX(rect)-1, CGRectGetMaxY(rect));
 CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
 CGContextMoveToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect)-1);
 CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect)+1);
 
 CGContextDrawPath(context, kCGPathStroke);
 }
 */



@end
