//
//  XMLParser.m
//  Snuffy
//
//  Created by Tom Flynn on 8/10/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "GTPageInterpreter.h"

#import "TBXML.h"
#import	"UISnuffleButton.h"
#import	"UISnufflePanel.h"
#import "UIRoundedView.h"
#import	"UIDisclosureIndicator.h"

#import "GTMultiButtonResponseView.h"
#import "GTFollowupViewController.h"
#import "GTFollowupModalView.h"
#import "GTLabel.h"



//////////Run-Time Constants///////////

// Constants for the XML element names that will be considered during the parse.
NSString * const kName_Title			= @"title";
NSString * const kName_TitleNumber		= @"number";
NSString * const kName_TitleHeading		= @"heading";
NSString * const kName_TitleSubHeading	= @"subheading";
NSString * const kName_TitlePeek		= @"peekpanel";
NSString * const kName_Button			= @"button";
NSString * const kName_LinkButton       = @"link-button";
NSString * const kName_ButtonText		= @"buttontext";
NSString * const kName_Label			= @"text";
NSString * const kName_Image			= @"image";
NSString * const kName_Panel			= @"panel";
NSString * const kName_PanelLabel		= @"text";
NSString * const kName_PanelImage		= @"image";
NSString * const kName_Question			= @"question";

// Constants for the follow up modal elements added in v7.0.x of this Pod
NSString * const kName_Button_Pair      = @"button-pair";
NSString * const kName_Positive_Button  = @"positive-button";
NSString * const kName_Negative_Button  = @"negative-button";
NSString * const kName_Followup_Modal   = @"followup-modal";

NSString * const kName_FollowUp_Title       = @"followup-title";
NSString * const kName_FollowUp_Body        = @"followup-body";
NSString * const kName_Input_Field          = @"input-field";
NSString * const kName_Input_Label          = @"input-label";
NSString * const kName_Input_Placeholder    = @"input-placeholder";
NSString * const kName_Thank_You            = @"thank-you";

// Constants for the XML attribute names
NSString * const kAttr_backgroundImage	= @"backgroundimage";
NSString * const kAttr_numOfButtons		= @"buttons";
NSString * const kAttr_numOfBigButtons	= @"bigbuttons";
NSString * const kAttr_mode				= @"mode";
NSString * const kAttr_shadows			= @"shadows";
NSString * const kAttr_watermark		= @"watermark";

NSString * const kAttr_color			= @"color";
NSString * const kAttr_alpha			= @"alpha";
NSString * const kAttr_textalign		= @"textalign";
NSString * const kAttr_align			= @"align";
NSString * const kAttr_size				= @"size";
NSString * const kAttr_x				= @"x";
NSString * const kAttr_y				= @"y";
NSString * const kAttr_width			= @"w";
NSString * const kAttr_height			= @"h";

// Constants for XML attributes for follow up modal, events and listeners added in v7.0.x of this pod
NSString * const kAttr_tap_events		= @"tap-events";
NSString * const kAttr_followup_id      = @"followup-id";
NSString * const kAttr_context_id       = @"context-id";
extern NSString * const kAttr_listeners;
NSString * const kAttr_type             = @"type";
NSString * const kAttr_validation       = @"validation";
NSString * const kAttr_validFormat      = @"valid-format";
NSString * const kAttr_name             = @"name";

NSString * const kAttr_yoff				= @"yoffset";
NSString * const kAttr_xoff				= @"xoffset";
NSString * const kAttr_xTrailingOff     = @"x-trailing-offset";
NSString * const kAttr_modifier			= @"modifier";

NSString * const kAttr_urlText          = @"label";

//text alignment constants
NSString * const kAlignment_left		= @"left";//default
NSString * const kAlignment_center		= @"center";
NSString * const kAlignment_right		= @"right";

//title mode constants
NSString * const kTitleMode_plain		= @"plain";
NSString * const kTitleMode_singlecurve	= @"single";
NSString * const kTitleMode_doublecurve	= @"double";//default
NSString * const kTitleMode_straight	= @"straight";
NSString * const kTitleMode_clear		= @"clear";

//title mode constants
NSString * const kTitleMode_peek		= @"peek";

//button mode constants
NSString * const kButtonMode_big		= @"big";
NSString * const kButtonMode_url		= @"url";
NSString * const kButtonMode_phone		= @"phone";
NSString * const kButtonMode_email		= @"email";
NSString * const kButtonMode_allurl		= @"allurl";
NSString * const kButtonMode_link       = @"link";

//label modifer constants
NSString * const kLabelModifer_normal	= @"normal";
NSString * const kLabelModifer_bold		= @"bold";
NSString * const kLabelModifer_italics	= @"italics";
NSString * const kLabelModifer_bolditalics	= @"bold-italics";

NSString * const kInputFieldType_email  = @"email";
NSString * const kInputFieldType_text   = @"text";

@interface GTPageInterpreter ()

@property (nonatomic, strong)	GTFileLoader	*fileLoader;
@property (nonatomic, strong)	GTPageStyle		*pageStyle;

@property (nonatomic, strong)	TBXML			*xmlRepresentation;
@property (nonatomic, assign)	TBXMLElement	*pageElement;

@property (nonatomic, assign)	BOOL			pageElementsHaveBeenParsed;
@property (nonatomic, assign)	BOOL			buttonElementsHaveBeenParsed;

@property (nonatomic, strong)	UIView			*pageView;
@property (nonatomic, assign)	CGRect			titleFrame;
@property (nonatomic, assign)	CGRect			questionFrame;

//object creation functions (take an xml element return an iphone interface object, ie a subclass of UIView)
- (id)createButtonLinesFromButtonElement:		(TBXMLElement *)element		buttonTag:(NSInteger)buttonTag	yPos:(CGFloat)yPos		container:(UIView *)container;
- (id)createDisclosureIndicatorFromButtonTag:	(NSInteger)buttonTag		container:(UIView *)container;
- (id)createImageFromElement:					(TBXMLElement *)element		xPos:(CGFloat)xpostion			yPos:(CGFloat)ypostion	container:(UIView *)container;
- (id)createPanelFromElement:					(TBXMLElement *)element		buttonTag:(NSInteger)buttonTag	container:(UIView *)container;
- (id)createQuestionFromElement:				(TBXMLElement *)element		container:(UIView *)container;
- (id)createQuestionLabelFromElement:			(TBXMLElement *)element		container:(UIView *)container;
- (id)createTitleFromElement:					(TBXMLElement *)element		container:(UIView *)container;
- (id)createSubTitleFromElement:				(TBXMLElement *)element		underTitle:(UIView *)titleView;
- (id)createTitleNumberFromElement:				(TBXMLElement *)element		titleMode:(NSString *)titleMode containerFrame:(CGRect)containerFrame;
- (id)createTitleHeadingFromElement:			(TBXMLElement *)element		titleMode:(NSString *)titleMode containerFrame:(CGRect)containerFrame;
- (id)createTitleSubheadingFromElement:			(TBXMLElement *)element		titleMode:(NSString *)titleMode containerFrame:(CGRect)containerFrame;

@end


@implementation GTPageInterpreter

- (instancetype)initWithXMLPath:(NSString *)xmlPath fileLoader:(GTFileLoader *)fileLoader pageStyle:(GTPageStyle *)pageStyle pageView:(UIView *)view delegate:(id<GTInterpreterDelegate>)delegate panelTapDelegate:(id<UIRoundedViewTapDelegate>)panelDelegate buttonTapDelegate:(id<UISnuffleButtonTapDelegate>)buttonDelegate {
	
	self = [self init];
	if (self) {
		
		self.fileLoader			= fileLoader;
		self.pageStyle			= pageStyle;
		self.delegate			= delegate;
		self.panelDelegate		= panelDelegate;
		self.buttonDelegate		= buttonDelegate;
		
		//parse and store xml
		NSData *data			= [NSData dataWithContentsOfFile:xmlPath];
		self.xmlRepresentation	= [[TBXML alloc] initWithXMLData:data error:nil];
		
		//holds a reference to the view that will hold this page
		self.pageView			= view;
		
		//holds a ref to the page element
		self.pageElement		= self.xmlRepresentation.rootXMLElement;
		
		//holds a ref to the background colour
		self.pageStyle.backgroundColor	= [GTPageStyle colorForHex:[TBXML valueOfAttributeNamed:kAttr_color forElement:self.pageElement]];
		
		//add background image if attribute is set
		if ([TBXML valueOfAttributeNamed:kAttr_backgroundImage forElement:self.pageElement]) {
			
			UIImageView *bgimage	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:[TBXML valueOfAttributeNamed:kAttr_backgroundImage forElement:self.pageElement]]];
			[bgimage setTag:900];
			[bgimage setFrame:[self.pageView frame]];
			[self.pageView insertSubview:bgimage atIndex:0];
		}
		
		//init flags
		self.pageElementsHaveBeenParsed		= NO;
		self.buttonElementsHaveBeenParsed	= NO;
		
	}
	
	return self;
}

- (CGRect)pageFrame {
	
	return self.pageView.frame;
}

-(NSMutableArray *)arrayWithUrls {
	TBXMLElement	*button_el		= [TBXML childElementNamed:kName_Button parentElement:self.pageElement];
	TBXMLElement	*savedButton_el	= nil;
	BOOL			moveToNextSibling= false;
	NSString		*button_mode	= nil;
	TBXMLElement	*urlbutton_el	= nil;
	NSMutableArray	*urlArray		= [NSMutableArray array];
	NSMutableDictionary	*urlDict	= nil;
	
	while (true) {
		
		if (button_el == nil) {
			if (savedButton_el != nil) {
				
				button_el		= [TBXML nextSiblingNamed:kName_Button searchFromElement:savedButton_el];
				savedButton_el	= nil;
				
				if (button_el == nil) {
					break;
				}
				
			} else {
				break;
			}
		}
		
		button_mode	= [TBXML valueOfAttributeNamed:kAttr_mode forElement:button_el];
		
		if (button_mode == nil) {
			savedButton_el	= button_el;
			button_el		= [TBXML childElementNamed:kName_Button parentElement:[TBXML childElementNamed:kName_Panel parentElement:button_el]];
			moveToNextSibling= false;
			urlbutton_el	= nil;
		} else if ([button_mode isEqual:kButtonMode_url]) {
			urlbutton_el	= button_el;
		} else {
			urlbutton_el	= nil;
		}
		
		if (urlbutton_el != nil) {
			
			urlDict = [NSMutableDictionary dictionary];
			
			if ([TBXML valueOfAttributeNamed:kAttr_urlText forElement:urlbutton_el] == nil) {
				[urlDict setObject:[TBXML textForElement:urlbutton_el] forKey:@"title"];
				[urlDict setObject:[TBXML textForElement:urlbutton_el] forKey:@"url"];
			} else {
				[urlDict setObject:[TBXML valueOfAttributeNamed:kAttr_urlText forElement:urlbutton_el] forKey:@"title"];
				[urlDict setObject:[TBXML textForElement:urlbutton_el] forKey:@"url"];
			}
			
			[urlArray addObject:urlDict];
			
		}
		
		if (moveToNextSibling) {
			button_el	= [TBXML nextSiblingNamed:kName_Button searchFromElement:button_el];
		}
		
		moveToNextSibling = true;
	}
	
	return urlArray;
}

#pragma mark -
#pragma mark Parser Functions

/**
 * Description: Identify all the page elements except buttons, call their 'create' functions and add them to the page's view
 */
