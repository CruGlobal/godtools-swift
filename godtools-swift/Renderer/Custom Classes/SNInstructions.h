//
//  SNInstructions.h
//  Snuffy
//
//  Created by Michael Harrison on 6/18/12.
//  Copyright (c) 2012 CCCA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SNTextDirectionMode) {
    SNTextDirectionModeLeftToRight,
	SNTextDirectionModeRightToLeft
};

@protocol SNInstructionsDelegate;

@interface SNInstructions : NSObject

-(void)showIntructionsInView:(UIView *)view forDirection:(SNTextDirectionMode)textDirection withDelegate:(id<SNInstructionsDelegate>)delegate;
-(void)stopAnimations;

@end

@protocol SNInstructionsDelegate <NSObject>

@optional
- (void)instructionAnimationsComplete;

@end
