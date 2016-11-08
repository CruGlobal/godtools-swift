//
//  GTFollowupModalView.m
//  GTViewController
//
//  Created by Ryan Carlson on 4/7/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTFollowupModalView.h"
#import "GTFollowupThankYouView.h"
#import "GTPageInterpreter.h"
#import "GTLabel.h"
#import "GTInputFieldView.h"
#import "UISnuffleButton.h"
#import "GTMultiButtonResponseView.h"

@interface GTFollowupModalView()

@end

@implementation GTFollowupModalView

- (instancetype)initFromElement:(TBXMLElement *)element withStyle:(GTPageStyle*)style presentingView:(UIView *)presentingView interpreterDelegate:(id<GTInterpreterDelegate>)interpreterDelegate buttonTapDelegate:(id<UISnuffleButtonTapDelegate>)tapDelegate {
    
    self = [super initWithFrame:presentingView.frame];

    [self setBackgroundColor:style.backgroundColor];
    [self setFollowupId:[TBXML valueOfAttributeNamed:@"followup-id" forElement:element]];
    self.inputFieldViews = [[NSMutableArray alloc]init];
    
    TBXMLElement *fallbackElement = element->firstChild;
    
    if (!fallbackElement) {
        return self;
    }
    
    TBXMLElement *modalComponentElement = fallbackElement->firstChild;
    
    int numLabels = 0;
    int numTextInputs = 0;
    int numButtonPairs = 0;
    
    CGFloat topLeadingSpace = 0;
    CGFloat betweenElementsSpace = 0;
    
    CGFloat totalVerticalSpace = presentingView.frame.size.height;
    CGFloat totalUsedSpace = 0;
    modalComponentElement = fallbackElement->firstChild;
    
    // first pass - count objects
    while(modalComponentElement != nil) {
        NSString *modalComponentElementName = [TBXML elementName:modalComponentElement];
        
        if ([modalComponentElementName isEqual:kName_FollowUp_Title]) {
            numLabels++;
            totalUsedSpace += DEFAULT_HEIGHT_LABEL;
        } else if ([modalComponentElementName isEqual:kName_FollowUp_Body]) {
            numLabels++;
            totalUsedSpace += DEFAULT_HEIGHT_LABEL;
        } else if ([modalComponentElementName isEqual:kName_Input_Field]) {
            numTextInputs++;
            totalUsedSpace += DEFAULT_HEIGHT_INPUTFIELD;
        } else if ([modalComponentElementName isEqual:kName_Button_Pair]) {
            numButtonPairs++;
            totalUsedSpace += DEFAULT_HEIGHT_BUTTONPAIR;
        }
        
        modalComponentElement = modalComponentElement->nextSibling;
    }
    
    CGFloat availableBufferSpace = totalVerticalSpace - totalUsedSpace;
    topLeadingSpace =       availableBufferSpace * 0.15;
    betweenElementsSpace =  (availableBufferSpace * 0.2) / (numLabels + numButtonPairs + numTextInputs);
    
    int currentY = topLeadingSpace;
    int inputFieldTag = BASE_TAG_INPUTFIELDTEXT;
    
    // second pass - render objects
    modalComponentElement = fallbackElement->firstChild;
    
    while(modalComponentElement != nil) {
        NSString *modalComponentElementName = [TBXML elementName:modalComponentElement];
        
        if ([modalComponentElementName isEqual:kName_FollowUp_Title]) {
            GTLabel *titleLabel = [[GTLabel alloc]initWithElement:modalComponentElement
                                              parentTextAlignment:UITextAlignmentCenter
                                                             xPos:-1
                                                             yPos:currentY
                                                        container:presentingView
                                                            style:style];
            
            currentY = titleLabel.frame.origin.y + titleLabel.frame.size.height + betweenElementsSpace;
            
            [self addSubview:titleLabel];
        } else if ([modalComponentElementName isEqual:kName_FollowUp_Body]) {
            GTLabel *bodyLabel = [[GTLabel alloc]initWithElement:modalComponentElement
                                             parentTextAlignment:UITextAlignmentLeft
                                                            xPos:-1
                                                            yPos:currentY
                                                       container:presentingView
                                                           style:style];
            currentY = bodyLabel.frame.origin.y + bodyLabel.frame.size.height + betweenElementsSpace;
            
            [self addSubview:bodyLabel];
        } else if ([modalComponentElementName isEqual:kName_Input_Field]) {
            GTInputFieldView *inputFieldView = [[GTInputFieldView alloc] inputFieldWithElement:modalComponentElement
                                                                                         withY:currentY
                                                                                     withStyle:style
                                                                                presentingView:presentingView];
            
            currentY = inputFieldView.frame.origin.y + inputFieldView.frame.size.height + betweenElementsSpace;
            
            // i love C sleight of hand :)
            inputFieldView.inputTextField.tag = inputFieldTag++;
            
            [self.inputFieldViews addObject:inputFieldView];
            [self addSubview:inputFieldView];
        } else if ([modalComponentElementName isEqual:kName_Button_Pair]) {
            TBXMLElement *firstButtonElement = modalComponentElement->firstChild;
            TBXMLElement *secondButtonElement = firstButtonElement->nextSibling;
            
            GTMultiButtonResponseView *buttonPairView = [[GTMultiButtonResponseView alloc] initWithFirstElement:firstButtonElement
                                                                                                  secondElement:secondButtonElement
                                                                                                  parentElement:modalComponentElement
                                                                                                      yPosition:currentY
                                                                                                  containerView:self
                                                                                                      withStyle:style
                                                                                              buttonTapDelegate:tapDelegate];
            
            [self addSubview:buttonPairView];
            
            currentY += buttonPairView.frame.size.height + betweenElementsSpace;
            
        } else if ([modalComponentElementName isEqual:kName_Thank_You]) {
            
            self.thankYouView = [[GTFollowupThankYouView alloc]initFromElement:modalComponentElement
                                                                     withFrame:self.frame
                                                                 withPageStyle:style];
            
            NSArray *listeners = [[TBXML valueOfAttributeNamed:kAttr_listeners forElement:modalComponentElement] componentsSeparatedByString:@","];
            
            for (id listener in listeners) {
                NSString *listenerName = listener;
                
                if ([interpreterDelegate respondsToSelector:@selector(registerListenerWithEventName:target:selector:parameter:)]) {
                    [interpreterDelegate registerListenerWithEventName:listenerName
                                                                target:interpreterDelegate
                                                              selector:@selector(transitionFollowupToThankYou)
                                                             parameter:nil];
                    
                }
            }
        }
        
        modalComponentElement = modalComponentElement->nextSibling;
    }
    
    return self;
}


- (void)setWatermark:(UIImageView *) watermarkImageView {

    [self addSubview:[self copyWatermark:watermarkImageView]];
    [self.thankYouView addSubview:[self copyWatermark:watermarkImageView]];
}


/* see: http://stackoverflow.com/questions/25439234/how-to-clone-a-uiimageview */
- (UIImageView *)copyWatermark:(UIImageView *)watermarkImageView {
    UIImageView *watermarkCopy = [[UIImageView alloc]initWithImage:watermarkImageView.image];
    
    watermarkCopy.frame = CGRectMake(0, 0, watermarkImageView.frame.size.width, watermarkImageView.frame.size.height);
    watermarkCopy.alpha = watermarkImageView.alpha;//same view opacity
    watermarkCopy.layer.opacity = watermarkImageView.layer.opacity;//same layer opacity
    watermarkCopy.clipsToBounds = watermarkImageView.clipsToBounds;//same clipping settings
    watermarkCopy.backgroundColor = watermarkImageView.backgroundColor;//same BG color

    return watermarkCopy;
}

@end