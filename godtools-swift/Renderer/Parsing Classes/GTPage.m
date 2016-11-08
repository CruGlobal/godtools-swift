//
//  GTPage.m
//  Snuffy
//
//  Created by Michael Harrison on 24/06/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "GTPage.h"

#import <math.h>
#import "UIDisclosureIndicator.h"
#import "UISnuffleButton.h"
#import "UISnufflePanel.h"
#import "UIRoundedView.h"
#import "UIRoundedView.h"
#import "UISnuffleButton.h"
#import "TBXML.h"
#import "GTInterpreter.h"
#import "GTFileLoader.h"

NSString * const GTPageNotificationEvent = @"org.cru.godtools.gtviewcontroller.gtpage.notification.event";
NSString * const GTPageNotificationEventKeyEventName = @"org.cru.godtools.gtviewcontroller.gtpage.notification.event.key.eventname";

//////////Compiler Constants///////////
#define CONTENT_PADDING 15
#define BUFFER 10
#define MAX_POPS 3
#define MASK_TAG 111111
#define SHADOW_TAG 222222
#define DROPSHADOW_INSET 10.0
#define ROUNDRECT_RADIUS 20.0
#define	DROPSHADOW_LENGTH 30.0
#define DROPSHADOW_SUBLENGTH 20.0


//////////Run-Time Constants///////////

//button mode constants
extern NSString * const kButtonMode_big;
extern NSString * const kButtonMode_url;
extern NSString * const kButtonMode_allurl;
extern NSString * const kAttr_backgroundImage;
extern NSString * const kAttr_watermark;

@interface GTPage () <GTInterpreterDelegate>

@property (nonatomic, weak)		id<GTPageDelegate>	pageDelegate;
@property (nonatomic, strong)	GTFileLoader *fileLoader;

@property (nonatomic, strong)	NSString			*filename;

@property (nonatomic, strong)	NSMutableDictionary *listeners;

@property (nonatomic, strong)	GTInterpreter		*interpreter;
@property (nonatomic, strong)	TBXML				*xmlRepresentation;
@property (nonatomic, strong)	UIColor				*bgc;
@property (nonatomic, strong)	UIImageView			*watermark;

@property (nonatomic, assign)	BOOL				titleFormattedBySubclass;
@property (nonatomic, assign)	BOOL				shadowAddedBySubclass;

@property (nonatomic, strong)	UILabel				*questionLabel;

@property (nonatomic, strong)	UIView				*titleView;
@property (nonatomic, strong)	UIView				*subTitleView;
@property (nonatomic, strong)	UIView				*panelview;
@property (nonatomic, strong)	UIView				*shadview;
@property (nonatomic, strong)	UIView				*maskview;
@property (nonatomic, strong)	UIButton			*button;
@property (nonatomic, strong)	UILabel				*label;
@property (nonatomic, strong)	UIImageView			*arrowview;

@property	NSInteger activeTag;
@property	NSInteger buttonmax;
@property	BOOL	isanimating;
@property	BOOL	isexpanded;

@property   BOOL	peekPanelIsHidden;

@property	CGRect	buttonoriginal;
@property	CGRect	buttonlarge;
@property	CGRect	contentsframe;
@property	CGRect	shadowbutton;
@property	CGRect	shadowpanel;
@property	CGRect	panelexpanded;
@property	CGRect	arrowvieworiginal;
@property	CGRect	arrowviewlarge;
@property	CGFloat durationMultiplier;

- (void)registerNotificationHandlersForEvents;

- (void)urlClick:(id)sender;
- (void)phoneClick:(id)sender;
- (void)emailClick:(id)sender;
- (void)allUrlClick:(id)sender;

- (void)click:(id)sender;

- (void)showShadow;
- (void)expand:(CAAnimation *)anim finished:(BOOL)flag context:(void *)context;
- (void)animateContentsIn:(CAAnimation *)anim finished:(BOOL)flag context:(void *)context;

- (void)animateContentsOut;
- (void)retract:(CAAnimation *)anim finished:(BOOL)flag context:(void *)context;
- (void)hideShadow:(CAAnimation *)anim finished:(BOOL)flag context:(void *)context;

- (void)animationCleanup:(NSString *)name finished:(BOOL)flag context:(void *)context;

- (void)setButtonBackgroundAfterSlideIn:(CAAnimation *)anim finished:(BOOL)flag context:(void *)context;

- (void)slideInAllLabels;
- (void)slideInWithLabel:(UISnuffleButton *)slidelabel delay:(NSTimeInterval)delay;

- (void)orderShadows;
- (void)peek:(id)sender;
- (void)subTitleShow;
- (void)subTitleHide;
- (void)subTitleAnimCleanup:(CAAnimation *)anim finished:(BOOL)flag context:(void *)context;

@end

@implementation GTPage

#pragma mark -
#pragma mark Initialisation

- (instancetype)initWithFilename:(NSString *)file frame:(CGRect)frame delegate:(id<GTPageDelegate>)delegate fileLoader:(GTFileLoader *)fileLoader {
	
	if ((self = [self initWithFrame:frame])) {
		
        self.listeners = [NSMutableDictionary dictionary];
		
        self.pageDelegate             = delegate;
        self.fileLoader               = fileLoader;

		//strip the file extention from the file name
        self.filename                 = [file stringByReplacingOccurrencesOfString:@".xml" withString:@""];

        self.watermark                = nil;

        self.titleFormattedBySubclass = NO;
        self.shadowAddedBySubclass    = NO;

		//parse xml
        NSString * xmlPath            = [self.fileLoader pathOfFileWithFilename:file];
        self.interpreter              = [GTInterpreter interpreterWithXMLPath:xmlPath fileLoader:self.fileLoader pageView:self delegate:self panelTapDelegate:self buttonTapDelegate:self];

		[self.interpreter renderPage];

        self.durationMultiplier       = 5;

        //set up subTitleView and TitleView
        self.titleView                = [self viewWithTag:560];
        self.subTitleView             = [self viewWithTag:550];
        self.peekPanelIsHidden        = YES;
		[self orderShadows];
	}
	
    return self;
}

- (void)cacheImages {
	
	[self.interpreter cacheImages];
	
}

#pragma mark - event listener methods

- (void)registerNotificationHandlersForEvents {
	
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePageEventWithNotification:)
                                                 name:GTPageNotificationEvent
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveButtonTapEventWithNotification:)
                                                 name:UISnuffleButtonNotificationButtonTapEvent
                                               object:nil];
}

- (void)didReceivePageEventWithNotification:(NSNotification *)notification {
    
    NSString *eventName = notification.userInfo[GTPageNotificationEventKeyEventName];
    [self triggerEventWithName:eventName];
    
}

- (void)didReceiveButtonTapEventWithNotification:(NSNotification *)notification {
    
    NSString *eventName = notification.userInfo[UISnuffleButtonNotificationButtonTapEventKeyEventName];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GTPageNotificationEvent
                                                        object:self
                                                      userInfo:@{GTPageNotificationEventKeyEventName: eventName}];
    
}

