//
//  HorizontalGestureRecognizer.h
//  Snuffy
//
//  Created by Michael Harrison on 28/06/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSInteger const HorizontalGestureRecognizerMinSwipeSpeed;

@protocol HorizontalGestureRecognizerDelegate;

@interface HorizontalGestureRecognizer : NSObject

- (instancetype)initWithDelegate:(id<HorizontalGestureRecognizerDelegate>)delegate target:(UIView *)target;

- (void)processTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)processTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)processTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)processTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)reset;

@end

@protocol HorizontalGestureRecognizerDelegate <NSObject>

@optional
- (void)processRightSwipe:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)processLeftSwipe:(UITouch *)touch withEvent:(UIEvent *)event;

- (void)processRightDrag:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)processLeftDrag:(UITouch *)touch withEvent:(UIEvent *)event;

- (void)processRightDragEnd:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)processLeftDragEnd:(UITouch *)touch withEvent:(UIEvent *)event;

- (void)processTap:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)resetViews;

@end
