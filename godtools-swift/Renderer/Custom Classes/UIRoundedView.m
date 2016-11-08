//
//  UIRoundedView.m
//  Snuffy
//
//  Created by Michael Harrison on 1/07/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "UIRoundedView.h"

#import "snuffyViewControllerTouchNotifications.h"
#import "HorizontalGestureRecognizer.h"

extern NSString * const kTitleMode_peek;

@interface UIRoundedView ()

@property (nonatomic, assign) CGPoint			startTouchPosition;
@property (nonatomic, assign) NSTimeInterval	startTimeStamp;
@property (nonatomic, assign) CGPoint			lastTouchPosition;
@property (nonatomic, assign) NSTimeInterval	lastTimeStamp;
@property (nonatomic, assign) double			totalHorizontalDistance;
@property (nonatomic, assign) double			horizontalSpeed;

@property (nonatomic, assign) BOOL				firstMoveOfTouch;

@end

@implementation UIRoundedView

- (instancetype)initWithFrame:(CGRect)frame bgColor:(UIColor *)color radius:(CGFloat)rad tapDelegate:(id<UIRoundedViewTapDelegate>)tapDelegate {
	
	if ((self = [self initWithFrame:frame])) {
		
        self.tapDelegate     = tapDelegate;

        self.BGColor         = color;
        self.radius          = rad;
        self.backgroundColor = [self.BGColor colorWithAlphaComponent:0.0];

        self.topleft         = YES;
        self.topright        = YES;
        self.bottomright     = YES;
        self.bottomleft      = YES;
	}
	
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame bgColor:(UIColor *)color radius:(CGFloat)rad topleft:(BOOL)tl topright:(BOOL)tr bottomright:(BOOL)br bottomleft:(BOOL)bl tapDelegate:(id<UIRoundedViewTapDelegate>)tapDelegate {
	
	if ((self = [self initWithFrame:frame])) {
		
        self.tapDelegate     = tapDelegate;

        self.BGColor         = color;
        self.radius          = rad;
        self.backgroundColor = [self.BGColor colorWithAlphaComponent:0.0];

        self.topleft         = tl;
        self.topright        = tr;
        self.bottomright     = br;
        self.bottomleft      = bl;
	}
	
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
	
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//NSLog(@"UIRoundedView: touchesBegan");
	UITouch *touch = [touches anyObject];
	
	if (self.startTimeStamp == 0) {
        self.firstMoveOfTouch        = YES;
        self.startTouchPosition      = [touch locationInView:self.tapDelegate.viewOfPageViewController];
        self.startTimeStamp          = [touch timestamp];
        self.lastTouchPosition       = [touch locationInView:self.tapDelegate.viewOfPageViewController];
        self.lastTimeStamp           = [touch timestamp];
        self.totalHorizontalDistance = 0;
        self.horizontalSpeed         = 0;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

	//grab the attributes of the current touch object
    NSEnumerator *touchEnum = [touches objectEnumerator];
    UITouch *touch          = nil;
	CGPoint previousLocationInView;
	
	//find the touch object with the same previous value as the lastTouchPosition
	while ((touch = [touchEnum nextObject])) {
		previousLocationInView = [touch previousLocationInView:self.tapDelegate.viewOfPageViewController];
		if (previousLocationInView.x == self.lastTouchPosition.x && previousLocationInView.y == self.lastTouchPosition.y) {
			break;
		}
		touch = nil;
	}
	
	//only do calculations if we are dealing with the correct touch object
	if (touch != nil) {
		
        CGPoint currentTouchPosition    = [touch locationInView:self.tapDelegate.viewOfPageViewController];
        NSTimeInterval currentTimeStamp = [touch timestamp];

		//calculate changes in direction and time since last call to touchesMoved
        double deltaX                   = fabs(currentTouchPosition.x - self.lastTouchPosition.x);
        double deltaT                   = currentTimeStamp - self.lastTimeStamp;

		//add the current change in distance to the total distance
        self.totalHorizontalDistance    += deltaX;

		//calculate instantanious speeds
        self.horizontalSpeed            = deltaX / deltaT;
        self.lastTouchPosition          = currentTouchPosition;
        self.lastTimeStamp              = currentTimeStamp;
		
		if (self.firstMoveOfTouch) {
			
			[[NSNotificationCenter defaultCenter] postNotificationName:snuffyViewControllerTouchNotificationTouchesBegan
																object:self
															  userInfo:@{snuffyViewControllerTouchNotificationTouchesKey:	touches,
																		 snuffyViewControllerTouchNotificationEventKey:		event}];
			
			self.firstMoveOfTouch		= NO;
		}
	}
	
	if (!self.firstMoveOfTouch) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:snuffyViewControllerTouchNotificationTouchesMoved
															object:self
														  userInfo:@{snuffyViewControllerTouchNotificationTouchesKey:	touches,
																	 snuffyViewControllerTouchNotificationEventKey:		event}];
		
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
    NSEnumerator *touchEnum = [touches objectEnumerator];
    UITouch *touch          = nil;
	CGPoint previousLocationInView, locationInView;
	
	//find the touch object with the same previous value as the lastTouchPosition
	while ((touch = [touchEnum nextObject])) {
		
        previousLocationInView = [touch previousLocationInView:self.tapDelegate.viewOfPageViewController];
        locationInView         = [touch locationInView:self.tapDelegate.viewOfPageViewController];
		
		if ((previousLocationInView.x == self.lastTouchPosition.x && previousLocationInView.y == self.lastTouchPosition.y) || (locationInView.x == self.lastTouchPosition.x && locationInView.y == self.lastTouchPosition.y)) {
			
			break;
		}
		
		touch = nil;
	}
	
	//only do calculations if we are dealing with the correct touch object
	if (touch != nil) {
		
		if (([touch tapCount] == 1 && (self.horizontalSpeed < HorizontalGestureRecognizerMinSwipeSpeed)) || self.firstMoveOfTouch || (self.totalHorizontalDistance < (0.5 * CGRectGetWidth(self.tapDelegate.viewOfPageViewController.frame)) && (self.horizontalSpeed < HorizontalGestureRecognizerMinSwipeSpeed))) {
			
			//based on the mode change the callback
			if ([self.titleMode isEqual:kTitleMode_peek]) {
				
				if ([self.tapDelegate respondsToSelector:@selector(didReceiveTapOnPeekPanel:)]) {
					
					[self.tapDelegate didReceiveTapOnPeekPanel:self];
					
				}
				
			} else {
				
				[[NSNotificationCenter defaultCenter] postNotificationName:snuffyViewControllerTouchNotificationTap
																	object:self
																  userInfo:@{snuffyViewControllerTouchNotificationTouchKey:	touch,
																			 snuffyViewControllerTouchNotificationEventKey:	event}];
				
			}
			
		}
		
		[self reset];
	}
	
	if (!self.firstMoveOfTouch) {
		
		[[NSNotificationCenter defaultCenter] postNotificationName:snuffyViewControllerTouchNotificationTouchesEnded
															object:self
														  userInfo:@{snuffyViewControllerTouchNotificationTouchesKey:	touches,
																	 snuffyViewControllerTouchNotificationEventKey:		event}];
	}
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[self reset];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:snuffyViewControllerTouchNotificationTouchesCancelled
														object:self
													  userInfo:@{snuffyViewControllerTouchNotificationTouchesKey:	touches,
																 snuffyViewControllerTouchNotificationEventKey:		event}];
}