- (void)removeNotificationHandlersForEvents {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GTPageNotificationEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UISnuffleButtonNotificationButtonTapEvent object:nil];
    
}

- (void)triggerEventWithName:(NSString *)eventName {
    
    if (eventName && self.listeners[eventName]) {
        
        [self.listeners[eventName] enumerateObjectsUsingBlock:^(NSDictionary *pair, NSUInteger index, BOOL *stop) {
            
            id target = pair[@"target"];
            SEL selector = NSSelectorFromString(pair[@"selector"]);
			id parameter = pair[@"parameter"];
            
            if (parameter) {
                [target performSelector:selector withObject:parameter];
            } else {
                [target performSelector:selector];
            }
		}];
		
    }
}

- (void)registerListenerWithEventName:(NSString *)eventName target:(id)target selector:(SEL)selector parameter:(id)parameter {
	
	target = ( target ? target : self );
    NSDictionary *pair;
    
    if (selector && [target respondsToSelector:selector]) {
        if (parameter) {
            pair = @{@"target": target, @"selector": NSStringFromSelector(selector), @"parameter" : parameter};
        } else {
            pair = @{@"target": target, @"selector": NSStringFromSelector(selector)};
        }
    } else {
        pair = nil;
    }
    
	if (eventName && pair) {
		
		if (self.listeners[eventName]) {
			[self.listeners[eventName] addObject:pair];
		} else {
			self.listeners[eventName] = @[pair].mutableCopy;
		}
		
	}
	
}

- (void)announce {
	NSLog(@"ANNOUNCEMENT!!!!");
}

#pragma mark - Title Animation

- (void)orderShadows {
    //send the shadows to their correct order in the view
    
    //subtitle drop shadows
    //E - 556
    [self bringSubviewToFront:[self viewWithTag:556]];
    //S - 552
    [self bringSubviewToFront:[self viewWithTag:552]];
    //SE - 553
    [self bringSubviewToFront:[self viewWithTag:553]];
    
    //S static - 572
    [self bringSubviewToFront:[self viewWithTag:572]];
    
    //subtitle
    [self bringSubviewToFront:[self viewWithTag:550]];
    
    //title drop shadows
    //E - 566
    [self bringSubviewToFront:[self viewWithTag:566]];
    //S - 562
    [self bringSubviewToFront:[self viewWithTag:562]];
    //SE - 563
    [self bringSubviewToFront:[self viewWithTag:563]];
    
    //SE static - 573
    [self bringSubviewToFront:[self viewWithTag:573]];
    
    //title
    [self bringSubviewToFront:[self viewWithTag:560]];
}

- (void)peek:(id)sender {
	//[self orderShadows];
		//hide the nav bar when a click is detected
	if ([self.pageDelegate respondsToSelector:@selector(hideNavToolbar)]) {
		[self.pageDelegate hideNavToolbar];
	}
	
	if (self.isanimating == NO) {
		self.titleView = [self viewWithTag:560];
		self.subTitleView = [[self viewWithTag:550] viewWithTag:555];
		
		if (self.subTitleView) {
			self.isanimating = YES;
            
			//if (self.subTitleView.frame.origin.y + self.subTitleView.frame.size.height <= (self.titleView.frame.origin.y + self.titleView.frame.size.height + 10)) {
            
            //if subTitleView not visible or peeking
            if (self.peekPanelIsHidden) {
				//NSLog(@"Show Peek Panel");
				self.durationMultiplier = 1;
				[self subTitleShow];
			} else {
				//NSLog(@"Hide Peek Panel");
				[self subTitleHide];
			}
		}
	}
}


- (void)subTitleShow {
    ////put all button elements behind the title
        // //Loop through each element in the view to determine how many buttons there are
	NSInteger max = 0;
	for (UIView *subview in self.subviews) {
		if (subview.tag > 0 && subview.tag < 10) {	//tags of buttons
			if (subview.tag > max) {
				max = subview.tag;	//set maximum
			}
		}
	}
	
	for (NSInteger iterator = 1; iterator <= max; iterator++) {	//loop once for each existing button
		[self sendSubviewToBack:[self viewWithTag:iterator + 30]];
		[self sendSubviewToBack:[self viewWithTag:iterator + 20]];
		[self sendSubviewToBack:[self viewWithTag:iterator]];
		
	}
	[self sendSubviewToBack:[self viewWithTag:890]];	//send the background image to back
	
	self.isexpanded = YES;
    self.peekPanelIsHidden = NO;
	
		//titleView Drop Shadow South (Snap - no animation)
	[[self viewWithTag:562]		setFrame:CGRectMake([self viewWithTag:562].frame.origin.x, 
															[self viewWithTag:562].frame.origin.y, 
															[self viewWithTag:562].frame.size.width, 
															DROPSHADOW_SUBLENGTH
															)];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:(self.durationMultiplier * 0.5)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDidStopSelector:@selector(subTitleAnimCleanup:finished:context:)];
	
	
	[self.subTitleView					setFrame:CGRectMake(CGRectGetMinX(self.subTitleView.frame),
															CGRectGetMaxY(self.titleView.frame) - self.titleView.frame.origin.y - ROUNDRECT_RADIUS, 
															self.subTitleView.frame.size.width, 
															self.subTitleView.frame.size.height
															)];
		//subTitleView Drop Shadow East
	[[self viewWithTag:556]		setFrame:CGRectMake([self viewWithTag:556].frame.origin.x, 
															CGRectGetMaxY(self.titleView.frame) - DROPSHADOW_SUBLENGTH, 
															[self viewWithTag:556].frame.size.width, 
															self.subTitleView.frame.size.height- DROPSHADOW_INSET
															)];
		//subTitleView Drop Shadow SouthEast
	[[self viewWithTag:553]		setFrame:CGRectMake([self viewWithTag:553].frame.origin.x,
                                                            CGRectGetMaxY(self.titleView.frame) + self.subTitleView.frame.size.height - ROUNDRECT_RADIUS - DROPSHADOW_INSET,
															DROPSHADOW_SUBLENGTH,
															DROPSHADOW_SUBLENGTH
															)];
		//subTitleView Drop Shadow South
	[[self viewWithTag:552]		setFrame:CGRectMake([self viewWithTag:552].frame.origin.x,
															CGRectGetMaxY(self.titleView.frame) + self.subTitleView.frame.size.height - ROUNDRECT_RADIUS - DROPSHADOW_INSET,
															[self viewWithTag:552].frame.size.width,
															DROPSHADOW_SUBLENGTH
															)];
	[UIView commitAnimations];
}

