 //
//  UIMultiButtonResponseView.m
//  GTViewController
//
//  Created by Ryan Carlson on 4/6/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTMultiButtonResponseView.h"
#import "GTFileLoader.h"
#import "GTPageInterpreter.h"

@implementation GTMultiButtonResponseView


- (instancetype) initWithFirstElement:(TBXMLElement *)firstElement secondElement:(TBXMLElement *)secondElement parentElement:(TBXMLElement *) parentElement yPosition:(CGFloat)y containerView:(UIView *)container withStyle:(GTPageStyle *) pageStyle buttonTapDelegate:(id<UISnuffleButtonTapDelegate>)tapDelegate {
    TBXMLElement *positiveElement                  = nil;
    TBXMLElement *negativeElement                  = nil;
    
    if ([[TBXML elementName:firstElement] isEqual:kName_Positive_Button]) {
        positiveElement = firstElement;
        negativeElement = secondElement;
    } else {
        positiveElement = secondElement;
        negativeElement = firstElement;
    }
    
    CGFloat xoffset                     = round([[TBXML valueOfAttributeNamed:kAttr_xoff forElement:parentElement] floatValue]);
    CGFloat xTrailingOffset             = round([[TBXML valueOfAttributeNamed:@"x-trailing-offset" forElement:parentElement] floatValue]);
    
    GTMultiButtonResponseView *responseView;
    CGRect frame;
    if (xoffset && xTrailingOffset) {
        frame = CGRectMake(xoffset,
                   y,
                   container.frame.size.width - xoffset - xTrailingOffset,
                   DEFAULT_HEIGHT_BUTTONPAIR);
    } else {
        frame = CGRectMake(0, y, container.frame.size.width, DEFAULT_HEIGHT_BUTTONPAIR);
    }
    
    responseView = [super initWithFrame:frame];
    
    UISnuffleButton *negativeButton = [[UISnuffleButton alloc] buttonWithElement:negativeElement
                                                                          addTag:0
                                                                            yPos:0
                                                                       container:responseView
                                                                       withStyle:pageStyle
                                                               buttonTapDelegate:tapDelegate];
    
    
    
    UISnuffleButton *positiveButton = [[UISnuffleButton alloc] buttonWithElement:positiveElement
                                                                          addTag:0
                                                                            yPos:0
                                                                       container:responseView
                                                                       withStyle:pageStyle
                                                               buttonTapDelegate:tapDelegate];
    
    [self layoutBasedOnAlignmentPositiveButton:positiveButton
                                negativeButton:negativeButton
                       multiButtonResponseView:responseView
                                     alignment:[TBXML valueOfAttributeNamed:kAttr_align forElement:parentElement]];
    
    [responseView addSubview:negativeButton];
    [responseView addSubview:positiveButton];
    
    return responseView;
}

- (void) layoutBasedOnAlignmentPositiveButton:(UISnuffleButton *)positiveButton negativeButton:(UISnuffleButton *)negativeButton multiButtonResponseView:(GTMultiButtonResponseView *) multiButtonResponseView alignment:(NSString *) alignment {
    
    if (!alignment || [alignment isEqual:@"center"]) {
        [negativeButton setFrame:CGRectMake(10,
                                            0,
                                            negativeButton.frame.size.width,
                                            negativeButton.frame.size.height)];
        
        [positiveButton setFrame:CGRectMake(multiButtonResponseView.frame.size.width - positiveButton.frame.size.width - 10,
                                            0,
                                            positiveButton.frame.size.width,
                                            positiveButton.frame.size.height)];
    } else if ([alignment isEqual:@"right"]) {
        [negativeButton setFrame:CGRectMake(multiButtonResponseView.frame.size.width - positiveButton.frame.size.width - negativeButton.frame.size.width - 10,
                                            0,
                                            negativeButton.frame.size.width,
                                            negativeButton.frame.size.height)];
        
        [positiveButton setFrame:CGRectMake(multiButtonResponseView.frame.size.width - positiveButton.frame.size.width - 10,
                                            0,
                                            positiveButton.frame.size.width,
                                            positiveButton.frame.size.height)];
    }
    
    
}
@end