- (void)renderPage {
	
	if (self.pageElement && !self.pageElementsHaveBeenParsed) {
		
		//init xml elements for interpretation
		TBXMLElement	*title_el			= [TBXML childElementNamed:kName_Title parentElement:self.pageElement];
		TBXMLElement	*question_el		= [TBXML childElementNamed:kName_Question parentElement:self.pageElement];
		TBXMLElement	*second_question_el	= nil;
		if (question_el != nil) {
			second_question_el				= [TBXML nextSiblingNamed:kName_Question searchFromElement:question_el];
		}
		
		//init objects that will be used to add interpreted elements to the page
		UIView			*titleView			= nil;
		UIRoundedView	*subTitleView		= nil;
        UIView          *subTitleContainer  = nil;
		UILabel			*questionLabel		= nil;
		UILabel			*secondQuestionLabel= nil;
		UIImageView		*questionShadowTop	= nil;
		UIImageView		*questionShadowBot	= nil;
		UIImageView		*question2ShadowTop	= nil;
		UIImageView		*question2ShadowBot	= nil;
		
		//grab page shadow mode
		NSString		*shadows			= [TBXML valueOfAttributeNamed:kAttr_shadows forElement:self.pageElement];
		//grab title mode
		NSString		*mode				= nil;
		
		//add shadows if the user wants them
		if (shadows == nil || [shadows isEqual:@"yes"]) {
			////Add a gradiated shadow to the top and bottom of the page
			//Create the imageviews
			UIImageView *grad_shad_top	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_top.png"]];
			UIImageView *grad_shad_bot	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_bot.png"]];
			
			//Set the imageview properties
			[grad_shad_top	setFrame:CGRectMake(CGRectGetMinX(self.pageView.frame),		CGRectGetMinY(self.pageView.frame),			self.pageView.frame.size.width,	30)];
			[grad_shad_bot	setFrame:CGRectMake(CGRectGetMinX(self.pageView.frame),		CGRectGetMaxY(self.pageView.frame) - 30,	self.pageView.frame.size.width,	30)];
			
            [grad_shad_top setTag:90];
            [grad_shad_bot setTag:91];
            
			//Insert the imageviews into the main view
			[self.pageView addSubview:grad_shad_top];
			[self.pageView addSubview:grad_shad_bot];
			
			//Put the shadow behind everything else
			//IMPORTANT: if at any other point, sendSubviewToBack is called, it will put it behind these, which may not be desirable

		}
		
		//set background color
		[self.pageView setBackgroundColor:self.pageStyle.backgroundColor];
		
		//create title from xml element
		if (title_el) {
			titleView		= [self createTitleFromElement:title_el container:self.pageView];
			mode			= [TBXML valueOfAttributeNamed:kAttr_mode forElement:title_el];
			self.titleFrame = titleView.frame;
			subTitleView	= [self createSubTitleFromElement:title_el underTitle:titleView];
            
            //create a container view to clip the peek panel above the title
            subTitleContainer = [[UIView alloc] initWithFrame:  CGRectMake(self.titleFrame.origin.x, self.titleFrame.origin.y,    subTitleView.frame.size.width,  self.pageView.frame.size.height)];   //container in page
            [subTitleContainer setTag:550];         //make the container accessible in the page
            [subTitleView setTag:555];                //make the peek panel accessible in the container
            subTitleContainer.clipsToBounds = YES;  //clip the contents
            subTitleContainer.userInteractionEnabled = NO;
            
            //set the title mode flags to peek
			if (subTitleView != nil && [subTitleView.titleMode isEqual:kTitleMode_peek]) {
				mode=kTitleMode_peek;
				((UIRoundedView *)(titleView)).titleMode = kTitleMode_peek;
			}
				
		} else {
			self.titleFrame = CGRectMake(0, 20, self.pageView.frame.size.width, 20);
		}
		
		//Add the subtitle (peekpanel) to the pageview
		if (subTitleView){
            
            //add the peek panel to the container
            [subTitleContainer addSubview:subTitleView];
            //add the container to the page
            [self.pageView insertSubview:subTitleContainer belowSubview:titleView];
            
            //[self.pageView addSubview:subTitleView];
            
///TODO: use send rather than insert
            
            [self.pageView insertSubview:[self.pageView viewWithTag:90] atIndex:0];           //put the top shadow to back
            [self.pageView insertSubview:[self.pageView viewWithTag:91] atIndex:0];           //put the bottom shadow to back
        }
		
				
		//create question from xml element
		if (question_el) {
			questionLabel = [self createQuestionFromElement:question_el container:nil];
			self.questionFrame = questionLabel.frame;
			
			//add shadows if its mode is straight
			if ([[TBXML valueOfAttributeNamed:kAttr_mode forElement:question_el] isEqual:kTitleMode_straight]) {
				//Create the imageviews
				questionShadowTop	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_bot.png"]];
				questionShadowBot	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_top.png"]];
				
				//Set the imageview properties
				[questionShadowTop	setFrame:CGRectMake(CGRectGetMinX(self.questionFrame),		CGRectGetMinY(self.questionFrame) - 10,		self.questionFrame.size.width,	30)];
				[questionShadowBot	setFrame:CGRectMake(CGRectGetMinX(self.questionFrame),		CGRectGetMaxY(self.questionFrame) - 5,		self.questionFrame.size.width,	30)];
			}
		} else {
			//self.questionFrame		= CGRectMake(10, self.pageView.frame.size.height - 30, 300, 10);
		}
		
		
		//create question from xml element
		if (second_question_el) {
			secondQuestionLabel		= [self createQuestionFromElement:second_question_el container:nil];
			
			//add shadows if its mode is straight
			if ([[TBXML valueOfAttributeNamed:kAttr_mode forElement:second_question_el] isEqual:kTitleMode_straight]) {
				//Create the imageviews
				question2ShadowTop	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_bot.png"]];
				question2ShadowBot	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_top.png"]];
				
				CGRect qframe = secondQuestionLabel.frame;
				
				//Set the imageview properties
				[question2ShadowTop	setFrame:CGRectMake(CGRectGetMinX(qframe),		CGRectGetMinY(qframe) - 10,		qframe.size.width,	30)];
				[question2ShadowBot	setFrame:CGRectMake(CGRectGetMinX(qframe),		CGRectGetMaxY(qframe) - 5,		qframe.size.width,	30)];
			} else {
				//destroy the second question if it is not a straight question
				secondQuestionLabel = nil;
			}
			
		}
		
		//Add the shadows to the title based on the title mode
		if ([mode isEqual:kTitleMode_doublecurve] || mode == nil) {
			////Add a gradiated shadow to the title
			//Create the imageviews
			UIImageView *grad_shad_NE	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_NE.png"]];
			UIImageView *grad_shad_E	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_E.png"]];
			UIImageView *grad_shad_SE	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_SE.png"]];
			UIImageView *grad_shad_S	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_S.png"]];
			
			//Set the imageview properties
			[grad_shad_NE	setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - 10, 
												titleView.frame.origin.y, 
												30.0, 
												30.0 )];
			
			[grad_shad_E	setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - 10, 
												grad_shad_NE.frame.origin.y		+ grad_shad_NE.frame.size.height, 
												30.0, 
												titleView.frame.size.height - grad_shad_NE.frame.size.height - 10 )];
			
			[grad_shad_SE	setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - 10, 
												titleView.frame.origin.y + titleView.frame.size.height - 10, 
												30.0, 
												30.0 )];
			
			[grad_shad_S	setFrame:CGRectMake(titleView.frame.origin.x, 
												grad_shad_SE.frame.origin.y, 
												titleView.frame.size.width - 10, 
												30.0 )];
			
			//Insert the imageviews into the main view
			[self.pageView insertSubview:grad_shad_NE	belowSubview:titleView];
			[self.pageView insertSubview:grad_shad_E	belowSubview:titleView];
			[self.pageView insertSubview:grad_shad_SE	belowSubview:titleView];
			[self.pageView insertSubview:grad_shad_S	belowSubview:titleView];
			
		} else if ([mode isEqual:kTitleMode_singlecurve]) {
			////Add a gradiated shadow to the title
			//Create the imageviews
			UIImageView *grad_shad_NE	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_NE.png"]];
			UIImageView *grad_shad_E	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_E.png"]];
			UIImageView *grad_shad_SE	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_SE.png"]];
			UIImageView *grad_shad_S	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_S.png"]];
			
			//Set the imageview properties
			[grad_shad_NE	setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - 10, 
												titleView.frame.origin.y, 
												30.0, 
												30.0 )];
			
			[grad_shad_E	setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - 10, 
												grad_shad_NE.frame.origin.y		+ grad_shad_NE.frame.size.height, 
												30.0, 
												titleView.frame.size.height - grad_shad_NE.frame.size.height - 10 )];
			
			[grad_shad_SE	setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - 10, 
												titleView.frame.origin.y + titleView.frame.size.height - 10, 
												30.0, 
												30.0 )];
			
			[grad_shad_S	setFrame:CGRectMake(titleView.frame.origin.x, 
												titleView.frame.origin.y + titleView.frame.size.height - 10, 
												titleView.frame.size.width - 10, 
												30.0 )];
			
			//Insert the imageviews into the main view
			[self.pageView insertSubview:grad_shad_NE	belowSubview:titleView];
			[self.pageView insertSubview:grad_shad_E	belowSubview:titleView];
			[self.pageView insertSubview:grad_shad_SE	belowSubview:titleView];
			[self.pageView insertSubview:grad_shad_S	belowSubview:titleView];
			
		} else if ([mode isEqual:kTitleMode_straight]) {
			////Add a gradiated shadow to the top and bottom of the title
			//Create the imageviews
			UIImageView *title_grad_shad_top	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_bot.png"]];
			UIImageView *title_grad_shad_bot	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_top.png"]];
			
			//Set the imageview properties
			[title_grad_shad_top	setFrame:CGRectMake(CGRectGetMinX(titleView.frame),		CGRectGetMinY(titleView.frame) + 10,		titleView.frame.size.width,	30)];
			[title_grad_shad_bot	setFrame:CGRectMake(CGRectGetMinX(titleView.frame),		CGRectGetMaxY(titleView.frame) - 10,		titleView.frame.size.width,	30)];
			
			//Insert the imageviews into the main view
			[self.pageView insertSubview:title_grad_shad_top belowSubview:titleView];
			[self.pageView insertSubview:title_grad_shad_bot belowSubview:titleView];
			
		} else if ([mode isEqual:kTitleMode_peek]) {
			
			
			////Add a gradiated shadow to the title
			//Create the imageviews
			UIImageView *grad_shad_NE_title		= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_NE.png"]];
			UIImageView *grad_shad_E			= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_E.png"]];
			UIImageView *grad_shad_E_title		= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_E.png"]];
			UIImageView *grad_shad_SE			= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_SE.png"]];
			UIImageView *grad_shad_SE_title		= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_SE.png"]];
			UIImageView *grad_shad_SE_static	= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_SE.png"]];
			UIImageView *grad_shad_S			= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_S.png"]];
			UIImageView *grad_shad_S_title		= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_S.png"]];
			UIImageView *grad_shad_S_static		= [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"grad_shad_S.png"]];
			
			//Set the imageview properties
			[grad_shad_NE_title		setFrame:CGRectMake(titleView.frame.size.width - DROPSHADOW_INSET, 
														titleView.frame.origin.y, 
														DROPSHADOW_LENGTH, 
														DROPSHADOW_LENGTH 
														)];
			
			[grad_shad_E			setFrame:CGRectMake(subTitleView.frame.size.width - DROPSHADOW_INSET, 
														titleView.frame.size.height - (ROUNDRECT_RADIUS * 2), 
														DROPSHADOW_SUBLENGTH, 
														(ROUNDRECT_RADIUS * 2)
														)];
			
			[grad_shad_E_title		setFrame:CGRectMake(titleView.frame.size.width - DROPSHADOW_INSET, 
														titleView.frame.origin.y + (subTitleView ? DROPSHADOW_LENGTH : 0), 
														DROPSHADOW_LENGTH, 
														titleView.frame.size.height - DROPSHADOW_INSET - (subTitleView ? DROPSHADOW_LENGTH : 0)
														)];
			
			[grad_shad_SE			setFrame:CGRectMake(subTitleView.frame.size.width - DROPSHADOW_INSET, 
														subTitleView.frame.origin.y + subTitleView.frame.size.height - DROPSHADOW_INSET, 
														DROPSHADOW_SUBLENGTH, 
														DROPSHADOW_SUBLENGTH 
														)];
			
			[grad_shad_SE_title		setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - DROPSHADOW_INSET, 
														titleView.frame.origin.y + titleView.frame.size.height - DROPSHADOW_INSET, 
														DROPSHADOW_LENGTH, 
														DROPSHADOW_LENGTH 
														)];
			
			[grad_shad_SE_static	setFrame:CGRectMake(titleView.frame.origin.x + titleView.frame.size.width - DROPSHADOW_SUBLENGTH, 
														titleView.frame.origin.y + titleView.frame.size.height - DROPSHADOW_INSET, 
														(ROUNDRECT_RADIUS * 2), 
														(ROUNDRECT_RADIUS * 2) 
														)];
			
			[grad_shad_S			setFrame:CGRectMake(subTitleView.frame.origin.x, 
														subTitleView.frame.origin.y + subTitleView.frame.size.height - DROPSHADOW_INSET, 
														subTitleView.frame.size.width - DROPSHADOW_INSET, 
														DROPSHADOW_SUBLENGTH 
														)];
			
			[grad_shad_S_title		setFrame:CGRectMake(titleView.frame.origin.x, 
														titleView.frame.origin.y + titleView.frame.size.height - DROPSHADOW_INSET, 
														titleView.frame.size.width - (subTitleView ? DROPSHADOW_SUBLENGTH : DROPSHADOW_INSET), 
														(subTitleView ? (ROUNDRECT_RADIUS * 2): DROPSHADOW_LENGTH) 
														)];
			
			[grad_shad_S_static		setFrame:CGRectMake(titleView.frame.origin.x, 
														titleView.frame.origin.y + titleView.frame.size.height - DROPSHADOW_INSET, 
														titleView.frame.size.width - DROPSHADOW_INSET, 
														DROPSHADOW_LENGTH 
														)];
			
			//adds tags to the shadows for later reference (550/560  + numpad location)
			[grad_shad_E            setTag:556];
			[grad_shad_E_title      setTag:566];
			[grad_shad_S            setTag:552];
			[grad_shad_S_title      setTag:562];
			[grad_shad_S_static     setTag:572];
            [grad_shad_SE           setTag:553];
			[grad_shad_SE_title     setTag:563];
            [grad_shad_SE_static    setTag:573];
			
			//Insert the imageviews into the main view
			if(subTitleView){	[self.pageView insertSubview:grad_shad_NE_title		belowSubview:titleView];}
			if(subTitleView){	[self.pageView insertSubview:grad_shad_E			belowSubview:subTitleView];}
								[self.pageView insertSubview:grad_shad_E_title		belowSubview:titleView];
			if(subTitleView){	[self.pageView insertSubview:grad_shad_SE			belowSubview:subTitleView];}
								[self.pageView insertSubview:grad_shad_SE_title		belowSubview:titleView];
			if(subTitleView){	[self.pageView insertSubview:grad_shad_SE_static	belowSubview:titleView];}
			if(subTitleView){	[self.pageView insertSubview:grad_shad_S			belowSubview:subTitleView];}
								[self.pageView insertSubview:grad_shad_S_title		belowSubview:titleView];		
			if(subTitleView){	[self.pageView insertSubview:grad_shad_S_static		belowSubview:subTitleView];}
			
		}
		
		//add the question and the title to the pages view
		if (titleView)					{[self.pageView addSubview:titleView];}
		//moved up: if (subTitleView)				{[self.pageView addSubview:subTitleView];}
		if (questionLabel)				{[self.pageView insertSubview:questionLabel aboveSubview:titleView];}
		if (secondQuestionLabel)		{[self.pageView insertSubview:secondQuestionLabel aboveSubview:titleView];}
		
		//add question shadows if they are there (ie mode="straight" for the question tag)
		if (questionShadowTop != nil) {
			[self.pageView insertSubview:questionShadowTop belowSubview:questionLabel];
			[self.pageView insertSubview:questionShadowBot belowSubview:questionLabel];
		}
		
		//add question shadows if they are there (ie mode="straight" for the question tag)
		if (question2ShadowTop != nil) {
			[self.pageView insertSubview:question2ShadowTop belowSubview:secondQuestionLabel];
			[self.pageView insertSubview:question2ShadowBot belowSubview:secondQuestionLabel];
		}
		
		//set flag
		self.pageElementsHaveBeenParsed = YES;
	} else {
		//throw exception if pre requiste functions have not been called
		if (!self.pageElement) {
			NSException* parseException = [NSException exceptionWithName:[self.fileLoader localizedString:@"GTPageInterpreter_parseException_name"]
																  reason:[self.fileLoader localizedString:@"GTPageInterpreter_parseException_message"]
																userInfo:nil];
			@throw parseException;
		}
	}
	
}