- (void)subTitleHide {
	
	self.isexpanded = NO;
    self.peekPanelIsHidden = YES;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:(self.durationMultiplier * 0.4)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDidStopSelector:@selector(subTitleAnimCleanup:finished:context:)];
	
	
	[self.subTitleView					setFrame:CGRectMake(CGRectGetMinX(self.subTitleView.frame), 
															self.titleView.frame.size.height - self.subTitleView.frame.size.height + 10, 
															self.subTitleView.frame.size.width, 
															self.subTitleView.frame.size.height
															)];
		//subTitleView Drop Shadow East
	[[self viewWithTag:556]		setFrame:CGRectMake([self viewWithTag:556].frame.origin.x, 
															CGRectGetMaxY(self.subTitleView.frame) + self.titleView.frame.origin.y - DROPSHADOW_INSET - ROUNDRECT_RADIUS, 
															DROPSHADOW_SUBLENGTH, 
															ROUNDRECT_RADIUS
															)];
		//subTitleView Drop Shadow SouthEast
	[[self viewWithTag:553]		setFrame:CGRectMake([self viewWithTag:553].frame.origin.x,
															self.subTitleView.frame.origin.y + self.subTitleView.frame.size.height + self.titleView.frame.origin.y - DROPSHADOW_INSET, 
															DROPSHADOW_SUBLENGTH,
															DROPSHADOW_SUBLENGTH
															)];
		//subTitleView Drop Shadow South
	[[self viewWithTag:552]		setFrame:CGRectMake([self viewWithTag:552].frame.origin.x,
															CGRectGetMaxY(self.subTitleView.frame) + self.titleView.frame.origin.y - DROPSHADOW_INSET,
															[self viewWithTag:552].frame.size.width,
															DROPSHADOW_SUBLENGTH
															)];
	[UIView commitAnimations];
}

- (void)subTitleAnimCleanup:(CAAnimation *)anim finished:(BOOL)flag context:(void *)context {
	
	if (self.peekPanelIsHidden) {
			//titleView Drop Shadow South
		[[self viewWithTag:562]		setFrame:CGRectMake([self viewWithTag:562].frame.origin.x, 
																[self viewWithTag:562].frame.origin.y, 
																[self viewWithTag:562].frame.size.width, 
																ROUNDRECT_RADIUS
																)];
	}
	self.isanimating = NO;
}

#pragma mark -
#pragma mark Url Interaction Functions

- (void)urlClick:(id)sender {
	
    NSInteger button_tag       = ([sender tag] % 10);
    UISnuffleButton *urlButton = (UISnuffleButton *)[self viewWithTag:button_tag + 110];
    
	if ([self.pageDelegate respondsToSelector:@selector(page:didReceiveTapOnURL:)]) {
		
        NSString *website = ( urlButton.urlTarget ? urlButton.urlTarget : urlButton.currentTitle );
        website           = ( [website hasPrefix:@"http"] ? website : [@"http://" stringByAppendingString:website] );
        NSURL *url        = ( website ? [NSURL URLWithString:website] : nil );
		
		[self.pageDelegate page:self didReceiveTapOnURL:url];
		
	}
	
}

- (void)phoneClick:(id)sender {
	
	UIButton *phoneButton = (UIButton *)sender;
	
	if ([self.pageDelegate respondsToSelector:@selector(page:didReceiveTapOnPhoneNumber:)]) {
		
        NSString *phoneNumber = (phoneButton.currentTitle ? phoneButton.currentTitle : nil );
		
		[self.pageDelegate page:self didReceiveTapOnPhoneNumber:phoneNumber];
		
	}
}

- (void)emailClick:(id)sender {
	
	UIButton *emailButton = (UIButton *)sender;
	
	if ([self.pageDelegate respondsToSelector:@selector(page:didReceiveTapOnEmailAddress:)]) {
		
        NSString *email = (emailButton.currentTitle ? emailButton.currentTitle : nil );
		
		[self.pageDelegate page:self didReceiveTapOnEmailAddress:email];
		
	}
	
}

- (void) allUrlClick:(id)sender {
	
	if ([self.pageDelegate respondsToSelector:@selector(page:didReceiveTapOnAllUrls:)]) {
		
        NSArray *urls = (self.interpreter.arrayWithUrls ? [NSArray arrayWithArray:self.interpreter.arrayWithUrls] : nil );
		
		[self.pageDelegate page:self didReceiveTapOnAllUrls:urls];
		
	}
	
}

#pragma mark - UIRoundedViewTapDelegate & UISnuffleButtonViewTapDelegate

- (CGRect)pageFrame {
	
	return self.frame;
}

- (UIView *)viewOfPageViewController {
	
	return self.pageDelegate.viewOfPageViewController;
}

#pragma mark - UIRoundedViewTapDelegate

- (void)didReceiveTapOnPeekPanel:(UIRoundedView *)peekPanel {
	
	[self peek:peekPanel];
	
}

#pragma mark - UISnuffleButtonViewTapDelegate

- (void)didReceiveTapOnURLButton:(UISnuffleButton *)urlButton {
	
	if ([self.pageDelegate respondsToSelector:@selector(page:didReceiveTapOnURL:)]) {
		
        NSString *website = ( urlButton.urlTarget ? urlButton.urlTarget : urlButton.currentTitle );
        website           = ( [website hasPrefix:@"http"] ? website : [@"http://" stringByAppendingString:website] );
        NSURL *url        = ( website ? [NSURL URLWithString:website] : nil );
		
		[self.pageDelegate page:self didReceiveTapOnURL:url];
		
	}
	
}

- (void)didReceiveTapOnPhoneButton:(UISnuffleButton *)phoneButton {
	
	if ([self.pageDelegate respondsToSelector:@selector(page:didReceiveTapOnPhoneNumber:)]) {
		
        NSString *phoneNumber = (phoneButton.currentTitle ? phoneButton.currentTitle : nil );
		
		[self.pageDelegate page:self didReceiveTapOnPhoneNumber:phoneNumber];
		
	}
	
}

- (void)didReceiveTapOnEmailButton:(UISnuffleButton *)emailButton {
	
	if ([self.pageDelegate respondsToSelector:@selector(page:didReceiveTapOnEmailAddress:)]) {
		
        NSString *email = (emailButton.currentTitle ? emailButton.currentTitle : nil );
		
		[self.pageDelegate page:self didReceiveTapOnEmailAddress:email];
		
	}
	
}

- (void)didReceiveTapOnAllURLButton:(UISnuffleButton *)allURLButton {
	
	if ([self.pageDelegate respondsToSelector:@selector(page:didReceiveTapOnAllUrls:)]) {
		
        NSArray *urls = (self.interpreter.arrayWithUrls ? [NSArray arrayWithArray:self.interpreter.arrayWithUrls] : nil );
		
		[self.pageDelegate page:self didReceiveTapOnAllUrls:urls];
		
	}
	
}

- (void)didReceiveTapOnButton:(UISnuffleButton *)button {
	
	[self click:button];
	
}

- (NSString *)currentPackageCode {
    if (self.pageDelegate && [self.pageDelegate respondsToSelector:@selector(currentPackageCode)]) {
        return [self.pageDelegate currentPackageCode];
    }
    return nil;
}

- (NSString *)currentLanguageCode {
    if (self.pageDelegate && [self.pageDelegate respondsToSelector:@selector(currentLanguageCode)]) {
        return [self.pageDelegate currentLanguageCode];
    }
    return nil;
}

