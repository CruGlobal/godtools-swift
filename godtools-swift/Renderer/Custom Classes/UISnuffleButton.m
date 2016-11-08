//
//  UISnuffleButton.m
//  Snuffy
//
//  Created by Michael Harrison on 23/07/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "UISnuffleButton.h"
#import "snuffyViewControllerTouchNotifications.h"
#import "HorizontalGestureRecognizer.h"

#import "GTPageInterpreter.h"
#import "GTFileLoader.h"

NSString * const UISnuffleButtonNotificationButtonTapEvent = @"org.cru.godtools.gtviewcontroller.uisnufflebutton.notification.buttontapevent";
NSString * const UISnuffleButtonNotificationButtonTapEventKeyEventName = @"org.cru.godtools.gtviewcontroller.uisnufflebutton.notification.buttontapevent.key.eventname";
NSString * const UISnuffleButtonNotificationButtonTapEventKeyPackageCode = @"org.cru.godtools.gtviewcontroller.uisnufflebutton.notification.buttontapevent.key.packagecode";
NSString * const UISnuffleButtonNotificationButtonTapEventKeyLanguageCode = @"org.cru.godtools.gtviewcontroller.uisnufflebutton.notification.buttontapevent.key.languagecode";

//button mode constants
extern NSString * const kButtonMode_big;
extern NSString * const kButtonMode_url;
extern NSString * const kButtonMode_phone;
extern NSString * const kButtonMode_email;
extern NSString * const kButtonMode_allurl;

@interface UISnuffleButton ()

@property (nonatomic, assign) BOOL                          firstMoveOfTouch;
@property (nonatomic, assign) CGPoint                       startTouchPosition;
@property (nonatomic, assign) NSTimeInterval                startTimeStamp;
@property (nonatomic, assign) CGPoint                       lastTouchPosition;
@property (nonatomic, assign) NSTimeInterval                lastTimeStamp;
@property (nonatomic, assign) double                        totalHorizontalDistance;
@property (nonatomic, assign) double                        horizontalSpeed;

@end

@implementation UISnuffleButton

- (instancetype)initWithFrame:(CGRect)frame tapDelegate:(id<UISnuffleButtonTapDelegate>)tapDelegate {
	
	if ((self = [self initWithFrame:frame])) {
		
        // Initialization code
		self.tapDelegate = tapDelegate;
		
    }
	
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
    }
	
    return self;
}

#pragma mark -
#pragma mark Create Functions


/**
 *	Description:	Creates a UISnuffleButton given a button element
 *	Parameters:		element:	The TBXMLElement that describes the button
 *					Tag:		The number that identifies the button
 *					yPos:		The y position of the button (which starts with the 2px line at the top)
 *	Returns:		A UISnuffleButton object with parameters set to what is described in the xml element.
 */
