//
//  DisclosureIndicator.m
//  Snuffy
//
//  Created by Tom Flynn on 20/08/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "UIDisclosureIndicator.h"

#define R 4.5

@implementation UIDisclosureIndicator


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

// Draws a disclosure indicator such that the tip of the arrow is at (x,y)
- (void)BRDrawDisclosureIndicator:(CGContextRef)ctxt x:(CGFloat)x y:(CGFloat)y {
    //static const CGFloat R = 4.5; // "radius" of the arrow head
    static const CGFloat W = 3; // line width
    CGContextSaveGState(ctxt);
    CGContextMoveToPoint(ctxt, x+R, y-R);
    CGContextAddLineToPoint(ctxt, x, y);
    CGContextAddLineToPoint(ctxt, x+R, y+R);
    CGContextSetLineCap(ctxt, kCGLineCapSquare);
    CGContextSetLineJoin(ctxt, kCGLineJoinMiter);
    CGContextSetLineWidth(ctxt, W);
	CGContextSetRGBStrokeColor(ctxt, 1, 1, 1, 1);
    CGContextStrokePath(ctxt);
    CGContextRestoreGState(ctxt);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	
	//BRDrawDisclosureIndicator(UIGraphicsGetCurrentContext(), CGRectGetMidX(rect) - (R / 2), CGRectGetMidY(rect));
	[self BRDrawDisclosureIndicator:UIGraphicsGetCurrentContext() x:CGRectGetMidX(rect) - (R / 2) y:CGRectGetMidY(rect)];
	
}




@end