#pragma mark -
#pragma mark Button Interaction Functions


//This is called for the expand animation for the contents of the page and panel which was clicked
- (void)click:(id)sender {
	
	//hide the nav bar when a click is detected
	if ([self.pageDelegate respondsToSelector:@selector(hideNavToolbar)]) {
		[self.pageDelegate hideNavToolbar];
	}
	
	//if subTitleView is visible
	if (self.subTitleView != nil) {
		if (self.subTitleView.frame.origin.y + self.subTitleView.frame.size.height > (self.titleView.frame.origin.y + self.titleView.frame.size.height + 10)) {
			[self peek:nil];
		}
	}
	
	//Logic handles the expanded and retracted statuses
	if ((self.isanimating == NO) && (self.activeTag == 0 || self.activeTag == [sender tag])) {
		
		self.activeTag = [sender tag];
		self.button		= sender;
		//self.buttontext	= (UILabel *)[self viewWithTag:(10 + self.activeTag)];
		self.arrowview	= (UIImageView *)[self viewWithTag:(20 + self.activeTag)];
		self.label		= (UILabel *)[self viewWithTag:(100 + self.activeTag)];
		self.panelview	= (UIView *)[self	viewWithTag:(1000 + self.activeTag)];
		if(self.panelview == nil) {
			//[self addPanelForButtonWithTag:self.activeTag];
			[self.interpreter renderPanelOnPageForButtonTag:self.activeTag];
			self.panelview	= (UIView *)[self	viewWithTag:(1000 + self.activeTag)];
			self.label		= (UILabel *)[self viewWithTag:(100 + self.activeTag)];
		}
		
		//set whether the animation is at normal speed(1), fast(0-1) or slow(>1)
		self.durationMultiplier = 1;
		
		if (self.buttonlarge.size.width == 0.0 || self.buttonlarge.size.height == 0.0) {
			NSInteger paneloffset = fmaxf(0.0, ((self.button.frame.origin.y - 2) + (self.label.frame.size.height + self.button.frame.size.height) + BUFFER) - self.frame.size.height);
			
			//Set up the dimensions
			self.buttonoriginal = CGRectMake(self.button.frame.origin.x,		self.button.frame.origin.y,			self.button.frame.size.width,			self.button.frame.size.height);
			self.buttonlarge	= CGRectMake(self.buttonoriginal.origin.x - 2,	self.buttonoriginal.origin.y - 2 - paneloffset,	self.buttonoriginal.size.width * 1.009 + 3,		self.buttonoriginal.size.height);
			self.contentsframe	= CGRectMake(CONTENT_PADDING - 5,				self.buttonlarge.size.height - 5,	self.label.frame.size.width,			self.label.frame.size.height);
			self.shadowbutton	= CGRectMake(self.buttonlarge.origin.x + 6,		self.buttonlarge.origin.y + 6,		self.buttonlarge.size.width + 0,		self.buttonlarge.size.height + 0);
			self.panelexpanded	= CGRectMake(self.buttonlarge.origin.x,			self.buttonlarge.origin.y,			fmaxf(fminf(self.contentsframe.size.width + 20, self.bounds.size.width -40), self.buttonlarge.size.width),		self.contentsframe.size.height + self.buttonlarge.size.height - 5);
			self.shadowpanel	= CGRectMake(self.panelexpanded.origin.x +		(self.shadowbutton.origin.x -		self.buttonlarge.origin.x),
											 self.panelexpanded.origin.y +		(self.shadowbutton.origin.y -		self.buttonlarge.origin.y),
											 self.panelexpanded.size.width +	(self.shadowbutton.size.width -		self.buttonlarge.size.width),
											 self.panelexpanded.size.height +	(self.shadowbutton.size.height -	self.buttonlarge.size.height));
			self.arrowvieworiginal	= CGRectMake(self.arrowview.frame.origin.x, self.arrowview.frame.origin.y, self.arrowview.frame.size.width, self.arrowview.frame.size.height);
			self.arrowviewlarge		= CGRectMake(self.arrowview.frame.origin.x, 
												 self.buttonlarge.origin.y + (self.arrowview.frame.origin.y - self.buttonoriginal.origin.y), 
												 self.arrowview.frame.size.width, 
												 self.arrowview.frame.size.height);
			self.buttonlarge = CGRectInset(self.buttonlarge, 1, 1);
			//(yes, the tab formatting looks bad here, but leave it alone - it is fine in the console)
			/*
			 //NSLog(@"Object Dimensions:");
			 //NSLog(@"paneloffset:		%i", paneloffset);
			 //NSLog(@"buttonoriginal:	x:%f,	y:%f,	w:%f,	h:%f",		self.buttonoriginal.origin.x,		self.buttonoriginal.origin.y,		self.buttonoriginal.size.width,		self.buttonoriginal.size.height);
			 //NSLog(@"buttonlarge:		x:%f,	y:%f,	w:%f,	h:%f",		self.buttonlarge.origin.x,			self.buttonlarge.origin.y,			self.buttonlarge.size.width,		self.buttonlarge.size.height);
			 //NSLog(@"contentsframe:	x:%f,	y:%f,	w:%f,	h:%f",		self.contentsframe.origin.x,		self.contentsframe.origin.y,		self.contentsframe.size.width,		self.contentsframe.size.height);
			 //NSLog(@"shadowbutton:	x:%f,	y:%f,	w:%f,	h:%f",		self.shadowbutton.origin.x,			self.shadowbutton.origin.y,			self.shadowbutton.size.width,		self.shadowbutton.size.height);
			 //NSLog(@"panelexpanded:	x:%f,	y:%f,	w:%f,	h:%f",		self.panelexpanded.origin.x,		self.panelexpanded.origin.y,		self.panelexpanded.size.width,		self.panelexpanded.size.height);
			 //NSLog(@"shadowpanel:		x:%f,	y:%f,	w:%f,	h:%f",		self.shadowpanel.origin.x,			self.shadowpanel.origin.y,			self.shadowpanel.size.width,		self.shadowpanel.size.height);
			 */
		}
		
		if (self.isexpanded) {	
			[self animateContentsOut];
		} else {
			[self showShadow];
		}
	}
}

- (void)tapAnywhere {
	if (self.activeTag != 0) {
		[self click:(id)[self viewWithTag:self.activeTag]];
	}
	
	if (self.subTitleView && !self.peekPanelIsHidden) {
		//if subTitleView not visible or peeking
		if (!(self.subTitleView.frame.origin.y + self.subTitleView.frame.size.height <= (self.titleView.frame.origin.y + self.titleView.frame.size.height + 10))) {
			[self peek:nil];
		}
	}
}

#pragma mark -
#pragma mark Expand Animation