- (id)buttonWithElement:(TBXMLElement *)element addTag:(NSInteger)tag yPos:(CGFloat)yPos container:(UIView *)container withStyle:(GTPageStyle *)pageStyle buttonTapDelegate:(id<UISnuffleButtonTapDelegate>)buttonDelegate {
    
    if (element != nil) {
        
        //init variables for xml elements
        TBXMLElement						*button_label		= [TBXML childElementNamed:kName_ButtonText		parentElement:element];
        TBXMLElement						*button_image		= [TBXML childElementNamed:kName_Image			parentElement:element];
        
        //init button's xml attributes
        NSString							*mode				= [TBXML valueOfAttributeNamed:kAttr_mode		forElement:element];
        NSString							*text				= nil;
        NSString                            *urlTarget          = nil;
        NSString							*textColorString	= nil;
        NSString							*textSizeString		= nil;
        NSString							*y					= nil;
        NSString							*image				= nil;
        NSString                            *validationString   = nil;
        NSArray								*tapEvents			= nil;
        CGFloat                             h                   = 0;
        CGFloat                             w                   = 0;
        
        if ([mode isEqual:kButtonMode_url] || [mode isEqual:kButtonMode_email] || [mode isEqual:kButtonMode_phone]) {
            text				= [TBXML valueOfAttributeNamed:kAttr_urlText forElement:element];
            if (text == nil) {
                text            = [TBXML textForElement:element];
            } else {
                urlTarget       = [TBXML textForElement:element];
            }
            textColorString		= [TBXML valueOfAttributeNamed:kAttr_color	forElement:element];
            textSizeString		= [TBXML valueOfAttributeNamed:kAttr_size	forElement:element];
            y					= [TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
        } else if ([mode isEqual:kButtonMode_allurl]) {
            text				= [TBXML textForElement:element];
            textColorString		= [TBXML valueOfAttributeNamed:kAttr_color	forElement:element];
            textSizeString		= [TBXML valueOfAttributeNamed:kAttr_size	forElement:element];
            y					= [TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
        } else if ([mode isEqual:kButtonMode_link] ||
                   [[TBXML elementName:element] isEqual:kName_Positive_Button] ||
                   [[TBXML elementName:element] isEqual:kName_Negative_Button] ||
                   [[TBXML elementName:element] isEqual:kName_LinkButton]) {
            text                = [TBXML textForElement:element];
            textColorString		= [TBXML valueOfAttributeNamed:kAttr_color	forElement:element];
            textSizeString		= [TBXML valueOfAttributeNamed:kAttr_size	forElement:element];
            y					= [TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
            h					= round([[TBXML valueOfAttributeNamed:kAttr_height	forElement:element] floatValue]);
            w					= round([[TBXML valueOfAttributeNamed:kAttr_width  forElement:element] floatValue]);
            validationString    = [TBXML valueOfAttributeNamed:kAttr_validation forElement:element];
        } else {
            text				= [TBXML textForElement:button_label];
            textColorString		= [TBXML valueOfAttributeNamed:kAttr_color	forElement:button_label];
            textSizeString		= [TBXML valueOfAttributeNamed:kAttr_size	forElement:button_label];
            y					= [TBXML valueOfAttributeNamed:kAttr_y		forElement:button_label];
        }
        
        if ([TBXML valueOfAttributeNamed:kAttr_tap_events forElement:element]) {
            tapEvents = [[TBXML valueOfAttributeNamed:kAttr_tap_events forElement:element] componentsSeparatedByString:@","];
        }
        
        //grab the image path if it exists
        if (button_image) {
            image		= [TBXML textForElement:button_image];
        }
        
        
        //if y attr is set then overwrite yPos
        if (y != nil) {
            yPos		= [y floatValue];
        }
        
        //init object ptr to store the button
        UISnuffleButton						*buttonTemp			= nil;
        
        //init variables for button parameters
        UIImage								*bgImage			= nil;
        UIColor								*bgColor			= nil;
        UIColor								*textColor			= [GTPageStyle colorForHex:textColorString];
        CGRect								frame;
        CGFloat								size				= DEFAULT_TEXTSIZE_BUTTON;
        UIControlContentHorizontalAlignment	contentHorizontalAlignment;
        UIControlContentVerticalAlignment	contentVerticalAlignment;
        UIEdgeInsets						edgeInset			= UIEdgeInsetsZero;
        BOOL								hide				= YES;
        BOOL                                validation          = NO;
        
        //set defaults based on mode
        if ([mode isEqual:kButtonMode_big]) {
            frame						= CGRectMake(LARGEBUTTONXOFFSET,
                                                     yPos + 2,
                                                     container.frame.size.width - (2 * LARGEBUTTONXOFFSET),
                                                     DEFAULT_HEIGHT_BIGBUTTON);
            bgColor						= [UIColor clearColor];
            if (textColor == nil) {
                textColor				= pageStyle.defaultTextColor;
            }
            contentHorizontalAlignment	= UIControlContentHorizontalAlignmentCenter;
            contentVerticalAlignment	= UIControlContentVerticalAlignmentBottom;
            edgeInset					= UIEdgeInsetsMake(0, 0, 7, 0);
        } else if ([mode isEqual:kButtonMode_url] ||
                   [mode isEqual:kButtonMode_email] ||
                   [mode isEqual:kButtonMode_phone]) {
            frame						= CGRectMake(BUTTONXOFFSET,
                                                     yPos + 2,
                                                     container.frame.size.width - (2 * BUTTONXOFFSET),
                                                     DEFAULT_HEIGHT_URLBUTTON); //JJ: height of url button
            
            tag							+= 110;
            bgColor						= [UIColor clearColor];
            if (textColor == nil) {
                textColor				= pageStyle.backgroundColor;
            }
            if (image == nil) {
                bgImage = [[GTFileLoader fileLoader] imageWithFilename:@"URL_Button.png"];
            }
            hide						= NO;
            contentHorizontalAlignment	= UIControlContentHorizontalAlignmentCenter;
            contentVerticalAlignment	= UIControlContentVerticalAlignmentCenter;
        } else if ([mode isEqual:kButtonMode_allurl]) {
            frame						= CGRectMake(BUTTONXOFFSET,
                                                     yPos + 2,
                                                     container.frame.size.width - (2 * BUTTONXOFFSET),
                                                     DEFAULT_HEIGHT_ALLURLBUTTON);
            bgColor						= [UIColor clearColor];
            if (textColor == nil) {
                textColor				= pageStyle.defaultTextColor;
            }
            contentHorizontalAlignment	= UIControlContentHorizontalAlignmentCenter;
            contentVerticalAlignment	= UIControlContentVerticalAlignmentCenter;
        } else if ([mode isEqual:kButtonMode_link] || [[TBXML elementName:element] isEqual:kName_LinkButton]) {
            frame						= CGRectMake(BUTTONXOFFSET,
                                                     yPos + 2,
                                                     w ?: container.frame.size.width - BUTTONXOFFSET * 2,
                                                     h ?: DEFAULT_HEIGHT_LINKBUTTON);
            
            tag							+= 110;
            bgColor						= [UIColor clearColor];
            if (textColor == nil) {
                textColor				= pageStyle.defaultTextColor;
            }
            hide						= NO;
            contentHorizontalAlignment	= UIControlContentHorizontalAlignmentCenter;
            contentVerticalAlignment	= UIControlContentVerticalAlignmentCenter;
        } else if ([[TBXML elementName:element] isEqual:kName_Positive_Button] ||
                   [[TBXML elementName:element] isEqual:kName_Negative_Button]) {
            frame						= CGRectMake(BUTTONXOFFSET,
                                                     yPos + 2,
                                                     w,
                                                     h);
            
            tag							+= 110;
            bgColor						= [UIColor clearColor];
            if (textColor == nil) {
                textColor				= pageStyle.backgroundColor;
            }
            if (image == nil) {
                bgImage = [[GTFileLoader fileLoader] imageWithFilename:@"URL_Button.png"];
            }
            hide						= NO;
            contentHorizontalAlignment	= UIControlContentHorizontalAlignmentCenter;
            contentVerticalAlignment	= UIControlContentVerticalAlignmentCenter;
            
            // gate on positive-buttons first.
            if ([[TBXML elementName:element] isEqual:kName_Positive_Button]) {
                validation = !validationString ||
                    (![[validationString lowercaseString] isEqualToString:@"no"] && ![[validationString lowercaseString] isEqualToString:@"false"]);
                
            }
        } else {
            frame						= CGRectMake(BUTTONXOFFSET,
                                                     yPos + 2,
                                                     container.frame.size.width - (2 * BUTTONXOFFSET),
                                                     DEFAULT_HEIGHT_BUTTON);
            bgColor						= [UIColor clearColor];
            if (textColor == nil) {
                textColor				= pageStyle.defaultTextColor;
            }
            contentHorizontalAlignment	= UIControlContentHorizontalAlignmentLeft;
            contentVerticalAlignment	= UIControlContentVerticalAlignmentCenter;
            edgeInset					= UIEdgeInsetsMake(0, 10, 0, 0);
        }
        
        
        
        //load background image if it exists
        if (image != nil) {
            bgImage = [[GTFileLoader fileLoader] imageWithFilename:image];
        }
        
        //if size defined then multiply it by that factor
        if (textSizeString != nil) {
            size = round(size * [textSizeString floatValue] / 100);
        }
        
        //create, set up and return button
        buttonTemp = [[UISnuffleButton alloc] initWithFrame:frame tapDelegate:buttonDelegate];
        buttonTemp.tapEvents = tapEvents;
        [buttonTemp setMode:mode];						//record the button's mode for later use
        [buttonTemp setBackgroundColor:bgColor];
        [buttonTemp setTitle:text forState:UIControlStateNormal];
        //use urlTarget if label text is specified
        if (urlTarget != nil) {
            [buttonTemp setUrlTarget:urlTarget];
        }
        
        if ([mode isEqual:kButtonMode_link] || [[TBXML elementName:element] isEqual:kName_LinkButton]) {
            UIFont *font = [UIFont fontWithName:buttonTemp.titleLabel.font.fontName size:size];
            
            NSDictionary *stringAttributes = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                            NSForegroundColorAttributeName : textColor,
                                               NSFontAttributeName : font};
            
            NSAttributedString *underlinedTitle = [[NSAttributedString alloc] initWithString:text
                                                                                  attributes:stringAttributes];

            [buttonTemp setAttributedTitle:underlinedTitle  forState:UIControlStateNormal];
        } else {
            buttonTemp.titleLabel.font = [UIFont fontWithName:buttonTemp.titleLabel.font.fontName size:size];
            
            if (bgImage) {
                [buttonTemp setBackgroundImage:bgImage forState:UIControlStateNormal];
            }
        }
        
        [buttonTemp setAdjustsImageWhenHighlighted:YES];
        [buttonTemp setTitleColor:textColor forState:UIControlStateNormal];
        [buttonTemp setContentHorizontalAlignment:contentHorizontalAlignment];
        [buttonTemp setContentVerticalAlignment:contentVerticalAlignment];
        [buttonTemp setContentEdgeInsets:edgeInset];
        [buttonTemp setTag:tag];
        [buttonTemp setHidden:hide];
        [buttonTemp setValidation:validation];
        
        return buttonTemp;
        
    } else {
        return nil;
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	//start highlighting
	if ([self.mode isEqual:kButtonMode_url] || [self.mode isEqual:kButtonMode_phone] || [self.mode isEqual:kButtonMode_email] || [self.mode isEqual:kButtonMode_allurl]) {
		
		[self setHighlighted:YES];
	}
	
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
	
	//NSLog(@"UISnuffleButton: touchesMoved");//grab the attributes of the current touch object
	NSEnumerator *touchEnum = [touches objectEnumerator];
    UITouch *touch = nil;
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
			
			self.firstMoveOfTouch = NO;
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
	
	[self setHighlighted:NO];
	
	//grab the attributes of the current touch object
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
			if ([self.mode isEqual:kButtonMode_url]) {
				
				if ([self.tapDelegate respondsToSelector:@selector(didReceiveTapOnURLButton:)]) {
					
					[self.tapDelegate didReceiveTapOnURLButton:self];
					
				}
				
			} else if ([self.mode isEqual:kButtonMode_phone]) {
				
				if ([self.tapDelegate respondsToSelector:@selector(didReceiveTapOnPhoneButton:)]) {
					
					[self.tapDelegate didReceiveTapOnPhoneButton:self];
					
				}
				
			} else if ([self.mode isEqual:kButtonMode_email]) {
				
				if ([self.tapDelegate respondsToSelector:@selector(didReceiveTapOnEmailButton:)]) {
					
					[self.tapDelegate didReceiveTapOnEmailButton:self];
					
				}
				
			} else if ([self.mode isEqual:kButtonMode_allurl]) {
				
				if ([self.tapDelegate respondsToSelector:@selector(didReceiveTapOnAllURLButton:)]) {
					
					[self.tapDelegate didReceiveTapOnAllURLButton:self];
					
				}
				
			} else {
				
				if ([self.tapDelegate respondsToSelector:@selector(didReceiveTapOnButton:)]) {
					
					[self.tapDelegate didReceiveTapOnButton:self];
					
				}
				
			}
			
            BOOL fieldsAreValid = YES;
            
            if (self.validation && self.tapDelegate && [self.tapDelegate respondsToSelector:@selector(validateFields)]) {
                fieldsAreValid = [self.tapDelegate validateFields];
            }
            
            if (fieldsAreValid) {
                [self.tapEvents enumerateObjectsUsingBlock:^(NSString *eventName, NSUInteger idx, BOOL *stop) {
                    if (eventName) {
                        NSString *trimmedEventName = [eventName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:UISnuffleButtonNotificationButtonTapEvent
                                                                            object:self
                                                                          userInfo:[self userInfoForTapEventNotification:trimmedEventName]];
                    }
                }];
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


- (NSDictionary *)userInfoForTapEventNotification:(NSString *)eventName {
    NSMutableDictionary *userInfo = @{}.mutableCopy;
    userInfo[UISnuffleButtonNotificationButtonTapEventKeyEventName] = eventName;
    
    if (self.tapDelegate && [self.tapDelegate respondsToSelector:@selector(currentPackageCode)] && [self.tapDelegate currentPackageCode]) {
        userInfo[UISnuffleButtonNotificationButtonTapEventKeyPackageCode] = [self.tapDelegate currentPackageCode];
    }
    
    if (self.tapDelegate && [self.tapDelegate respondsToSelector:@selector(currentLanguageCode)] && [self.tapDelegate currentLanguageCode]) {
        userInfo[UISnuffleButtonNotificationButtonTapEventKeyLanguageCode] = [self.tapDelegate currentLanguageCode];
    }
    
    return userInfo;
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	[self reset];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:snuffyViewControllerTouchNotificationTouchesCancelled
														object:self
													  userInfo:@{snuffyViewControllerTouchNotificationTouchesKey:	touches,
																 snuffyViewControllerTouchNotificationEventKey:		event}];
	
}

- (void)reset {
	
	[self setHighlighted:NO];
	
    self.startTouchPosition      = CGPointZero;
    self.startTimeStamp          = 0.0;
    self.lastTouchPosition       = CGPointZero;
    self.lastTimeStamp           = 0.0;
    self.totalHorizontalDistance = 0.0;
    self.horizontalSpeed         = 0.0;
    self.firstMoveOfTouch        = NO;
	
}

@end