/**
 * Description: Identify all the objects on the page, call their 'create' functions and add them to the page's view
 */
- (void)renderButtonsOnPage {
    
	if (self.pageElement && self.pageElementsHaveBeenParsed && !self.buttonElementsHaveBeenParsed) {
		
        //NSMutableArray      *pageObjects        = [NSMutableArray alloc];
        
		//init xml elements for interpretation
		TBXMLElement		*object_el			= self.pageElement->firstChild;
		
		//init variables for xml attributes
		NSString			*button_mode		= nil;
		
		//init objects that will be used to add interpreted elements to the page
		UIImageView			*buttonLinesTemp	= nil;
		UISnuffleButton		*buttonTemp			= nil;
		UIDisclosureIndicator *arrowTemp		= nil;
        
		UILabel             *labelLabel			= nil;
		UIImageView         *imageImage			= nil;
		
		//init variables used to hold element attribute values
		NSInteger			numOfButtons		= 0;
		NSInteger			numOfBigButtons		= 0;
        NSInteger           numOfTextLabels     = 0;
        CGFloat             combinedHeightOfTextLabels = 0;
        NSInteger           numOfImages         = 0;
		
        //NSLog(@"\nObject CountLoop:");
        
    ////////////////////////////////////////////////////////
    ////First loop for counting of objects for placement////
    ////////////////////////////////////////////////////////
        
        //Loop through all objects in the page
        while (object_el != nil) {
            //NSLog(@"%@", [TBXML elementName:object_el]);
            
            NSString *elementName = [TBXML elementName:object_el];
        ////title
            if([elementName isEqual:kName_Title]) {
                //title creation is not handled here
            }
            
            ////button
            if ([elementName isEqual:kName_Button]) {
                //get the button mode
                button_mode		= [TBXML valueOfAttributeNamed:kAttr_mode forElement:object_el];
                if ([button_mode isEqual:kButtonMode_big]) {
                    numOfBigButtons++;
                } else {
                    numOfButtons++;
                }
            }
            
        ////text label
            if ([elementName isEqual:kName_Label]) {
                numOfTextLabels++;
                
                //note: because of the unpredictable height of text labels, we need to calculate their combined height

                //create a temporary text label and add it's height to the tally
                labelLabel = [[GTLabel alloc] initWithElement:object_el
                                                 parentTextAlignment:NSTextAlignmentLeft
                                                                xPos:0
                                                                yPos:0
                                                           container:self.pageView
                                                               style:self.pageStyle];
                
                combinedHeightOfTextLabels += fmaxf(labelLabel.frame.size.height,40);
                
            }
            
        ////image
            if ([elementName isEqual:kName_Image]) {
                numOfImages++;
            }
            
            object_el = object_el->nextSibling;
        }
        //NSLog(@"\nCountLoop found:\n %ld regular buttons,\n %ld big buttons,\n %ld text labels,\n %ld images", (long)numOfButtons, (long)numOfBigButtons, (long)numOfTextLabels, (long)numOfImages);
        
        
    ///////////////////////////////////
    //Second loop for object creation//
    ///////////////////////////////////
        
		//init variables for button placment
		CGFloat				spaceBetweenObjects;
		CGFloat				previousObjectYMax;
        NSInteger           buttonCount         = 1;
        NSInteger           labelCount          = 1;
        NSInteger           object_ypos         = 0;
        NSInteger           object_xpos         = 0;
        
        //reset object_el to the first object
        object_el = self.pageElement->firstChild;//[TBXML childElementNamed:kName_Button parentElement:self.pageElement];
		

        //////////////////////
        ////Object Spacing////
        //////////////////////
        
        //calculate the top limit for objects to be spaced - bottom of the title, with extra if there is a peek panel
        NSInteger topOfPageSpace = ([TBXML childElementNamed:kName_TitlePeek parentElement:object_el] ? CGRectGetMaxY(self.titleFrame) + ROUNDRECT_RADIUS : CGRectGetMaxY(self.titleFrame));
        //NSLog(@"topOfPageSpace = %ld", (long)topOfPageSpace);
        
        //calculate the bottom limit for objects to be spaced - top of question if it exists, or bottom of page if it doesn't
        NSInteger bottomOfPageSpace = ([TBXML childElementNamed:kName_Question parentElement:self.pageElement] ? CGRectGetMinY(self.questionFrame) : CGRectGetHeight(self.pageView.frame));
        //NSLog(@"bottomOfPageSpace = %ld", (long)bottomOfPageSpace);
        
        spaceBetweenObjects = round(((       bottomOfPageSpace                          // top of question/bottom of page
                                             - topOfPageSpace)                          // bottom of title
											 - (numOfButtons * 40)						// combined height of normal buttons
											 - (numOfBigButtons * 140)					// combined height of big buttons
                                             - combinedHeightOfTextLabels               // combined height of text labels (assuming single line of text)
                                             - (numOfImages * 140))                     // combined height of images (assuming 140 height)
											/ (numOfButtons + numOfBigButtons + numOfTextLabels + numOfImages + 1));	// divided by the number of spaces needed between objects
        //NSLog(@"spaceBetweenObjects = %f", spaceBetweenObjects);

        
        //set the bottom of the title for the first object 
        previousObjectYMax			= topOfPageSpace; //the bottom of the title
        
        
    ////Loop through all objects in the page
        while (object_el != nil) {
            
            NSString *elementName = [TBXML elementName:object_el];
            
            //y position handling
            object_ypos = [[TBXML valueOfAttributeNamed:kAttr_y forElement:object_el] integerValue];
            if (object_ypos == 0) {
                object_ypos = (previousObjectYMax + spaceBetweenObjects);
            }
			
			//x position handling
            object_xpos = [[TBXML valueOfAttributeNamed:kAttr_x forElement:object_el] integerValue];
            if (object_xpos == 0) {
                object_xpos = (10);
            }
            
            ////TITLE
            if([elementName isEqual:kName_Title]) {
                //title creation is not handled here
                //NSLog(@"Title already created");
            }
            
            ////BUTTON
            if ([elementName isEqual:kName_Button] || [elementName isEqual:@"link-button"]) {
                
                //get the button mode
                button_mode		= [TBXML valueOfAttributeNamed:kAttr_mode forElement:object_el];
                
                //create the lines around the button and add it to the page's view
                buttonLinesTemp	= [self createButtonLinesFromButtonElement:object_el buttonTag:buttonCount yPos:object_ypos container:nil];
                [self.pageView addSubview:buttonLinesTemp];
                
                //create the button and add it to the page's view
                buttonTemp      = [[UISnuffleButton alloc] buttonWithElement:object_el
                                                                      addTag:buttonCount
                                                                        yPos:object_ypos
                                                                   container:self.pageView
                                                                   withStyle:self.pageStyle
                                                           buttonTapDelegate:self.buttonDelegate];
                [self.pageView addSubview:buttonTemp];
                
                //create the arrow and add it to the page's view
                arrowTemp		= [self createDisclosureIndicatorFromButtonTag:buttonCount container:nil];
                [self.pageView addSubview:arrowTemp];

                previousObjectYMax = CGRectGetMaxY(buttonLinesTemp.frame);
                buttonCount++;
            }
            
            ////TEXT LABEL - note: some defaults are overridden here since existing text label defaults are for within panels, not page objects.
            if ([elementName isEqual:kName_Label]) {
                
                labelLabel = [[GTLabel alloc]initWithElement:object_el
                                                parentTextAlignment:NSTextAlignmentLeft
                                                               xPos:object_xpos
                                                               yPos:object_ypos
                                                          container:self.pageView
                                                              style:self.pageStyle];
                [labelLabel setTag:(800+labelCount)];
                if (labelLabel.alpha == 1) {
                    labelLabel.alpha = 0;
                }
 
                //add created label
                [self.pageView insertSubview:labelLabel atIndex:1];
                
                //NSLog(@"Text Label created with frame: x:%f y:%f w:%f h:%f", buttonTemp.frame.origin.x, buttonTemp.frame.origin.y, buttonTemp.frame.size.width, buttonTemp.frame.size.height);
                //NSLog(@"Text Label created with Tag:%d", 800+labelCount);
                
                previousObjectYMax = CGRectGetMaxY(labelLabel.frame);
                labelCount++;
            }
            
            ////IMAGE
            if ([elementName isEqual:kName_Image]) {
                numOfImages++;
                
                imageImage = [self createImageFromElement:object_el xPos:object_xpos yPos:object_ypos container:nil];
				            
                [self.pageView insertSubview:imageImage atIndex:1];
                
                //NSLog(@"Image created with frame: x:%f y:%f w:%f h:%f", buttonTemp.frame.origin.x, buttonTemp.frame.origin.y, buttonTemp.frame.size.width, buttonTemp.frame.size.height);
                
                previousObjectYMax = CGRectGetMaxY(imageImage.frame);
            }
            
            
            ////FOLLOWUP MODAL
            if ( [elementName isEqual:kName_Followup_Modal]) {
                GTFollowupViewController *viewController = [[GTFollowupViewController alloc]init];
                
                GTFollowupModalView *followupModalView = [[GTFollowupModalView alloc] initFromElement:object_el
                                                                                            withStyle:self.pageStyle
                                                                                       presentingView:self.pageView
                                                                                  interpreterDelegate:self.delegate
                                                                                    buttonTapDelegate:viewController];
                
                [viewController setFollowupView:followupModalView];
                
                NSArray *listeners = [[TBXML valueOfAttributeNamed:kAttr_listeners forElement:object_el] componentsSeparatedByString:@","];
                
                for (id listener in listeners) {
                    NSString *listenerName = listener;
                    
                    if ([self.delegate respondsToSelector:@selector(registerListenerWithEventName:target:selector:parameter:)]) {
                        [self.delegate registerListenerWithEventName:listenerName
                                                                  target:self.delegate
                                                                selector:@selector(presentFollowupModalView:)
                                                               parameter:viewController];

                    }
                }
                
                if ([self watermark]) {
                    [followupModalView setWatermark:[self watermark]];
                }
            }
            //NSLog(@"previousObjectYMax = %f\n", previousObjectYMax);
            
            //iterate to the next object
            object_el = object_el->nextSibling;

            //NSLog(@"Button Loop found %d regular buttons and %d big buttons.", numOfButtons, numOfBigButtons);
        
                
        }
        
		//set flag
		self.buttonElementsHaveBeenParsed = YES;
	} else {
		//throw exception if pre requiste functions have not been called
		if (!self.pageElement) {
			NSException* parseException = [NSException exceptionWithName:[self.fileLoader localizedString:@"GTPageInterpreter_parseException_name"]
																  reason:[self.fileLoader localizedString:@"GTPageInterpreter_parseException_message"]
																userInfo:nil];
			@throw parseException;
		}
		
		//throw exception if pre requiste functions have not been called
		if (!self.pageElementsHaveBeenParsed) {
			NSException* parseException = [NSException exceptionWithName:[self.fileLoader localizedString:@"GTPageInterpreter_parseException_name"]
																  reason:[self.fileLoader localizedString:@"GTPageInterpreter_parseXMLPageException_message"]
																userInfo:nil];
			@throw parseException;
		}
	}
}