- (void)reset {
	
    self.startTouchPosition      = CGPointZero;
    self.startTimeStamp          = 0.0;
    self.lastTouchPosition       = CGPointZero;
    self.lastTimeStamp           = 0.0;
    self.totalHorizontalDistance = 0.0;
    self.horizontalSpeed         = 0.0;
    self.firstMoveOfTouch        = NO;
}

- (void)fillRoundedRect:(CGRect)rect inContext:(CGContextRef)context {
	
    CGContextBeginPath(context);
	
	CGContextSetFillColorWithColor(context, [self.BGColor CGColor]);
	CGContextMoveToPoint(context, CGRectGetMinX(rect) + self.radius, CGRectGetMinY(rect));
	
	if (self.topright) {
		CGContextAddArc(context, CGRectGetMaxX(rect) - self.radius, CGRectGetMinY(rect) + self.radius, self.radius, 3 * M_PI / 2, 0, 0);
	} else {
		CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
	}
	
    if (self.bottomright) {
		CGContextAddArc(context, CGRectGetMaxX(rect) - self.radius, CGRectGetMaxY(rect) - self.radius, self.radius, 0, M_PI / 2, 0);
	} else {
		CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
	}
    
	if (self.bottomleft) {
		CGContextAddArc(context, CGRectGetMinX(rect) + self.radius, CGRectGetMaxY(rect) - self.radius, self.radius, M_PI / 2, M_PI, 0);
	} else {
		CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
	}
	
	if (self.topleft) {
		CGContextAddArc(context, CGRectGetMinX(rect) + self.radius, CGRectGetMinY(rect) + self.radius, self.radius, M_PI, 3 * M_PI / 2, 0);
	} else {
		CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	}
	
    CGContextClosePath(context);
    CGContextFillPath(context);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)drawingBoundary {
	CGRect rect = [self bounds];
    CGContextRef context = UIGraphicsGetCurrentContext();
	[self fillRoundedRect:rect inContext:context];
}


@end