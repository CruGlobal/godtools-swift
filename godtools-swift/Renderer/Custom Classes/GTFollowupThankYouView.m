//
//  GTFollowupThankYouView.m
//  GTViewController
//
//  Created by Ryan Carlson on 4/12/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTFollowupThankYouView.h"
#import "GTLabel.h"

#import "GTPageInterpreter.h"
#import "UISnuffleButton.h"

@implementation GTFollowupThankYouView

- (instancetype) initFromElement:(TBXMLElement *) thankYouComponentElement withFrame:(CGRect)frame withPageStyle:(GTPageStyle *)style {
    
    self = [super initWithFrame:frame];
    [self setBackgroundColor:style.backgroundColor];
    
    TBXMLElement *thankYouElement = thankYouComponentElement->firstChild;
    
    int numLabels = 0;
    int numTextInputs = 0;
    int numButtonPairs = 0;
    
    CGFloat topLeadingSpace = 0;
    CGFloat betweenElementsSpace = 0;
    
    CGFloat totalVerticalSpace = frame.size.height;
    CGFloat totalUsedSpace = 0;

    // first pass - count objects
    while (thankYouElement) {
        NSString *thankYouElementName = [TBXML elementName:thankYouElement];
        
        if ([thankYouElementName isEqual:kName_Label]) {
            numLabels++;
            totalUsedSpace += DEFAULT_HEIGHT_LABEL;
        } else if ([thankYouElementName isEqual:kName_Button]) {
            numLabels++;
            totalUsedSpace += DEFAULT_HEIGHT_LABEL;
        }
        
        thankYouElement = thankYouElement->nextSibling;
    }
    
    CGFloat availableBufferSpace = totalVerticalSpace - totalUsedSpace;
    topLeadingSpace =       availableBufferSpace * 0.2;
    betweenElementsSpace =  (availableBufferSpace * 0.2) / (numLabels + numButtonPairs + numTextInputs);
    
    int currentY = topLeadingSpace;
    
    thankYouElement = thankYouComponentElement->firstChild;
    
    while (thankYouElement) {
        NSString *thankYouElementName = [TBXML elementName:thankYouElement];
        
        if ([thankYouElementName isEqual:kName_Label]) {
            UILabel *label = [[GTLabel alloc]initWithElement:thankYouElement
                                         parentTextAlignment:UITextAlignmentLeft
                                                        xPos:-1
                                                        yPos:currentY
                                                   container:self
                                                       style:style];
            
            currentY += label.frame.size.height + betweenElementsSpace;
            
            [self addSubview:label];
        } else if ([thankYouElementName isEqual:kName_LinkButton] || [thankYouElementName isEqual:kName_Button]) {
            UISnuffleButton *button = [[UISnuffleButton alloc]buttonWithElement:thankYouElement
                                                                         addTag:0
                                                                           yPos:currentY
                                                                      container:self
                                                                      withStyle:style
                                                              buttonTapDelegate:nil];
            
            currentY += button.frame.origin.y + betweenElementsSpace;
            
            [self addSubview:button];
        }
        
        thankYouElement = thankYouElement->nextSibling;
    }
    
    return self;
}
@end