//Identify the elements in the button pop-out panel and call its 'create' function
- (void)renderPanelOnPageForButtonTag:(NSInteger)tag {
	
	if (self.pageElement && self.buttonElementsHaveBeenParsed) {
		
		//init xml elements for interpretation
		TBXMLElement	*button_el			= [TBXML childElementNamed:kName_Button parentElement:self.pageElement];
		TBXMLElement	*panel_el			= nil;
		
		
		//find button
		for (NSInteger buttonCount = 1; buttonCount < tag; buttonCount++) {
			button_el				=		[TBXML nextSiblingNamed:kName_Button searchFromElement:button_el];
		}
		
		//grab xml element for panel
		panel_el					=		[TBXML childElementNamed:kName_Panel parentElement:button_el];
		
		//create, add and release panel
		UISnufflePanel		*tempPanel	=		[self createPanelFromElement:panel_el buttonTag:tag container:self.pageView];
		if (![self.pageView viewWithTag:tempPanel.tag]) {
			[self.pageView	addSubview:tempPanel];
		}
		
	} else {
		//throw exception if pre requiste functions have not been called
		if (!self.pageElement) {
			NSException* parseException = [NSException exceptionWithName:[self.fileLoader localizedString:@"GTPageInterpreter_parseException_name"]
																  reason:[self.fileLoader localizedString:@"GTPageInterpreter_parseException_message"]
																userInfo:nil];
			@throw parseException;
		}
		
		//throw exception if pre requiste functions have not been called
		if (!self.buttonElementsHaveBeenParsed) {
			NSException* parseException = [NSException exceptionWithName:[self.fileLoader localizedString:@"GTPageInterpreter_parseException_name"]
																  reason:[self.fileLoader localizedString:@"GTPageInterpreter_parseXMLButtonsException_message"]
																userInfo:nil];
			@throw parseException;
		}
	}
	
}

- (UIImageView *)watermark {
	NSString *filename = [TBXML valueOfAttributeNamed:kAttr_watermark forElement:self.pageElement];
	UIImageView *watermark = nil;
	
	if (filename != nil && filename.length>0) {
		watermark = [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:filename]];
		[watermark setFrame:self.pageView.frame];
	}
	
	return watermark;
}

#pragma mark -
#pragma mark Cache Functions

- (void)cacheImages {
	
	//NSLog(@"Caching Images...");
	TBXMLElement *element = self.pageElement;
	while (element) {
		NSString *bgImageFilename	= [TBXML valueOfAttributeNamed:kAttr_backgroundImage forElement:element];
		//NSLog(@"Caching bgimage: %@", bgImageFilename);
		NSString *watermarkFilename = [TBXML valueOfAttributeNamed:kAttr_watermark forElement:element];
		//NSLog(@"Caching watermark: %@", watermarkFilename);
		NSString *elementText		= [TBXML textForElement:element];
		//NSLog(@"Caching elementtext: %@", elementText);
		
		//NSLog(@"Caching Loop: %@:%@", [TBXML elementName:element], elementText);
		
		if (bgImageFilename) {
			[self.fileLoader cacheImageWithFileName:bgImageFilename];
		}
		if (watermarkFilename) {
			[self.fileLoader cacheImageWithFileName:watermarkFilename];
		}
		
		NSRange substrFound;
		substrFound = [[elementText lowercaseString] rangeOfString:@".png"];
		
		if (substrFound.location != NSNotFound) {
			//text contains ".png"; is an image filename
			[self.fileLoader cacheImageWithFileName:elementText];
			//NSLog(@"Caching File: %@", elementText);
		}
		
		
		TBXMLElement *nextelement;// = element->firstChild;
		if (element->firstChild != nil) {
			nextelement = element->firstChild;
		} else if (element->nextSibling != nil){
			nextelement = element->nextSibling;
		} else {
			
			nextelement = element->parentElement->nextSibling;
		}
		
		if (element->firstChild == nil && element->nextSibling == nil && element->parentElement->nextSibling == nil && element->parentElement->parentElement != nil) {
			nextelement = element->parentElement;
			nextelement = nextelement->parentElement->nextSibling;
		}
		
		
		element = nextelement;
		
	}
	
	
	//check for BGImg
	//Check for Watermark
	
	//Loop through every element in the page, checking for referenced images, and cache them
}

#pragma mark -
#pragma mark Create Functions

/**
 *	Description:	Creates an image view for the lines around the button given a button element
 *	Parameters:		Tag:	The number that identifies the button associated with this disclosure indicator
 *	Returns:		A DisclosureIndicator object with parameters set to associate it with its button.
 */
- (id)createButtonLinesFromButtonElement:(TBXMLElement *)element buttonTag:(NSInteger)buttonTag yPos:(CGFloat)yPos container:(UIView *)container {
	
	if (element != nil) {
		
		//init variables for attributes
		NSString	*filename	= nil;
		NSString	*mode		= [TBXML valueOfAttributeNamed:kAttr_mode forElement:element];
		CGFloat		xPos, width, height;
		
		//set container to the page if not set
		if (container == nil) {
			container = self.pageView;
		}
		
		//set vaiables based on the button's mode
		if ([mode isEqual:kButtonMode_big]) {
			filename			= @"Buttonlines_large.png";
			xPos				= LARGEBUTTONXOFFSET;
			width				= container.frame.size.width - (2 * LARGEBUTTONXOFFSET);
			height				= 140;
		} else {
			filename			= @"Buttonlines.png";
			xPos				= BUTTONXOFFSET;
			width				= container.frame.size.width - (2 * BUTTONXOFFSET);
			height				= 40;
		}
		
		//create, set up and return button lines image
		UIImageView *buttonLinesTemp = [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:filename]];
		[buttonLinesTemp setFrame:CGRectMake(xPos, yPos, width, height)];
		[buttonLinesTemp setOpaque:NO];
		[buttonLinesTemp setTag:(30 + buttonTag)];
		[buttonLinesTemp setHidden:YES];
		
		return buttonLinesTemp;
		
	} else {
		return nil;
	}
}

/**
 *	Description:	Creates an image view from an image element
 *	Parameters:		Tag:	The number that identifies the button associated with this disclosure indicator
 *	Returns:		A DisclosureIndicator object with parameters set to associate it with its button.
 */
- (id)createDisclosureIndicatorFromButtonTag:(NSInteger)buttonTag container:(UIView *)container {
	
	//set container to the page if not set
	if (container == nil) {
		container	= self.pageView;
	}
	
	//find the Disclosure Indicator's (arrow's) button
	UISnuffleButton *arrowsButton = (UISnuffleButton *)[container viewWithTag:buttonTag];
	
	if (arrowsButton != nil && !([arrowsButton.mode isEqual:kButtonMode_allurl] || [arrowsButton.mode isEqual:kButtonMode_url])) {
		//calculate frame from the arrow's button
		CGRect frame = CGRectMake(CGRectGetMaxX(arrowsButton.frame) - 20 ,
								  CGRectGetMaxY(arrowsButton.frame) - 25,
								  14,
								  14);
		
		//create, set up and return the disclosure indicator 
		UIDisclosureIndicator *arrowTemp = [[UIDisclosureIndicator alloc] initWithFrame:frame];
		[arrowTemp setBackgroundColor:[UIColor clearColor]];
		[arrowTemp setTag:(20 + buttonTag)];
		[arrowTemp setHidden:YES];
		
		return arrowTemp;
		
	} else {
		return nil;
	}
}

/**
 *	Description:	Creates an image view from an image element
 *	Parameters:		Element:	The TBXMLElement for the image
 *	Returns:		A UIImageView object from the attributes specified in the passed TBXML element.
 */
