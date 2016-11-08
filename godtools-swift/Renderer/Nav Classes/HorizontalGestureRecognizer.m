//
//  HorizontalGestureRecognizer.m
//  Snuffy
//
//  Created by Michael Harrison on 28/06/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "HorizontalGestureRecognizer.h"

NSInteger const HorizontalGestureRecognizerMinSwipeSpeed	= 400;

@interface HorizontalGestureRecognizer ()

@property (nonatomic, weak)		id<HorizontalGestureRecognizerDelegate> delegate;
@property (nonatomic, strong)	UIView			*targetView;

@property (nonatomic, assign)	double			totalHorizontalDistance;
@property (nonatomic, assign)	double			totalHorizontalSpeed;
@property (nonatomic, assign)	double			horizontalSpeed;

@property (nonatomic, assign)	CGPoint			startTouchPosition;
@property (nonatomic, assign)	NSTimeInterval	startTimeStamp;

@property (nonatomic, assign)	CGPoint			lastTouchPosition;
@property (nonatomic, assign)	NSTimeInterval	lastTimeStamp;

@end

@implementation HorizontalGestureRecognizer

- (instancetype)initWithDelegate:(id<HorizontalGestureRecognizerDelegate>)delegate target:(UIView *)target {
	
	self = [super init];
	
	if (self) {
	
		self.delegate				= delegate;
		self.targetView				= target;
		
	}
	
	return self;
}

- (void)processTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //grab touch attributes
    UITouch *touch = [touches anyObject];
    
    //set initial values for instance variables
    self.startTouchPosition		= [touch locationInView:self.targetView];
    self.startTimeStamp			= [touch timestamp];
    self.lastTouchPosition		= [touch locationInView:self.targetView];
    self.lastTimeStamp			= [touch timestamp];
    self.totalHorizontalDistance = 0;
}

- (void)processTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//grab the attributes of the current touch object
	NSEnumerator *touchEnum = [touches objectEnumerator];
    UITouch *touch = nil;
	CGPoint previousLocationInView;
	
	//find the touch object with the same previous value as the lastTouchPosition
	while ((touch = [touchEnum nextObject])) {
		previousLocationInView = [touch previousLocationInView:self.targetView];
		if (previousLocationInView.x == self.lastTouchPosition.x && previousLocationInView.y == self.lastTouchPosition.y) {
			break;
		}
		touch = nil;
	}
	
	//only do calculations if we are dealing with the correct touch object
	if (touch != nil) {
		CGPoint currentTouchPosition = [touch locationInView:self.targetView];
		NSTimeInterval currentTimeStamp = [touch timestamp];
		
		//calculate changes in direction and time since last call to touchesMoved
		double deltaX = currentTouchPosition.x - self.lastTouchPosition.x;
		double deltaT = currentTimeStamp - self.lastTimeStamp;
		
		//add the current change in distance to the total distance
		self.totalHorizontalDistance += fabs(deltaX);
		
		//calculate instantanious speeds
		self.horizontalSpeed  = deltaX / deltaT;
		
		//calculate overall speed
		self.totalHorizontalSpeed = self.totalHorizontalDistance / (currentTimeStamp - self.startTimeStamp);
		
		// Check the direction.
		if (self.startTouchPosition.x < currentTouchPosition.x) {
			if ([self.delegate respondsToSelector:@selector(processRightDrag:withEvent:)]) {
				[self.delegate performSelector:@selector(processRightDrag:withEvent:) withObject:touch withObject:event];
			}
		} else {
			if ([self.delegate respondsToSelector:@selector(processLeftDrag:withEvent:)]) {
				[self.delegate performSelector:@selector(processLeftDrag:withEvent:) withObject:touch withObject:event];
			}
		}
		
		self.lastTouchPosition	= [touch locationInView:self.targetView];
		self.lastTimeStamp		= [touch timestamp];
	}
}

- (void)processTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//grab the attributes of the current touch object
	NSEnumerator *touchEnum = [touches objectEnumerator];
    UITouch *touch;
	CGPoint previousLocationInView, locationInView;
	
	//find the touch object with the same previous value as the lastTouchPosition
	while ((touch = [touchEnum nextObject])) {
		previousLocationInView = [touch previousLocationInView:self.targetView];
		locationInView = [touch locationInView:self.targetView];
		if ((previousLocationInView.x == self.lastTouchPosition.x && previousLocationInView.y == self.lastTouchPosition.y) || (locationInView.x == self.lastTouchPosition.x && locationInView.y == self.lastTouchPosition.y)) {
			break;
		}
		touch = nil;
	}
	
	//only do calculations if we are dealing with the right touch object
	if (touch != nil) {
		CGPoint endTouchPosition	= [touch locationInView:self.targetView];
		NSTimeInterval endTimeStamp = [touch timestamp];
		
		//check that the touch was not a tap
		if (self.startTimeStamp != endTimeStamp) {
			//calculate the overall speed of the users drag
			self.totalHorizontalSpeed = self.totalHorizontalDistance / (endTimeStamp - self.startTimeStamp);
			
			//check if it was fast enough to be a swipe
			if (fabs(self.horizontalSpeed) > HorizontalGestureRecognizerMinSwipeSpeed) {
				//check direction
				if (self.startTouchPosition.x < endTouchPosition.x) {
					if ([self.delegate respondsToSelector:@selector(processRightSwipe:withEvent:)]) {
						[self.delegate performSelector:@selector(processRightSwipe:withEvent:) withObject:touch withObject:event];
					}
				} else {
					if ([self.delegate respondsToSelector:@selector(processLeftSwipe:withEvent:)]) {
						[self.delegate performSelector:@selector(processLeftSwipe:withEvent:) withObject:touch withObject:event];
					}
				}
				//else its a drag
			} else {
				//check direction
				if (self.startTouchPosition.x < endTouchPosition.x) {
					if ([self.delegate respondsToSelector:@selector(processRightDragEnd:withEvent:)]) {
						[self.delegate performSelector:@selector(processRightDragEnd:withEvent:) withObject:touch withObject:event];
					}
				} else {
					if ([self.delegate respondsToSelector:@selector(processLeftDragEnd:withEvent:)]) {
						[self.delegate performSelector:@selector(processLeftDragEnd:withEvent:) withObject:touch withObject:event];
					}
				}
			}
			
		}
		
		//if its a tap
		if ([touch tapCount] > 0) {
			if ([self.delegate respondsToSelector:@selector(processTap:withEvent:)]) {
				[self.delegate performSelector:@selector(processTap:withEvent:) withObject:touch withObject:event];
			}
		}
		
		[self reset];
	}
}

- (void)processTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if ([self.delegate respondsToSelector:@selector(resetViews)]) {
		[self.delegate performSelector:@selector(resetViews)];
	}
	
	[self reset];
}

- (void)reset {
	self.startTouchPosition		= CGPointZero;
	self.startTimeStamp			= 0.0;
	self.lastTouchPosition		= CGPointZero;
	self.lastTimeStamp			= 0.0;
	self.totalHorizontalDistance= 0.0;
	self.totalHorizontalSpeed	= 0.0;
	self.horizontalSpeed		= 0.0;
}


@end