- (void)showShadow {
	//NSLog(@"showShadow: %i", self.isanimating);
	
	//temp views for shadows
	UIImageView *panelShad_NE = nil;
	UIImageView *panelShad_E = nil;
	UIImageView *panelShad_SE = nil;
	UIImageView *panelShad_S = nil;
	UIImageView *panelShad_SW = nil;
	
	//grab shadow view
	self.shadview	= (UIView *)[self viewWithTag:SHADOW_TAG];
	//NSLog(@"shadview:%@", self.shadview);
	//if shadow view doesn't exist yet create it
	if (self.shadview == nil) {

		self.shadview = [[UIView alloc] initWithFrame:self.buttonoriginal];
		
		//Set up the shadow view for the first time
		[self.shadview			setTag:SHADOW_TAG];
		[self.shadview			setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];//buttonoriginal];
		[self.shadview			setBackgroundColor:[UIColor clearColor]];
		[self.shadview.layer	setMasksToBounds:NO];
		
		//gradiated shadows test
		self.shadview.autoresizesSubviews = YES;
		
		
		/*
		 UIImage *largeimage = [(UIImageView*)([self viewWithTag:890]) image];//[(UIImageView*)([[self subviews] :0]) image]; //[UIImage imageNamed:@"flame"];
		 CGImageRef bgimageref = CGImageCreateWithImageInRect([largeimage CGImage], self.buttonoriginal);
		 UIImageView *bgimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.buttonoriginal.size.width, self.buttonoriginal.size.height)];
		 [bgimage setImage:[UIImage imageWithCGImage:bgimageref]];
		 [[self viewWithTag:self.activeTag] addSubview:bgimage];
		 [[self viewWithTag:self.activeTag] sendSubviewToBack:bgimage];
		 [bgimage release];
		 */
		
		panelShad_NE = [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_NE.png"]];
		panelShad_NE.tag = 549; //'northeast' on numpad
		//panelShad_NE.backgroundColor = [UIColor whiteColor];	//debug
		[self.shadview addSubview:panelShad_NE];
		
		panelShad_E = [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_E.png"]];
		panelShad_E.tag = 546; //'east' on numpad
		//panelShad_E.backgroundColor = [UIColor whiteColor];	//debug
		[self.shadview addSubview:panelShad_E];
		
		panelShad_SE = [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_SE.png"]];
		panelShad_SE.tag = 543; //'southeast' on numpad
		//panelShad_SE.backgroundColor = [UIColor whiteColor];	//debug
		[self.shadview addSubview:panelShad_SE];
		
		panelShad_S = [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_S.png"]];
		panelShad_S.tag = 542; //'south' on numpad
		//panelShad_S.backgroundColor = [UIColor whiteColor];	//debug
		[self.shadview addSubview:panelShad_S];
		
		panelShad_SW = [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_SW.png"]];
		panelShad_SW.tag = 541; //'southwest' on numpad
		//panelShad_SW.backgroundColor = [UIColor whiteColor];	//debug
		[self.shadview addSubview:panelShad_SW];
		
		[self insertSubview:self.shadview belowSubview:self.button];
	}
	
	//grab shadows
	panelShad_NE		= (UIImageView *)[self.shadview viewWithTag:549];
	panelShad_E			= (UIImageView *)[self.shadview viewWithTag:546];
	panelShad_SE		= (UIImageView *)[self.shadview viewWithTag:543];
	panelShad_S			= (UIImageView *)[self.shadview viewWithTag:542];
	panelShad_SW		= (UIImageView *)[self.shadview viewWithTag:541];
	
	//resize shadows
	panelShad_NE.frame	= CGRectMake(CGRectGetMaxX(self.buttonoriginal), CGRectGetMinY(self.buttonoriginal), 0, 10);
	panelShad_E.frame	= CGRectMake(CGRectGetMaxX(self.buttonoriginal), self.buttonoriginal.origin.y + 10, 0, self.buttonoriginal.size.height - 10);
	panelShad_SE.frame	= CGRectMake(CGRectGetMaxX(self.buttonoriginal), CGRectGetMaxY(self.buttonoriginal), 0, 0);
	panelShad_S.frame	= CGRectMake(self.buttonoriginal.origin.x + 10, CGRectGetMaxY(self.buttonoriginal), self.buttonoriginal.size.width - 10, 0);
	panelShad_SW.frame	= CGRectMake(CGRectGetMinX(self.buttonoriginal), CGRectGetMaxY(self.buttonoriginal), 10, 0);
	
	//grab mask view
	self.maskview	= (UIView *)[self viewWithTag:MASK_TAG];
	//if mask view doesn't exist yet create it
	if (self.maskview == nil) {
		self.maskview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		
		//Set up the mask view for the first time
		[self.maskview			setTag:MASK_TAG];
		[self.maskview		setBackgroundColor:[UIColor blackColor]];
		[self.maskview		setAlpha:0.0];
		[self		bringSubviewToFront:self.button];
		[self		insertSubview:self.maskview belowSubview:self.button];
	}
	
	//Set up the mask view
	[self.maskview		setAlpha:0.0];
	[self.maskview		setHidden:NO];
	
	
	//let the page Delegate know the mask is active
	if ([self.pageDelegate respondsToSelector:@selector(setActiveViewMasked:)]) {
		[self.pageDelegate setActiveViewMasked:YES];
	}
	
	//[self.shadview			setFrame:self.buttonoriginal];
	
	//[self				sendSubviewToBack:shadview];
	[self				bringSubviewToFront:self.maskview];
	[self				bringSubviewToFront:self.shadview];
	[self				bringSubviewToFront:self.panelview];
	[self				bringSubviewToFront:self.button];
	[self				bringSubviewToFront:self.arrowview];
	
	//show shadow view
	[self.shadview			setAlpha:0.0];
	[self.shadview			setHidden:NO];
	
	//Toggle the frame status variable
	self.isexpanded = YES;
	
	//Disable interaction while animating
	self.isanimating = YES;
	
	//set up the panelview
	[self.panelview setHidden:NO];
	[self.panelview setAlpha:0.0];
	[self.panelview setFrame:self.buttonoriginal];
	[self.label				setAlpha: 0];	//contents
	//NSLog(@"shadview:%@", self.shadview);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:(self.durationMultiplier * 0.25)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDidStopSelector:@selector(expand:finished:context:)];
	
	//What to animate
	////button position
	[self.button.layer		setFrame:CGRectMake(self.buttonlarge.origin.x + 2, self.buttonlarge.origin.y, self.buttonoriginal.size.width, self.buttonoriginal.size.height)];
	
	////button growth via CGAffineTransformMakeScale
	self.button.transform	= CGAffineTransformMakeScale(1.009, 1.009);
	//NSLog(@"shadView:(%f,%f,%f,%f)\nbuttonlarge:(%f,%f,%f,%f)", self.shadview.frame.origin.x, self.shadview.frame.origin.y, self.shadview.frame.size.width, self.shadview.frame.size.height, self.buttonlarge.origin.x, self.buttonlarge.origin.y, self.buttonlarge.size.width, self.buttonlarge.size.height);
	//shadows
	//NorthEast
	[panelShad_NE setFrame:CGRectMake(CGRectGetMaxX(self.buttonlarge), CGRectGetMinY(self.buttonlarge), 10, 10)];
	//East
	[panelShad_E setFrame:CGRectMake(CGRectGetMaxX(self.buttonlarge), CGRectGetMinY(self.buttonlarge)+10, 10, self.buttonlarge.size.height - 10)];
	//South East
	[panelShad_SE setFrame:CGRectMake(CGRectGetMaxX(self.buttonlarge), CGRectGetMaxY(self.buttonlarge), 10, 10)];
	//South
	[panelShad_S setFrame:CGRectMake(CGRectGetMinX(self.buttonlarge)+10, CGRectGetMaxY(self.buttonlarge), self.buttonlarge.size.width - 10, 10)];	
	//South West
	[panelShad_SW setFrame:CGRectMake(CGRectGetMinX(self.buttonlarge), CGRectGetMaxY(self.buttonlarge), 10, 10)];
	
	////mask
	[self.maskview			setAlpha:0.2];
	
	//shadview
	[self.shadview			setAlpha:1.0];
	
	//panelview
	[self.panelview			setAlpha:1.0];
	[self.panelview			setFrame:self.buttonlarge];
	
	//rotate the arrow down
	self.arrowview.transform = CGAffineTransformMakeRotation(M_PI * -0.5);
	
	//move the arrow
	[self.arrowview			setFrame:self.arrowviewlarge];
	
	//Animate
	[UIView commitAnimations];
	//NSLog(@"showShadow: %i", self.isanimating);
	
}

//Slide the panel down
- (void)expand:(CAAnimation *)anim finished:(BOOL)flag context:(void *)context {
	//NSLog(@"expand: %i", self.isanimating);
	//Set up the panel view
	[self.panelview.layer	setMasksToBounds:YES];
	//[self.panelview.layer	setCornerRadius:10.0];
	//[self.panelview			setHidden:NO];
	//[self.panelview			setAlpha:1.0];
	
	//Apply the start location and dimensions
	//panelview.center = shrunkpoint;
	self.panelview.frame = self.buttonlarge;
	
	
	//Set up the animation
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animateContentsIn:finished:context:)];
	[UIView setAnimationDuration:(self.durationMultiplier * 0.25)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	//What to animate
	////panel
	[self.panelview			setFrame:self.panelexpanded];
	
	//shadows
	//NorthEast
	[[self.shadview viewWithTag:549] setFrame:CGRectMake(CGRectGetMaxX(self.panelexpanded), CGRectGetMinY(self.panelexpanded), 10, 10)];
	//East
	[[self.shadview viewWithTag:546] setFrame:CGRectMake(CGRectGetMaxX(self.panelexpanded), CGRectGetMinY(self.panelexpanded)+10, 10, self.panelexpanded.size.height - 10)];
	//South East
	[[self.shadview viewWithTag:543] setFrame:CGRectMake(CGRectGetMaxX(self.panelexpanded), CGRectGetMaxY(self.panelexpanded), 10, 10)];
	//South
	[[self.shadview viewWithTag:542] setFrame:CGRectMake(CGRectGetMinX(self.panelexpanded)+10, CGRectGetMaxY(self.panelexpanded), self.panelexpanded.size.width - 10, 10)];	
	//South West
	[[self.shadview viewWithTag:541] setFrame:CGRectMake(CGRectGetMinX(self.panelexpanded), CGRectGetMaxY(self.panelexpanded), 10, 10)];
	
	
	//Animate
	[UIView commitAnimations];
	
	//[self.label setCenter:CGPointMake(self.label.center.x, self.label.center.y + self.buttonlarge.size.height)];
	self.label.frame = self.contentsframe;
	//NSLog(@"expand: %i", self.isanimating);
}

//Fades in the panel text
//This is called when the expand animation is stopped
- (void)animateContentsIn:(CAAnimation *)anim finished:(BOOL)flag context:(void *)context {
	//NSLog(@"animateContentsIn: %i", self.isanimating);
	//Set up the animation
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationCleanup:finished:context:)];
	[UIView setAnimationDuration:(self.durationMultiplier * 0.25)];
	
	//What to animate
	[self.label				setAlpha:1.0];
	self.label.transform = CGAffineTransformIdentity;
	
	//Animate
	[UIView commitAnimations];
	//NSLog(@"animateContentsIn: %i", self.isanimating);
}

#pragma mark -
#pragma mark Retract Animation

//Fade the panel text out
- (void)animateContentsOut {
	//NSLog(@"animateContentsOut: %i", self.isanimating);
	//Disable interaction while animating
	self.isanimating = YES;
	
	//Set up the animation
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(retract:finished:context:)];
	[UIView setAnimationDuration:(self.durationMultiplier * 0.25)];
	
	//What to animate
	[self.label				setAlpha:0.0];
	
	//Animate
	[UIView commitAnimations];
	//NSLog(@"animateContentsOut: %i", self.isanimating);
}

//slide the panel up
- (void)retract:(CAAnimation *)anim finished:(BOOL)flag context:(void *)context {
	//NSLog(@"retract: %i", self.isanimating);
	//Set up the animation
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideShadow:finished:context:)];
	[UIView setAnimationDuration:(self.durationMultiplier * 0.25)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	//What to animate
	[self.panelview			setFrame:self.buttonlarge];
	
	//shadows
	//NorthEast
	[[self.shadview viewWithTag:549] setFrame:CGRectMake(CGRectGetMaxX(self.buttonlarge), CGRectGetMinY(self.buttonlarge), 10, 10)];
	//East
	[[self.shadview viewWithTag:546] setFrame:CGRectMake(CGRectGetMaxX(self.buttonlarge), CGRectGetMinY(self.buttonlarge)+10, 10, self.buttonlarge.size.height - 10)];
	//South East
	[[self.shadview viewWithTag:543] setFrame:CGRectMake(CGRectGetMaxX(self.buttonlarge), CGRectGetMaxY(self.buttonlarge), 10, 10)];
	//South
	[[self.shadview viewWithTag:542] setFrame:CGRectMake(CGRectGetMinX(self.buttonlarge)+10, CGRectGetMaxY(self.buttonlarge), self.buttonlarge.size.width - 10, 10)];	
	//South West
	[[self.shadview viewWithTag:541] setFrame:CGRectMake(CGRectGetMinX(self.buttonlarge), CGRectGetMaxY(self.buttonlarge), 10, 10)];
	
	
	//Animate
	[UIView commitAnimations];
	//NSLog(@"retract: %i", self.isanimating);
	
}