- (id)createImageFromElement:(TBXMLElement *)element xPos:(CGFloat)xpostion yPos:(CGFloat)ypostion container:(UIView *)container {
	
	//set container to the page if not set
	if (container == nil) {
		container	= self.pageView;
	}
	
	//set default value if not set
	if (!(xpostion >= 0)) {
		xpostion = DEFAULT_PANEL_OFFSET_X;
	}
	
	if (!(ypostion >= 0)) {
		ypostion = DEFAULT_PANEL_OFFSET_Y;
	}
	
	if (element != nil) {
		//NSLog(@"%@",[TBXML textForElement:element]);
		
		NSString	*filename	=						[TBXML textForElement:element];
		NSString	*align		=						[TBXML valueOfAttributeNamed:kAttr_align	forElement:element];
		CGFloat		x			=						[[TBXML valueOfAttributeNamed:kAttr_x		forElement:element] floatValue];
		CGFloat		y			=						[[TBXML valueOfAttributeNamed:kAttr_y		forElement:element] floatValue];
		CGFloat		w			=						[[TBXML valueOfAttributeNamed:kAttr_width	forElement:element] floatValue];
		CGFloat		h			=						[[TBXML valueOfAttributeNamed:kAttr_height	forElement:element] floatValue];
		CGFloat		xoffset		=						round([[TBXML valueOfAttributeNamed:kAttr_xoff		forElement:element] floatValue]);
		CGFloat		yoffset		=						round([[TBXML valueOfAttributeNamed:kAttr_yoff		forElement:element] floatValue]);
		
		//load the image into an image view
		UIImageView *imageTemp = [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:filename]];
		
		x						=						(x == 0 ? xpostion						: x);
		y						=						(y == 0 ? ypostion						: y);
		w						=						(w == 0 ? imageTemp.frame.size.width	: w);
		h						=						(h == 0 ? imageTemp.frame.size.height	: h);
		
		//grab frame from attributes
		CGRect tempFrame =  CGRectMake(x,
									   y,
									   w,
									   h);
		
		//if alignment is found calculate position based on alignment
		if ([align isEqualToString:kAlignment_left]) {
			
			tempFrame	= CGRectMake( DEFAULT_PANEL_OFFSET_X, y, w, h);
			
		} else if ([align isEqualToString:kAlignment_center]) {
			
			tempFrame	= CGRectMake( ( 0.5 * container.frame.size.width ) - ( 0.5 * w ), y, w, h);
			
		} else if ([align isEqualToString:kAlignment_right]) {
			
			tempFrame	= CGRectMake( container.frame.size.width - w - DEFAULT_PANEL_OFFSET_X, y, w, h);
			
		}
		
		//apply offset
		tempFrame.origin.x			+= xoffset;
		tempFrame.origin.y			+= yoffset;
		
		if (!CGRectIsEmpty(tempFrame)) {
			[imageTemp setFrame:tempFrame];
		}
		
		//set up image
		[imageTemp setBackgroundColor:[UIColor clearColor]];
		
		return imageTemp;
		
	} else {
		return nil;
	}
	
}


/**
 *	Description:	Creates an UISnufflePanel from a panel element
 *	Parameters:		Element:	The TBXMLElement for the panel
 *	Returns:		A UISnufflePanel object from the attributes specified in the passed TBXML element.
 */
- (id)createPanelFromElement:(TBXMLElement *)element buttonTag:(NSInteger)buttonTag container:(UIView *)container {
	
	//if panel exists create panel
	if (element) {
		
		//Fetch and store the panel's text alignment
		NSString		*panel_alignment	= [TBXML valueOfAttributeNamed:kAttr_textalign	forElement:element];
		UITextAlignment	panelAlign;
		if ([panel_alignment isEqual:kAlignment_left]) {
			panelAlign = NSTextAlignmentLeft;
		} else if ([panel_alignment isEqual:kAlignment_center]) {
			panelAlign = NSTextAlignmentCenter;
		} else if ([panel_alignment isEqual:kAlignment_right]) {
			panelAlign = NSTextAlignmentRight;
		} else {
			panelAlign = NSTextAlignmentLeft;
		}
		
		//init objects that will be used to add interpreted elements to the page
		UILabel			*labelTemp			= nil;
		UIImageView		*imageTemp			= nil;
		UISnuffleButton	*buttonTemp			= nil;
		
        GTMultiButtonResponseView *multiButtonResponseView = nil;
        
		//init variables for xml attributes
		CGFloat			maxWidth			= 0;
		CGFloat			maxHeight			= 0;
		
		UISnufflePanel	*tempPanel			=	[[UISnufflePanel alloc] init];
		CGRect			containerFrame		=	(container ? container.frame : CGRectMake(0, 0, 320, 480));
		UIView			*tempContainerView	=	[[UIView alloc] initWithFrame:CGRectMake(5, 5, CGRectGetWidth(containerFrame) - 40, 5)];
		
		//init variables for button placment
		CGFloat				spaceBetweenObjects = 10.0;
		CGFloat				previousObjectYMax	= 0.0;
        NSInteger           object_ypos         = 0;
        NSInteger           object_xpos         = 0;
        
        //set object_el to the first object
       TBXMLElement		*object_el				= element->firstChild;
        
		////Loop through all objects in the panel
        while (object_el != nil) {
            
            //y position handling
            //object_yoffset = [[TBXML valueOfAttributeNamed:kAttr_yoff forElement:object_el] integerValue];
            object_ypos = [[TBXML valueOfAttributeNamed:kAttr_y forElement:object_el] integerValue];
            if (object_ypos == 0) {
                object_ypos = (previousObjectYMax + spaceBetweenObjects);
            }
			
			//x position handling
            //object_xoffset = [[TBXML valueOfAttributeNamed:kAttr_xoff forElement:object_el] integerValue];
            object_xpos = [[TBXML valueOfAttributeNamed:kAttr_x forElement:object_el] integerValue];
            if (object_xpos == 0) {
                object_xpos = (0);
            }
            
            ////BUTTON
			if ([[TBXML elementName:object_el] isEqual:kName_Button] || [[TBXML elementName:object_el] isEqual:@"link-button"]) {
                
                //create image
                buttonTemp          = [[UISnuffleButton alloc]buttonWithElement:object_el
                                                                         addTag:buttonTag
                                                                           yPos:object_ypos
                                                                      container:tempContainerView
                                                                      withStyle:self.pageStyle
                                                              buttonTapDelegate:self.buttonDelegate];
                
                //store the maximum dimensions
                maxWidth			= fmaxf(maxWidth, CGRectGetMaxX(buttonTemp.frame));
				maxHeight			= fmaxf(maxHeight, CGRectGetMaxY(buttonTemp.frame));
				
				previousObjectYMax	= CGRectGetMaxY(buttonTemp.frame);
				
				//add to container
				[tempContainerView addSubview:buttonTemp];
				
            }
            
            
            ////POSITIVE-NEGATIVE BUTTON COMBO
            if ([[TBXML elementName:object_el] isEqual:kName_Button_Pair]) {
                TBXMLElement *firstChild = object_el->firstChild;
                TBXMLElement *secondChild = firstChild->nextSibling;
                
                multiButtonResponseView = [[GTMultiButtonResponseView alloc]initWithFirstElement:firstChild
                                                                                   secondElement:secondChild
                                                                                   parentElement:object_el
                                                                                       yPosition:object_ypos
                                                                                   containerView:tempContainerView
                                                                                       withStyle:self.pageStyle
                                                                               buttonTapDelegate:self.buttonDelegate];
                
                maxWidth			= fmaxf(maxWidth, CGRectGetMaxX(multiButtonResponseView.frame));
                maxHeight			= fmaxf(maxHeight, CGRectGetMaxY(multiButtonResponseView.frame));
                
                previousObjectYMax	= CGRectGetMaxY(multiButtonResponseView.frame);
                
                //add to container
                [tempContainerView addSubview:multiButtonResponseView];
                
            }
            
            
            ////TEXT LABEL - note: some defaults are overridden here since existing text label defaults are for within panels, not page objects.
            if ([[TBXML elementName:object_el] isEqual:kName_Label]) {
                
                //create label
                labelTemp           = [[GTLabel alloc] initWithElement:object_el
                                                   parentTextAlignment:panelAlign
                                                                  xPos:object_xpos
                                                                  yPos:object_ypos
                                                             container:tempContainerView
                                                                 style:self.pageStyle];
                
				//store the maximum dimensions
				maxWidth			= fmaxf(maxWidth, CGRectGetMaxX(labelTemp.frame));
				maxHeight			= fmaxf(maxHeight, CGRectGetMaxY(labelTemp.frame));
				
				previousObjectYMax	= CGRectGetMaxY(labelTemp.frame);
				
				//add to container
				[tempContainerView addSubview:labelTemp];
				
            }
            
            ////IMAGE
            if ([[TBXML elementName:object_el] isEqual:kName_Image]) {
                
				//create image
				imageTemp			= [self createImageFromElement:object_el xPos:object_xpos yPos:object_ypos container:tempContainerView];
				
				//store the maximum dimensions
				maxWidth			= fmaxf(maxWidth, CGRectGetMaxX(imageTemp.frame));
				maxHeight			= fmaxf(maxHeight, CGRectGetMaxY(imageTemp.frame));
				
				previousObjectYMax	= CGRectGetMaxY(imageTemp.frame);
				
				//add to container
				[tempContainerView addSubview:imageTemp];
				
            }
            
            //NSLog(@"previousObjectYMax = %f\n", previousObjectYMax);
            
            //iterate to the next object
            object_el = object_el->nextSibling;
			
			
        }
		
		//set up container view
		[tempContainerView setFrame:CGRectMake(5, 5, fmaxf(280, maxWidth), maxHeight+5)];
		[tempContainerView setBackgroundColor:[UIColor clearColor]];
		[tempContainerView setTag:(100 + buttonTag)];
		
		//set up panel
		[tempPanel setFrame:tempContainerView.frame];
		[tempPanel setBackgroundColor:self.pageStyle.backgroundColor];
		[tempPanel setTag:(1000 + buttonTag)];
		[tempPanel setHidden:YES];
		[tempPanel setAlpha:0.0];
		
		//add views
		[tempPanel addSubview:tempContainerView];
		
		return tempPanel;
		
	} else {
		return nil;
	}
}