- (void)hideShadow:(CAAnimation *)anim finished:(BOOL)flag context:(void *)context {
	//NSLog(@"hideShadow: %i", self.isanimating);
	
	//Toggle the frame status variable
	self.isexpanded = NO;
	
	[UIView beginAnimations:@"hideShadow" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationCleanup:finished:context:)];
	[UIView setAnimationDuration:(self.durationMultiplier * 0.25)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	//What to animate
	////panel
	[self.panelview			setFrame:self.buttonoriginal];
	////button growth
	//[self.button.layer		setFrame:self.buttonoriginal];
	////button growth via CGAffineTransformMakeScale
	self.button.transform	= CGAffineTransformMakeScale(1, 1);
	[self.button.layer		setFrame:self.buttonoriginal];
	////button text growth
	//[self.buttontext.layer	setFrame:self.buttonoriginal];
	
	////shadow
	//NorthEast
	[[self.shadview viewWithTag:549] setFrame:CGRectMake(CGRectGetMaxX(self.buttonoriginal), CGRectGetMinY(self.buttonoriginal), 0, 10)];
	//East
	[[self.shadview viewWithTag:546] setFrame:CGRectMake(CGRectGetMaxX(self.buttonoriginal), CGRectGetMinY(self.buttonoriginal)+10, 0, self.buttonoriginal.size.height - 10)];
	//South East
	[[self.shadview viewWithTag:543] setFrame:CGRectMake(CGRectGetMaxX(self.buttonoriginal), CGRectGetMaxY(self.buttonoriginal), 0, 0)];
	//South
	[[self.shadview viewWithTag:542] setFrame:CGRectMake(CGRectGetMinX(self.buttonoriginal)+10, CGRectGetMaxY(self.buttonoriginal), self.buttonoriginal.size.width - 10, 0)];	
	//South West
	[[self.shadview viewWithTag:541] setFrame:CGRectMake(CGRectGetMinX(self.buttonoriginal), CGRectGetMaxY(self.buttonoriginal), 10, 0)];
	
	[self.shadview			setAlpha:0.0];
	////mask
	[self.maskview			setAlpha:0.0];
    
    [self.panelview         setAlpha:0.0];
	
	//rotate the arrow up
	self.arrowview.transform = CGAffineTransformMakeRotation(0);
	
	//move the arrow
	[self.arrowview			setFrame:self.arrowvieworiginal];
	
	//Animate
	[UIView commitAnimations];
	
	//let the page delegate know the mask is not active
	if ([self.pageDelegate respondsToSelector:@selector(setActiveViewMasked:)]) {
		[self.pageDelegate setActiveViewMasked:NO];
	}
	
	//reset active tag
	self.activeTag = 0;
	
	//NSLog(@"hideShadow: %i", self.isanimating);
}

- (void)animationCleanup:(NSString *)name finished:(BOOL)flag context:(void *)context {
	//NSLog(@"animationCleanup: %i", self.isanimating);
	//Re-enable interaction, now animations are finished
	if (!self.isexpanded) {
		self.buttonlarge	= CGRectZero;
		if ([name isEqualToString:@"hideShadow"]) {
			//[self.maskview removeFromSuperview];
			//[self.shadview removeFromSuperview];
			[self.maskview setHidden:YES];
			[self.shadview setHidden:YES];
			self.maskview = nil;
			self.shadview = nil;
			self.arrowview = nil;
			
			self.button		= nil;
			//self.buttontext	= nil;
			self.label		= nil;
			self.panelview	= nil;
		}
	}
	
	self.isanimating = NO;
	//NSLog(@"animationCleanup: %i", self.isanimating);
}
#pragma mark -
#pragma mark Navigation

- (BOOL)viewWillTransitionWithSwipe:(BOOL)swipe {
	
	//if there is a panel open, close it quickly
	if (self.isexpanded) {
		if (swipe) {
			self.durationMultiplier = 0.05;
			
		} else {
			self.durationMultiplier = 0.5;
		}
		[self click:[self viewWithTag:self.activeTag]];
		[self peek:nil];
		
	}
	else {
		//remove all the animations in the view; pop the elements to their final position so they don't show in the space between the pages
		for (UIView *subview in self.subviews) {
            //              button                    or                urlbutton   
			if ((subview.tag > 0 && subview.tag < 10) || (subview.tag > 110 && subview.tag < 120)) {
				[subview.layer removeAllAnimations];
			}
		}
	}
	self.isanimating = NO;
	
	return YES;
}

- (void)viewWillReturnToCenter {
	
	
}

- (void)viewWillTransitionOut {
	for (id subview in self.subviews) {
		if ([subview class] == [UISnuffleButton class] || [subview class] == [UIRoundedView class]) {
			[subview reset];
		}
	}
}

- (void)viewHasTransitionedIn {
	
    [self registerNotificationHandlersForEvents];
    
	if (self.watermark == nil) {
		self.watermark = self.interpreter.watermark;
		
		if (self.watermark != nil) {
			self.watermark.alpha = 0.0;
			[self insertSubview:self.watermark belowSubview:[self viewWithTag:90]];   //insert the watermark just below the page top shadow
			[self sendSubviewToBack:[self viewWithTag:890]]; //send background image to the back
		}
	}

	if (self.watermark != nil) {
		[UIView	beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDelay:0.5];
		[UIView setAnimationDuration:0.5];
		self.watermark.alpha = 1.0;
		[UIView commitAnimations];
		
	}
	
	[self.interpreter renderButtonsOnPage];
	
	[self slideInAllLabels];

    [self orderShadows];
}

- (void)viewHasTransitionedOut {
	//Prepare the view to be animated in again:
	
    [self removeNotificationHandlersForEvents];
    
	self.isanimating = NO;
	
	self.watermark.alpha = 0.0;
	
////Hide all the elements that have to animate in
    //loop though all elements
	for (UIView *subview in self.subviews) {
        //button components
		if (subview.tag < 10 && subview.tag != 0) {     //tags of buttons
			//hide button
			subview.hidden = YES;
			//hide arrow
			[[self viewWithTag:subview.tag + 20] setHidden:YES];
			//hide lines
			[[self viewWithTag:subview.tag + 30] setHidden:YES];
		}
        
        //urlbuttons
        if (subview.tag > 110 && subview.tag < 120) {   //tags of urlbuttons
            subview.hidden = YES;
        }
        
        //text elements
		if (subview.tag > 800 && subview.tag < 900) {	//tags of text elements
			if (subview.alpha == 1) {
				[subview setAlpha:0.0]; 
			}
		}
	}
	//hide question
	[[self viewWithTag:10] setHidden:YES];
	
	if (self.isexpanded) {
		//reset any expanded stuff
		//[self.buttontext		setFrame:self.buttonoriginal];
		[self.button			setFrame:self.buttonoriginal];
		//[self.shadview			setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		[self.shadview			setAlpha:0.0];
		[self.maskview			setAlpha:0.0];
		[self.arrowview			setTransform:CGAffineTransformMakeRotation(0)];
		[self.arrowview			setFrame:self.arrowvieworiginal];
		
		self.buttonlarge = CGRectZero;
		
		[self.shadview			setHidden:YES];
		[self.maskview			setHidden:YES];
		[self.panelview			setHidden:YES];
		[self setIsexpanded:NO];
		
		self.maskview = nil;
		self.shadview = nil;
	}
}

- (void)viewHasReturnedToCenter {
	
	
}