- (id)createQuestionFromElement:(TBXMLElement *)element container:(UIView *)container {
	
	//set container to the page if not set
	if (container == nil) {
		container	= self.pageView;
	}
	
	if (element != nil) {
		
		UIView			*questionContainer	=	[[UIView alloc] init];
		UILabel			*tempLabel			=	nil;
		TBXMLElement	*label_el			=	[TBXML childElementNamed:kName_Label		parentElement:element];
		NSString		*mode				=	[TBXML valueOfAttributeNamed:kAttr_mode		forElement:element];
		NSInteger		numOfLabels			=	0;
		NSUInteger		tag					=	10;
		CGFloat			maxY				=	0;
		
						mode				=	(mode == nil ? @"" : mode);
		
		if ([TBXML valueOfAttributeNamed:kAttr_listeners forElement:element]) {
			
			__weak typeof(self)weakSelf = self;
			NSArray *listeners = [[TBXML valueOfAttributeNamed:kAttr_listeners forElement:element] componentsSeparatedByString:@","];
			[listeners enumerateObjectsUsingBlock:^(NSString *listener, NSUInteger index, BOOL *stop) {
				
				if ([weakSelf.delegate respondsToSelector:@selector(registerListenerWithEventName:target:selector:parameter:)]) {
					
					[weakSelf.delegate registerListenerWithEventName:listener target:nil selector:@selector(announce) parameter:nil];
					
				}
				
			}];
			
		}
		
		//if the question is made up of labels, put them in the container
		while (label_el) {
			//create label from element
			tempLabel = [self createQuestionLabelFromElement:label_el container:questionContainer];
			
			//record max y
			maxY = fmaxf(maxY, CGRectGetMaxY(tempLabel.frame));
			
			//add label to container
			[questionContainer addSubview:tempLabel];
			
			//increament
			label_el = [TBXML nextSiblingNamed:kName_Label searchFromElement:label_el];
			numOfLabels++;
		}
		
		//if there were labels finish configuring the container else set the container to be a straight question label
		if (numOfLabels > 0) {
			NSString	*x			=	[TBXML valueOfAttributeNamed:kAttr_x		forElement:element];
			NSString	*y			=	[TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
			NSString	*w			=	[TBXML valueOfAttributeNamed:kAttr_width	forElement:element];
			NSString	*h			=	[TBXML valueOfAttributeNamed:kAttr_height	forElement:element];
			NSString	*align		=	[TBXML valueOfAttributeNamed:kAttr_align	forElement:element];
			CGRect		frame		=	CGRectZero;
			
			if		(x)				{frame.origin.x		=	round([x floatValue]);}	else	{frame.origin.x		= DEFAULT_QUESTION_OFFSET_X;}
			if		(y)				{frame.origin.y		=	round([y floatValue]);}	else	{frame.origin.y		= container.frame.size.height - maxY - DEFAULT_QUESTION_OFFSET_Y;}
			if		(w)				{frame.size.width	=	round([w floatValue]);}	else	{frame.size.width	= container.frame.size.width;}
			if		(h)				{frame.size.height	=	round([h floatValue]);}	else	{frame.size.height	= maxY + 5;}
			
			questionContainer.frame	=	frame;
			[questionContainer setBackgroundColor:[UIColor clearColor]];
			
			//add properties to space the question out better and to let the animation code know it needs to be faded in
			if ([mode isEqual:kTitleMode_straight]) {
				
				tag = 0;
				
			}
			
			//if the question can be aligned then align it
			if (![mode isEqual:kTitleMode_straight] && frame.size.width < container.frame.size.width) {
				
				//if alignment is found calculate position based on alignment
				if ([align isEqualToString:kAlignment_left]) {
					
					frame.origin.x		= DEFAULT_QUESTION_OFFSET_X;
					
				} else if ([align isEqualToString:kAlignment_center]) {
					
					frame.origin.x		= ( 0.5 * container.frame.size.width ) - ( 0.5 * frame.size.width );
					
				} else if ([align isEqualToString:kAlignment_right]) {
					
					frame.origin.x		= container.frame.size.width - frame.size.width - DEFAULT_QUESTION_OFFSET_X;
					
				}
				
			}
			
			[questionContainer setTag:tag];
			if (tag != 0) {[questionContainer setHidden:YES];}
			if (y == nil) {
				questionContainer.frame = CGRectMake(questionContainer.frame.origin.x,
													 container.frame.size.height - 20 - questionContainer.frame.size.height - 10,
													 questionContainer.frame.size.width,
													 questionContainer.frame.size.height + 10);
			}
			
		} else {
			
			questionContainer		=	[self createQuestionLabelFromElement:element container:container];
			
			//add properties to space the question out better and to let the animation code know it needs to be faded in
			if ([mode isEqual:kTitleMode_straight]) {tag = 0;}
			[questionContainer setTag:tag];
			if (tag != 0) {[questionContainer setHidden:YES];}
			questionContainer.frame = CGRectMake(questionContainer.frame.origin.x,
												 container.frame.size.height - 20 - questionContainer.frame.size.height - 10,
												 container.frame.size.width - (questionContainer.frame.origin.x * 2),
												 questionContainer.frame.size.height + 10);
		}
		
		return questionContainer;
		
	} else {
		return nil;
	}
	
}

- (id)createQuestionLabelFromElement:(TBXMLElement *)element container:(UIView *)container {
	
	//set container to the page if not set
	if (container == nil) {
		container	= self.pageView;
	}
	
	if (element != nil) {
		//read attributes for label
		NSString	*text		=								[TBXML textForElement:element];
		NSString	*mode		=								[TBXML valueOfAttributeNamed:kAttr_mode		forElement:element];
		UIColor		*color		=	[GTPageStyle colorForHex:	[TBXML valueOfAttributeNamed:kAttr_color	forElement:element]];
		NSString	*modifier	=								[TBXML valueOfAttributeNamed:kAttr_modifier	forElement:element];
		NSString	*alpha		=								[TBXML valueOfAttributeNamed:kAttr_alpha	forElement:element];
		NSString	*align		=								[TBXML valueOfAttributeNamed:kAttr_align	forElement:element];
		NSString	*textalign	=								[TBXML valueOfAttributeNamed:kAttr_textalign	forElement:element];
		NSString	*size		=								[TBXML valueOfAttributeNamed:kAttr_size		forElement:element];
		NSString	*x			=								[TBXML valueOfAttributeNamed:kAttr_x		forElement:element];
		NSString	*y			=								[TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
		NSString	*w			=								[TBXML valueOfAttributeNamed:kAttr_width	forElement:element];
		NSString	*h			=								[TBXML valueOfAttributeNamed:kAttr_height	forElement:element];
		
					mode		=								(mode == nil ? @"" : mode);
		
		CGRect			frame			= CGRectZero;
		UITextAlignment textAlignment	= NSTextAlignmentRight;
		BOOL			resize			= YES;
		UIColor			*bgColor		= nil;
		NSUInteger		textSize		= DEFAULT_TEXTSIZE_QUESTION_NORMAL;
		NSString		*font			= self.pageStyle.questionFontName;
		CGFloat			labelAlpha		= 1.0;
		
		//overwrite defaults with user set values (xml attributes)
		if		(x)										{frame.origin.x		=	round([x floatValue]);}								else	{frame.origin.x		= 10;}
		if		(y)										{frame.origin.y		=	round([y floatValue]);}								else	{frame.origin.y		= 364;}
		if		(w)										{frame.size.width	=	round([w floatValue]);}								else	{frame.size.width	= 300;}
		if		(h)										{frame.size.height	=	round([h floatValue]);}								else	{frame.size.height	= 76;}
		if		((w != nil) && (h != nil))				{resize				= NO;}
		
		if		(!bgColor)																								{bgColor			= self.pageStyle.defaultLabelBackgroundColor;}
		if		(!color)																								{color				= self.pageStyle.defaultTextColor;}
		if		(size)									{textSize			= round(textSize * [size floatValue] / 100);}
		
		if (alpha) {
			labelAlpha = [alpha floatValue];
		}
		
		if (textalign) {
			if		([textalign isEqual:kAlignment_right])	{textAlignment		= NSTextAlignmentRight;}
			else if ([textalign isEqual:kAlignment_center])	{textAlignment		= NSTextAlignmentCenter;}
			else if ([textalign isEqual:kAlignment_left])	{textAlignment		= NSTextAlignmentLeft;}
		}																										else	{textAlignment		= NSTextAlignmentRight;}
		
		if		([mode isEqual:kTitleMode_straight]) {
			bgColor = self.pageStyle.straightQuestionBackgroundColor;
			color = self.pageStyle.backgroundColor;
			textSize = round(DEFAULT_TEXTSIZE_QUESTION_STRAIGHT * [size floatValue] / 100);
			font = self.pageStyle.straightQuestionFontName;
			frame = CGRectMake(0, frame.origin.y, 320, frame.size.height);
			textAlignment = NSTextAlignmentCenter;
		}
		
		//if the question can be aligned then align it
		if (![mode isEqual:kTitleMode_straight] && frame.size.width < container.frame.size.width) {
			
			//if alignment is found calculate position based on alignment
			if ([align isEqualToString:kAlignment_left]) {
				
				frame.origin.x		= DEFAULT_QUESTION_OFFSET_X;
				
			} else if ([align isEqualToString:kAlignment_center]) {
				
				frame.origin.x		= ( 0.5 * container.frame.size.width ) - ( 0.5 * frame.size.width );
				
			} else if ([align isEqualToString:kAlignment_right]) {
				
				frame.origin.x		= container.frame.size.width - frame.size.width - DEFAULT_QUESTION_OFFSET_X;
				
			}
			
		}
		
		if (modifier) {
			if ([modifier isEqual:kLabelModifer_bold]) {
				font = self.pageStyle.boldLabelFontName;
			} else if ([modifier isEqual:kLabelModifer_italics]) {
				font = self.pageStyle.italicsLabelFontName;
			} else if ([modifier isEqual:kLabelModifer_bolditalics]) {
				font = self.pageStyle.boldItalicsLabelFontName;
			} else if ([modifier isEqual:kLabelModifer_normal]) {
				font = self.pageStyle.labelFontName;
			}
		}
        
        return [[GTLabel alloc]initWithFrame:frame
                                  autoResize:resize text:text
                                       color:color
                                     bgColor:bgColor
                                       alpha:labelAlpha
                                   alignment:textAlignment
                                        font:font
                                        size:textSize];

	} else {
		return nil;
	}
}

- (id)createTitleFromElement:(TBXMLElement *)element container:(UIView *)container {
	
	
	if (element) {
		UIRoundedView	*titleContainer		= nil;
		
		NSString		*mode				= [TBXML valueOfAttributeNamed:kAttr_mode			forElement:element];
		
		TBXMLElement	*title_number		= [TBXML childElementNamed:kName_TitleNumber		parentElement:element];
		TBXMLElement	*title_heading		= [TBXML childElementNamed:kName_TitleHeading		parentElement:element];
		TBXMLElement	*title_subheading	= [TBXML childElementNamed:kName_TitleSubHeading	parentElement:element];
		NSInteger		xmltitleheight		= [[TBXML valueOfAttributeNamed:kAttr_height		forElement:element] intValue];
		CGRect			titleFrame			= CGRectMake(0, 20, CGRectGetWidth(container.frame) - 20, xmltitleheight ? xmltitleheight : 150);
		
		UILabel	*tempNumber			= nil;
		UILabel *tempHeading		= nil;
		UILabel	*tempSubHeading		= nil;
		
		//create the title container
		if ([mode isEqual:kTitleMode_straight]) {
			titleFrame = CGRectMake(0, 20, CGRectGetWidth(container.frame), CGRectGetHeight(titleFrame));
			
		}
		
		if (title_number)		{tempNumber		= [self createTitleNumberFromElement:title_number			titleMode:mode containerFrame:titleFrame];}
		if (title_heading)		{tempHeading	= [self createTitleHeadingFromElement:title_heading			titleMode:mode containerFrame:titleFrame];}
		if (title_subheading)	{tempSubHeading	= [self createTitleSubheadingFromElement:title_subheading	titleMode:mode containerFrame:titleFrame];}
		
		//fixes issue with number getting cut off when heading is short
		if (tempNumber && tempHeading) {
			tempNumber.frame = CGRectMake(CGRectGetMinX(tempNumber.frame),
										  CGRectGetMinY(tempNumber.frame),
										  CGRectGetWidth(tempNumber.frame),
										  fmaxf(fminf(CGRectGetHeight(tempNumber.frame), CGRectGetHeight(tempHeading.frame)), 50));
		}
		
		//Uses a loop to find the right size for the heading to fit on 3 lines
		if ([mode isEqual:kTitleMode_peek]) {
			NSArray *textArray = [tempHeading.text componentsSeparatedByString:@" "];
			NSInteger numberoflines = [textArray count];
			CGFloat desiredHeight = fmaxf(CGRectGetHeight(tempSubHeading.frame), DEFAULT_TITLE_PEEKHEADING_MIN_HEIGHT);
			
			tempHeading.text = [textArray componentsJoinedByString:@"\n"];
			
			UIFont *tempFont = [UIFont fontWithName:self.pageStyle.peekHeadingFontName size:DEFAULT_TEXTSIZE_TITLE_PEEKHEADING_MAX];
			int i;
			CGSize labelsize;
			for (i=DEFAULT_TEXTSIZE_TITLE_PEEKHEADING_MAX; i> DEFAULT_TEXTSIZE_TITLE_PEEKHEADING_MIN; i=i-1) {
				tempFont = [tempFont fontWithSize:i];
				CGSize constraintSize = CGSizeMake(tempHeading.frame.size.width, MAXFLOAT);
				labelsize = [tempHeading.text sizeWithFont:tempFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
				
				CGFloat currentNumberOfLines = ceil(labelsize.height / tempFont.lineHeight);
				if (labelsize.height <= desiredHeight && currentNumberOfLines == numberoflines) {
					break;
				}
			}
			
			if (numberoflines > 1) {
				tempHeading.frame = CGRectMake(tempHeading.frame.origin.x, tempHeading.frame.origin.y, labelsize.width, labelsize.height);
				tempHeading.font = tempFont;
			}
			
			tempSubHeading.frame			= CGRectMake(CGRectGetMaxX(tempHeading.frame) + 11, 
														 tempSubHeading.frame.origin.y, 
														 container.frame.size.width - 20 - tempSubHeading.frame.origin.x - 11, 
														 fmaxf(tempSubHeading.frame.size.height + 10,labelsize.height + 20));
			tempHeading.frame				= CGRectMake(tempHeading.frame.origin.x, 
														 tempHeading.frame.origin.y - 10, 
														 tempHeading.frame.size.width, 
														 fmaxf(tempSubHeading.frame.size.height + 10,labelsize.height + 20));
			
		}
		
		//calc title height
		CGFloat titleheight = 0;
		if (xmltitleheight == 0) {
			titleheight = fmaxf(CGRectGetMaxY(tempHeading.frame) + ([mode isEqual:kTitleMode_peek] ? 0 : 5), CGRectGetMaxY(tempSubHeading.frame)+5);
		} else {
			if (!(xmltitleheight % 2) && [mode isEqual:kTitleMode_straight]) {
				//add 1 to even heights (even heights render blurry on straight-mode titles for some WEIRD reason)
				//xmltitleheight++;
			}
			titleheight = xmltitleheight;
		}
		
		//override title height for subheadings with peek
		if (tempSubHeading && [mode isEqual:kTitleMode_peek]) {titleheight += tempSubHeading.frame.size.height + CGRectGetMinY(tempSubHeading.frame) - CGRectGetMaxY(tempHeading.frame);}
		
		//set newly calculated height but don't let it be less than 43, the min value for shadows to display correctly
		titleFrame.size.height = fmaxf(titleheight, 43);
		//set bigger min size if a number is involved
		if (tempNumber) {
			titleFrame.size.height = fmaxf(titleheight, 60);
		}
		
		//create the title container
		if ([mode isEqual:kTitleMode_clear]) {
			//clear mode
			titleContainer = [[UIRoundedView alloc] initWithFrame:titleFrame
														  bgColor:self.pageStyle.clearTitleBackgroundColor
														   radius:ROUNDRECT_RADIUS
														  topleft:NO
														 topright:NO
													  bottomright:NO
													   bottomleft:NO
													  tapDelegate:self.panelDelegate];
			
		} else if ([mode isEqual:kTitleMode_plain]) {
			//plain mode
			titleContainer = [[UIRoundedView alloc] initWithFrame:titleFrame
														  bgColor:self.pageStyle.plainTitleBackgroundColor
														   radius:ROUNDRECT_RADIUS
														  topleft:NO
														 topright:YES
													  bottomright:YES
													   bottomleft:NO
													  tapDelegate:self.panelDelegate];
			
			tempSubHeading.frame = CGRectMake(10, 10, container.frame.size.width - 30, titleheight - 10);
			[tempSubHeading sizeToFit];
			titleContainer.frame = CGRectMake(0, 20, container.frame.size.width - 20, tempSubHeading.frame.size.height + 20);
			titleContainer.clipsToBounds = YES;
		} else if ([mode isEqual:kTitleMode_straight]) {
			//straight mode
			titleContainer = [[UIRoundedView alloc] initWithFrame:titleFrame
														  bgColor:self.pageStyle.straightTitleBackgroundColor
														   radius:ROUNDRECT_RADIUS
														  topleft:NO
														 topright:NO
													  bottomright:NO
													   bottomleft:NO
													  tapDelegate:self.panelDelegate];
			
		} else if ([mode isEqual:kTitleMode_singlecurve] || [mode isEqual:kTitleMode_peek]) {
			//single rounded corner mode or
			//peek mode
			titleContainer = [[UIRoundedView alloc] initWithFrame:titleFrame
														  bgColor:self.pageStyle.singleCurveTitleBackgroundColor
														   radius:ROUNDRECT_RADIUS * 2
														  topleft:NO
														 topright:NO
													  bottomright:YES
													   bottomleft:NO
													  tapDelegate:self.panelDelegate];
			
		} else {
			//no mode specified
			titleContainer = [[UIRoundedView alloc] initWithFrame:titleFrame
														  bgColor:self.pageStyle.defaultTitleBackgroundColor
														   radius:ROUNDRECT_RADIUS
														  topleft:NO
														 topright:YES
													  bottomright:YES
													   bottomleft:NO
													  tapDelegate:self.panelDelegate];
			
			titleContainer.clipsToBounds = YES;
		}
		
		//peek mode: create the vertical line
		if ([mode isEqual:kTitleMode_peek]) {
			UIImageView *tempVertLine = [[UIImageView alloc] initWithImage:[self.fileLoader imageWithFilename:@"vline.png"]];
			tempVertLine.frame = CGRectMake(CGRectGetMaxX(tempHeading.frame) + 4, tempSubHeading.frame.origin.y + 5, 2, tempSubHeading.frame.size.height - 10);
			if (tempVertLine) {[titleContainer addSubview:tempVertLine];}
		}
		
		//center heading vertically
		if (xmltitleheight) {
			[tempHeading setCenter:CGPointMake(tempHeading.center.x, round(titleContainer.center.y - titleContainer.frame.origin.y))];
		}
		
		if (tempNumber) {[titleContainer addSubview:tempNumber];}
		if (tempHeading) {[titleContainer addSubview:tempHeading];}
		if (tempSubHeading) {[titleContainer addSubview:tempSubHeading];}

		titleContainer.titleMode	= mode;
		titleContainer.tag			= 560;
		return titleContainer;
		
	} else {
		return nil;
	}
	
}

- (id)createSubTitleFromElement:(TBXMLElement *)element underTitle:(UIView *)titleUIView {
	UIRoundedView	*subTitleContainer = nil;
	
	if (element) {
		
		TBXMLElement	*subTitle_element			= [TBXML childElementNamed:kName_TitlePeek		parentElement:element];
		if (subTitle_element) {
			
			NSString	*text		=								[TBXML textForElement:subTitle_element];
			NSString	*modifier	=								[TBXML valueOfAttributeNamed:kAttr_modifier forElement:subTitle_element];
			UIColor		*color		=	[GTPageStyle colorForHex:	[TBXML valueOfAttributeNamed:kAttr_color	forElement:subTitle_element]];
			NSString	*alpha		=								[TBXML valueOfAttributeNamed:kAttr_alpha	forElement:subTitle_element];
			NSString	*align		=								[TBXML valueOfAttributeNamed:kAttr_textalign	forElement:subTitle_element];
			NSString	*size		=								[TBXML valueOfAttributeNamed:kAttr_size		forElement:subTitle_element];
			NSString	*x			=								[TBXML valueOfAttributeNamed:kAttr_x		forElement:subTitle_element];
			NSString	*y			=								[TBXML valueOfAttributeNamed:kAttr_y		forElement:subTitle_element];
			NSString	*w			=								[TBXML valueOfAttributeNamed:kAttr_width	forElement:subTitle_element];
			NSString	*h			=								[TBXML valueOfAttributeNamed:kAttr_height	forElement:subTitle_element];
			
			//init variables for object parameters
			CGRect			frame			= CGRectZero;
			UITextAlignment textAlignment	= NSTextAlignmentLeft;
			BOOL			resize			= YES;
			UIColor			*bgColor		= nil;
			NSUInteger		textSize		= DEFAULT_TEXTSIZE_TITLE_SUBHEADING;
			NSString		*font			= self.pageStyle.peekPanelFontName;
			CGFloat			labelAlpha		= 1.0;
			
			//set parameters to attribute val or defaults	//attribute value															//default value
			if		(x)										{frame.origin.x		=	round([x floatValue]);}								else	{frame.origin.x		= 10;}
			if		(y)										{frame.origin.y		=	round([y floatValue]);}								else	{frame.origin.y		= 30;}
			if		(w)										{frame.size.width	=	round([w floatValue]);}								else	{frame.size.width	= CGRectGetWidth(titleUIView.frame) - 40;}
			if		(h)										{frame.size.height	=	round([h floatValue]);}								else	{frame.size.height	= 80;}
			if		((w != nil) && (h != nil))				{resize				= NO;}
			
			if		(!bgColor)																											{bgColor			= self.pageStyle.subTitleBackgroundColor;}
			if		(!color)																											{color				= self.pageStyle.backgroundColor;}
			if		(size)									{textSize			= round(textSize * [size floatValue] / 100);}
			
			if (alpha) {
				labelAlpha = [alpha floatValue];
			}
			
			if (modifier) {
				if		([modifier isEqual:kLabelModifer_bold])			{font		= self.pageStyle.boldLabelFontName;}
				else if	([modifier isEqual:kLabelModifer_italics])		{font		= self.pageStyle.italicsLabelFontName;}
				else if	([modifier isEqual:kLabelModifer_bolditalics])	{font		= self.pageStyle.boldItalicsLabelFontName;}
			}
			
			if (align) {
				if		([align isEqual:kAlignment_right])	{textAlignment		= NSTextAlignmentRight;}
				else if ([align isEqual:kAlignment_center])	{textAlignment		= NSTextAlignmentCenter;}
				else if ([align isEqual:kAlignment_left])	{textAlignment		= NSTextAlignmentLeft;}
			}
			
			UILabel			*tempSubTitleText		= nil;
			
			if (subTitle_element) {
                tempSubTitleText = [[GTLabel alloc] initWithFrame:frame
                                                       autoResize:resize
                                                             text:text
                                                            color:color
                                                          bgColor:self.pageStyle.defaultLabelBackgroundColor
                                                            alpha:labelAlpha
                                                        alignment:textAlignment
                                                             font:font
                                                              size:textSize];
			}
			
			
			//set the initial frame of the subtitle
			CGRect subTitleFrame = CGRectMake(0,
                                              self.titleFrame.size.height - (tempSubTitleText.frame.size.height + tempSubTitleText.frame.origin.y + (ROUNDRECT_RADIUS)) + 10,
                                              titleUIView.frame.size.width - 10,
                                              tempSubTitleText.frame.size.height + tempSubTitleText.frame.origin.y + (ROUNDRECT_RADIUS)
                                              );
			
			subTitleContainer = [[UIRoundedView alloc] initWithFrame:subTitleFrame
															 bgColor:bgColor
															  radius:(ROUNDRECT_RADIUS * 2)
															 topleft:NO
															topright:NO
														 bottomright:YES
														  bottomleft:NO
														 tapDelegate:self.panelDelegate];
			
			CGRect peekPanelArrowFrame = CGRectMake((subTitleFrame.size.width / 2) - 5 ,subTitleFrame.size.height - 8 , 10, 10);
            UILabel *peekPanelArrow = [[GTLabel alloc] initWithFrame:peekPanelArrowFrame
                                                          autoResize:NO
                                                                text:@"▼"
                                                               color:self.pageStyle.defaultTextColor
                                                             bgColor:self.pageStyle.defaultLabelBackgroundColor
                                                               alpha:1.0
                                                           alignment:NSTextAlignmentCenter
                                                                font:self.pageStyle.labelFontName
                                                                size:8];
            
			peekPanelArrow.shadowColor = [UIColor darkGrayColor];
			
			[subTitleContainer addSubview:tempSubTitleText];
			[subTitleContainer insertSubview:peekPanelArrow aboveSubview:tempSubTitleText];
			
			subTitleContainer.titleMode = kTitleMode_peek;
		}
	}
	return subTitleContainer;
}

- (id)createTitleNumberFromElement:(TBXMLElement *)element	titleMode:(NSString *)titleMode containerFrame:(CGRect)containerFrame {
	
	if (element != nil) {
		
		//read attributes for title subheading
		NSString	*text	=								[TBXML textForElement:element];
		UIColor		*color	=	[GTPageStyle colorForHex:	[TBXML valueOfAttributeNamed:kAttr_color	forElement:element]];
		NSString	*alpha	=								[TBXML valueOfAttributeNamed:kAttr_alpha	forElement:element];
		NSString	*align	=								[TBXML valueOfAttributeNamed:kAttr_textalign	forElement:element];
		NSString	*size	=								[TBXML valueOfAttributeNamed:kAttr_size		forElement:element];
		NSString	*x		=								[TBXML valueOfAttributeNamed:kAttr_x		forElement:element];
		NSString	*y		=								[TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
		NSString	*w		=								[TBXML valueOfAttributeNamed:kAttr_width	forElement:element];
		NSString	*h		=								[TBXML valueOfAttributeNamed:kAttr_height	forElement:element];
		
		CGRect			frame			= CGRectZero;
		UITextAlignment textAlignment	= NSTextAlignmentRight;
		BOOL			resize			= YES;
		UIColor			*bgColor		= nil;
		NSUInteger		textSize		= DEFAULT_TEXTSIZE_TITLE_NUMBER;
		NSString		*font			= self.pageStyle.numberFontName;
		CGFloat			labelAlpha		= 1.0;
		//overwrite defaults with user set values (xml attributes)
		if		(x)										{frame.origin.x		= [x floatValue];}								else	{frame.origin.x		= 10;}
		if		(y)										{frame.origin.y		= [y floatValue];}								else	{frame.origin.y		= 5;}
		if		(w)										{frame.size.width	= [w floatValue];}								else	{frame.size.width	= 40;}
		if		(h)										{frame.size.height	= [h floatValue];}								else	{frame.size.height	= 150;}
		if		((w != nil) && (h != nil))				{resize				= NO;}
		
		if		(!bgColor)																								{bgColor			= self.pageStyle.defaultLabelBackgroundColor;}
		if		(!color)																								{color				= self.pageStyle.backgroundColor;}
		if		(size)									{textSize			= round(textSize * [size floatValue] / 100);}
		
		if (alpha) {
			labelAlpha = [alpha floatValue];
		}
		
		if (align) {
			if		([align isEqual:kAlignment_right])	{textAlignment		= NSTextAlignmentRight;}
			else if ([align isEqual:kAlignment_center])	{textAlignment		= NSTextAlignmentCenter;}
			else if ([align isEqual:kAlignment_left])	{textAlignment		= NSTextAlignmentLeft;}
		}																										else	{textAlignment		= NSTextAlignmentRight;}
		
		if (titleMode) {
			if		([titleMode isEqual:kTitleMode_clear])	{bgColor			= self.pageStyle.clearTitleBackgroundColor;}
		}
		
        return [[GTLabel alloc] initWithFrame:frame
                                   autoResize:resize
                                         text:text
                                        color:color
                                      bgColor:bgColor
                                        alpha:labelAlpha
                                    alignment:textAlignment
                                         font:font
                                         size:textSize];
		
	} else {
		return nil;
	}
	
}


- (id)createTitleHeadingFromElement:(TBXMLElement *)element	titleMode:(NSString *)titleMode containerFrame:(CGRect)containerFrame {
	
	
	if (element != nil) {
		//read attributes for title subheading
		NSString	*text	=								[TBXML textForElement:element];
		UIColor		*color	=	[GTPageStyle colorForHex:	[TBXML valueOfAttributeNamed:kAttr_color	forElement:element]];
		NSString	*alpha	=								[TBXML valueOfAttributeNamed:kAttr_alpha	forElement:element];
		NSString	*align	=								[TBXML valueOfAttributeNamed:kAttr_textalign	forElement:element];
		NSString	*size	=								[TBXML valueOfAttributeNamed:kAttr_size		forElement:element];
		NSString	*x		=								[TBXML valueOfAttributeNamed:kAttr_x		forElement:element];
		NSString	*y		=								[TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
		NSString	*w		=								[TBXML valueOfAttributeNamed:kAttr_width	forElement:element];
		NSString	*h		=								[TBXML valueOfAttributeNamed:kAttr_height	forElement:element];
		
		CGRect			frame			= CGRectZero;
		UITextAlignment textAlignment	= ([titleMode isEqual:kTitleMode_peek] ? NSTextAlignmentRight : NSTextAlignmentLeft);
		BOOL			resize			= YES;
		UIColor			*bgColor		= nil;
		NSUInteger		textSize		= ([titleMode isEqual:kTitleMode_peek] ? DEFAULT_TEXTSIZE_TITLE_HEADING_PEEKMODE : DEFAULT_TEXTSIZE_TITLE_HEADING_NORMALMODE );
		NSString		*font			= ([titleMode isEqual:kTitleMode_peek] ? self.pageStyle.peekHeadingFontName : self.pageStyle.headingFontName);
		CGFloat			labelAlpha		= 1.0;
		
		//set values to attribute values or defaults
		if ([titleMode isEqual:kTitleMode_peek]) {
			//peek mode
			if		(x)										{frame.origin.x		= [x floatValue];}								else	{frame.origin.x		= 5;}
			if		(y)										{frame.origin.y		= [y floatValue];}								else	{frame.origin.y		= 10;}
			if		(w)										{frame.size.width	= [w floatValue];}								else	{frame.size.width	= CGRectGetWidth(containerFrame) / 4 - 2 * DEFAULT_TITLE_PEEKHEADING_PADDING - DEFAULT_TITLE_PEEKHEADING_LINE_WIDTH;}
			if		(h)										{frame.size.height	= [h floatValue];}								else	{frame.size.height	= 100;}
			if		((w != nil) && (h != nil))				{resize				= NO;}
			
		} else {
			if		(x)										{frame.origin.x		= [x floatValue];}								else	{frame.origin.x		= 55;}
			if		(y)										{frame.origin.y		= [y floatValue];}								else	{frame.origin.y		= 5;}
			if		(w)										{frame.size.width	= [w floatValue];}								else	{frame.size.width	= CGRectGetWidth(containerFrame) - 60;}
			if		(h)										{frame.size.height	= [h floatValue];}								else	{frame.size.height	= 150;}
			if		((w != nil) && (h != nil))				{resize				= NO;}
		}
		if		(!bgColor)																								{bgColor			= self.pageStyle.clearTitleBackgroundColor;}
		if		(!color)																								{color				= self.pageStyle.backgroundColor;}
		if		(size)									{textSize			= round(textSize * [size floatValue] / 100);}
		
		if (alpha) {
			labelAlpha = [alpha floatValue];
		}
		
		if (align) {
			if		([align isEqual:kAlignment_right])	{textAlignment		= NSTextAlignmentRight;}
			else if ([align isEqual:kAlignment_center])	{textAlignment		= NSTextAlignmentCenter;}
			else if ([align isEqual:kAlignment_left])	{textAlignment		= NSTextAlignmentLeft;}
		}
		
		if (titleMode) {
			if		([titleMode isEqual:kTitleMode_clear])		{bgColor			= self.pageStyle.clearTitleBackgroundColor;}
			else if ([titleMode isEqual:kTitleMode_straight])	{
				textAlignment=NSTextAlignmentCenter;
                UILabel *temp = [[GTLabel alloc] initWithFrame:frame
                                                    autoResize:resize
                                                          text:text
                                                         color:color
                                                       bgColor:bgColor
                                                         alpha:labelAlpha
                                                     alignment:textAlignment
                                                          font:font
                                                          size:textSize];
				frame = temp.frame;
				frame.origin.x		= 0;
				frame.size.width = containerFrame.size.width;
				temp.frame = frame;
				
				return temp;
			}
		}
		
        return [[GTLabel alloc] initWithFrame:frame
                                   autoResize:resize
                                         text:text
                                        color:color
                                      bgColor:bgColor
                                        alpha:labelAlpha
                                    alignment:textAlignment
                                         font:font
                                         size:textSize];
	} else {
		return nil;
	}
}

/**
 *	Description:	Creates a subheading view for the title
 *	Parameters:		Element:	The TBXMLElement for the subheading
 *					titleMode:	A NSString containing the specified title mode (straight, single, etc.)
 *	Returns:		A UIView object from the attributes specified in the passed TBXML element.
 */
- (id)createTitleSubheadingFromElement:(TBXMLElement *)element titleMode:(NSString *)titleMode containerFrame:(CGRect)containerFrame {
	//read attributes for title subheading
	NSString	*text	=								[TBXML textForElement:element];
	UIColor		*color	=	[GTPageStyle colorForHex:	[TBXML valueOfAttributeNamed:kAttr_color	forElement:element]];
	NSString	*alpha	=								[TBXML valueOfAttributeNamed:kAttr_alpha	forElement:element];
	NSString	*align	=								[TBXML valueOfAttributeNamed:kAttr_textalign	forElement:element];
	NSString	*size	=								[TBXML valueOfAttributeNamed:kAttr_size		forElement:element];
	NSString	*x		=								[TBXML valueOfAttributeNamed:kAttr_x		forElement:element];
	NSString	*y		=								[TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
	NSString	*w		=								[TBXML valueOfAttributeNamed:kAttr_width	forElement:element];
	NSString	*h		=								[TBXML valueOfAttributeNamed:kAttr_height	forElement:element];
	
	//init title parameters with defaults
	CGRect			frame			= CGRectZero;
	UITextAlignment textAlignment	= ([titleMode isEqual:kTitleMode_peek] ? NSTextAlignmentLeft : NSTextAlignmentCenter);
	BOOL			resize			= YES;
	UIColor			*bgColor		= nil;
	NSUInteger		textSize		= DEFAULT_TEXTSIZE_TITLE_SUBHEADING;
	NSString		*font			= ([titleMode isEqual:kTitleMode_peek] ? self.pageStyle.peekSubheadingFontName : self.pageStyle.subheadingFontName);
	CGFloat			labelAlpha		= 1.0;
	
	//check if xml attributes are specified,		if so,				use them.										if not,	use defaults
	if ([titleMode isEqual:kTitleMode_peek]) {
		//peek mode
		if		(x)										{frame.origin.x		= [x floatValue];}								else	{frame.origin.x		= CGRectGetWidth(containerFrame) / 4 + DEFAULT_TITLE_PEEKHEADING_PADDING;}
		if		(y)										{frame.origin.y		= [y floatValue];}								else	{frame.origin.y		= 0;}
		if		(w)										{frame.size.width	= [w floatValue];}								else	{frame.size.width	= CGRectGetWidth(containerFrame) * 3 / 4 - DEFAULT_TITLE_PEEKHEADING_PADDING - 31;}
		if		(h)										{frame.size.height	= [h floatValue];}								else	{frame.size.height	= 120;}
		if		((w != nil) && (h != nil))				{resize				= NO;}
	} else {
		if		(x)										{frame.origin.x		= [x floatValue];}								else	{frame.origin.x		= 0;}
		if		(y)										{frame.origin.y		= [y floatValue];}								else	{frame.origin.y		= 82;}
		if		(w)										{frame.size.width	= [w floatValue];}								else	{frame.size.width	= CGRectGetWidth(containerFrame);}
		if		(h)										{frame.size.height	= [h floatValue];}								else	{frame.size.height	= 23;}
		if		((w != nil) && (h != nil))				{resize				= NO;}
	}
	
	
	//Background Colour (clear)
	if		(!bgColor)								{bgColor			= self.pageStyle.clearTitleBackgroundColor;}
	
	//Text Colour (page's background colour)
	if		(!color)								{color				= self.pageStyle.backgroundColor;}
	
	//Text Size (percentage modifier)
	if		(size)									{textSize			= round(textSize * [size floatValue] / 100);}
	
	if (alpha) {
		labelAlpha = [alpha floatValue];
	}
	
	if (align) {
		if		([align isEqual:kAlignment_right])	{textAlignment		= NSTextAlignmentRight;}
		else if ([align isEqual:kAlignment_center])	{textAlignment		= NSTextAlignmentCenter;}
		else if ([align isEqual:kAlignment_left])	{textAlignment		= NSTextAlignmentLeft;}
	}
	
	//**added to remove multiple return points**	
    //Sets up the return data, the mode handling modifies this.
    UILabel *tempLabel = [[GTLabel alloc] initWithFrame:frame
                                             autoResize:resize
                                                   text:text
                                                  color:color
                                                bgColor:bgColor
                                                  alpha:labelAlpha
                                              alignment:textAlignment
                                                   font:font
                                                   size:textSize];
	
	//mode handling
	if (titleMode) {
		//clear
		if		([titleMode isEqual:kTitleMode_clear])	{
			bgColor			= self.pageStyle.clearTitleBackgroundColor;
			tempLabel.backgroundColor = self.pageStyle.clearTitleBackgroundColor;
		}
		//straight
		else if ([titleMode isEqual:kTitleMode_straight]) {
			textAlignment=NSTextAlignmentCenter;
			tempLabel.textAlignment = NSTextAlignmentCenter;
			//**CONFIRM REDUNDANCY**	UILabel *temp = [self createLabelWithFrame:frame autoResize:resize text:text color:color bgColor:bgColor alpha:labelAlpha alignment:textAlignment font:font size:textSize];
			frame = tempLabel.frame;
			frame.origin.x		= 0;
			frame.size.width = containerFrame.size.width;
			tempLabel.frame = frame;
			
			//**CONFIRM REDUNDANCY**	return temp;
		}
	}
	
	//**CONFIRM REDUNDANCY**	return [self createLabelWithFrame:frame autoResize:resize text:text color:color bgColor:bgColor alpha:labelAlpha alignment:textAlignment font:font size:textSize];
	return tempLabel;
}

@end