- (BOOL)viewControllerWillBeReleased {
	if (self.button != nil)		{ [self.button.layer removeAllAnimations]; }
	if (self.label != nil)		{ [self.label.layer removeAllAnimations]; }
	if (self.maskview != nil)	{ [self.maskview.layer removeAllAnimations]; [self.maskview removeFromSuperview]; self.maskview = nil; }
	if (self.shadview != nil)	{ [self.shadview.layer removeAllAnimations]; [self.shadview removeFromSuperview]; self.shadview = nil; }
	if (self.panelview != nil)	{ [self.panelview.layer removeAllAnimations]; }
	
	[self.button setFrame:self.buttonoriginal];
	
	self.button		= nil;
	self.label		= nil;
	self.panelview	= nil;
	self.maskview = nil;
	self.shadview = nil;
	
	return YES;
}

#pragma mark -
#pragma mark Element Slide-In Animation

//Animates all the interactable regions to tell the user where can (and should) be touched
- (void)slideInAllLabels {
	if (!self.isexpanded && !self.isanimating) {
		
		//Loop through each element in the view to determine how many buttons there are
		NSInteger max = 0;
		for (UIView *subview in self.subviews) {
			if (subview.tag > 0 && subview.tag < 10) {	//tags of buttons
				if (subview.tag > max) {
					max = subview.tag;	//set maximum
				}
			}
            if (subview.tag > 110 && subview.tag < 120) { //tags of url buttons
                if ((subview.tag - 110) > max) {
                    max = subview.tag-110;  //set maximum
                }
            }
		}
		
		self.buttonmax = max;
		//self.activeTag = 1;
		//self.isanimating = YES;
		
		CGFloat delay = 0;
		for (NSInteger iterator = 1; iterator <= max; iterator++) {
			[self slideInWithLabel:(UISnuffleButton *)[self viewWithTag:iterator] delay:(NSTimeInterval)delay ];
            [self slideInWithLabel:(UISnuffleButton *)[self viewWithTag:iterator+110] delay:(NSTimeInterval)delay ];
			delay = delay + 0.1;
		}
		
		
		//unhide the question, but hide with alpha
		[[self viewWithTag:10] setAlpha:0.0];
		[[self viewWithTag:10] setHidden:NO];
		
		[UIView beginAnimations:nil context:nil];	
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.5];

		//text fade in
		for (UIView *subview in self.subviews) {
			if (subview.tag > 800 && subview.tag < 900) {	//tags of text elements
				if (subview.alpha == 0) {
					[subview setAlpha:1.0]; 
				}
			}
		}
        
        /*
        //urlbutton fade in
        for (UIView *subview in self.subviews) {
            if (subview.tag > 110 && subview.tag < 120) {   //tags of url buttons (button + 110)
                
            }
        }
        */
		
		//question fade in
		[[self viewWithTag:10] setAlpha:1.0];
		
		[UIView commitAnimations];
		
		
	}
}

//Animates the interactable regions to inform the user where they can touch
- (void)slideInWithLabel:(UISnuffleButton *)slidelabel delay:(NSTimeInterval)delay{
	UIView *arrow = [self viewWithTag:slidelabel.tag + 20];
	UIView *lines = [self viewWithTag:slidelabel.tag + 30];
	[slidelabel setFrame: CGRectMake(0-slidelabel.frame.size.width,
									 slidelabel.frame.origin.y,
									 slidelabel.frame.size.width,
									 slidelabel.frame.size.height)];
	
	//unhide elements, but set opacity to zero
	[slidelabel	setAlpha:0.0];
	slidelabel.hidden		= NO;
	[arrow	setAlpha:0.0];
	arrow.hidden	= NO;
	[lines	setAlpha:0.0];
	lines.hidden	= NO;	
	/*
	 //hide background color for slidein
	 [slidelabel setBackgroundColor:[UIColor clearColor]];
	 [slidelabel setBackgroundImage:nil forState:UIControlStateNormal];
	 */
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelay:delay];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.5];
	//[UIView setAnimationDelegate:self];
	//[UIView setAnimationDidStopSelector:@selector(setButtonBackgroundAfterSlideIn:finished:context:)];
	
	//button slide
	[slidelabel setFrame: CGRectMake(([[slidelabel mode] isEqual:kButtonMode_big] ? 20 : 10),
									 slidelabel.frame.origin.y,
									 slidelabel.frame.size.width,
									 slidelabel.frame.size.height)];
	//button alpha
	[slidelabel setAlpha:1.0];
	[UIView commitAnimations];
	
	//unhide the question, but hide with alpha
	//[[self viewWithTag:10] setAlpha:0.0];
	//[[self viewWithTag:10] setHidden:NO];
	
	
	[UIView beginAnimations:nil context:nil];	
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.5];
	
	//arrow fade in
	[arrow setAlpha:1.0];
	//lines fade in
	[lines setAlpha:1.0];
	//text fade in
	/*
	 for (UIView *subview in self.subviews) {
		 if (subview.tag > 800 && subview.tag < 900) {	//tags of text elements
			 if (subview.alpha == 0) {
				[subview setAlpha:1.0]; 
			 }
		 }
	 }
	 
	
	[[self viewWithTag:10] setAlpha:1.0];
	*/
	[UIView commitAnimations];
	
}

- (void)setButtonBackgroundAfterSlideIn:(CAAnimation *)anim finished:(BOOL)flag context:(void*)context {
	/*
	 UIImage *largeimage = [(UIImageView*)([self viewWithTag:890]) image];//[(UIImageView*)([[self subviews] :0]) image]; //[UIImage imageNamed:@"flame"];
	 CGImageRef bgimageref = CGImageCreateWithImageInRect([largeimage CGImage], [self viewWithTag:self.activeTag].frame);
	 UIImage *bgImage = [UIImage imageWithCGImage:bgimageref];
	 CGImageRelease(bgimageref);
	 [((UIButton*)[self viewWithTag:self.activeTag]) setBackgroundImage:bgImage forState:UIControlStateNormal];
	 [((UIButton*)[self viewWithTag:self.activeTag]) setBackgroundColor:self.backgroundColor];
	 
	 if (self.activeTag == self.buttonmax) {
	 self.activeTag = 0;	//reset activetag
	 //[self sendSubviewToBack:[self viewWithTag:890]];
	 } else {
	 self.activeTag = self.activeTag + 1;
	 }
	 */
	
	//self.isanimating = NO;
	
}


#pragma mark - Followup Modal methods

- (void)presentFollowupModalView:(GTFollowupViewController*)followupViewController {
    if ([self.pageDelegate respondsToSelector:@selector(presentFollowupModal:)]) {
        [self.pageDelegate presentFollowupModal:followupViewController];
    }
}


- (void)transitionFollowupToThankYou {
    if ([self.pageDelegate respondsToSelector:@selector(transitionFollowupToThankYou)]) {
        [self.pageDelegate transitionFollowupToThankYou];
    }
}


- (void)dismissFollowupModal {
    if ([self.pageDelegate respondsToSelector:@selector(dismissFollowupModal)]) {
        [self.pageDelegate dismissFollowupModal];
    }
}


- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}

@end
