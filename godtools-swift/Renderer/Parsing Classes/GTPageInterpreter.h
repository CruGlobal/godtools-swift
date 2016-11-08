//
//  XMLParser.h
//  Snuffy
//
//  Created by Tom Flynn on 8/10/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "GTInterpreter.h"

#import "GTInterpreter+init.h"

//////////Compiler Constants///////////
#define DEFAULTOFFSET 10.0
#define DEFAULT_PANEL_OFFSET_X 0.0
#define DEFAULT_PANEL_OFFSET_Y 5.0
#define DEFAULT_QUESTION_OFFSET_X 0.0
#define DEFAULT_QUESTION_OFFSET_Y 0
#define DEFAULTOFFSET 10.0
#define BUTTONXOFFSET 10
#define	LARGEBUTTONXOFFSET 20
#define DROPSHADOW_INSET 10.0
#define ROUNDRECT_RADIUS 10.0
#define	DROPSHADOW_LENGTH 30.0
#define DROPSHADOW_SUBLENGTH 20.0

#define DEFAULT_TEXTSIZE_LABEL 17.0
#define DEFAULT_TEXTSIZE_BUTTON 20.0
#define DEFAULT_TEXTSIZE_QUESTION_NORMAL 20.0
#define DEFAULT_TEXTSIZE_QUESTION_STRAIGHT 17.0
#define DEFAULT_TEXTSIZE_TITLE_PEEKHEADING_MAX 30
#define DEFAULT_TEXTSIZE_TITLE_PEEKHEADING_MIN 6
#define DEFAULT_TEXTSIZE_TITLE_SUBHEADING 17
#define DEFAULT_TITLE_PEEKHEADING_MIN_HEIGHT 68
#define DEFAULT_TITLE_PEEKHEADING_PADDING 5
#define DEFAULT_TITLE_PEEKHEADING_LINE_WIDTH 2
#define DEFAULT_TEXTSIZE_TITLE_NUMBER 68
#define DEFAULT_TEXTSIZE_TITLE_HEADING_PEEKMODE 30
#define DEFAULT_TEXTSIZE_TITLE_HEADING_NORMALMODE 17

#define DEFAULT_X_LABEL 10.0

#define DEFAULT_HEIGHT_LABEL 40.0
#define DEFAULT_HEIGHT_INPUTFIELD 25.0
#define DEFAULT_HEIGHT_INPUTFIELDLABEL 30.0
#define DEFAULT_HEIGHT_BUTTONPAIR 40.0
#define DEFAULT_HEIGHT_BUTTON 36.0
#define DEFAULT_HEIGHT_URLBUTTON 50.0
#define DEFAULT_HEIGHT_BIGBUTTON 136.0
#define DEFAULT_HEIGHT_ALLURLBUTTON 36.0
#define DEFAULT_HEIGHT_LINKBUTTON 40.0

#define BASE_TAG_INPUTFIELDTEXT 3580

//////////Run-Time Constants///////////

// Constants for the XML element names that will be considered during the parse.
extern NSString * const kName_Title;
extern NSString * const kName_TitleNumber;
extern NSString * const kName_TitleHeading;
extern NSString * const kName_TitleSubHeading;
extern NSString * const kName_TitlePeek;
extern NSString * const kName_Button;
extern NSString * const kName_ButtonText;
extern NSString * const kName_LinkButton;
extern NSString * const kName_Label;
extern NSString * const kName_Image;
extern NSString * const kName_Panel;
extern NSString * const kName_PanelLabel;
extern NSString * const kName_PanelImage;
extern NSString * const kName_Question;

// Constants for the follow up modal elements added in v7.0.x of this Pod
extern NSString * const kName_Button_Pair;
extern NSString * const kName_Positive_Button;
extern NSString * const kName_Negative_Button;
extern NSString * const kName_Followup_Modal;

extern NSString * const kName_FollowUp_Title;
extern NSString * const kName_FollowUp_Body;
extern NSString * const kName_Input_Field;
extern NSString * const kName_Input_Label;
extern NSString * const kName_Input_Placeholder;
extern NSString * const kName_Thank_You;

// Constants for the XML attribute names
extern NSString * const kAttr_backgroundImage;
extern NSString * const kAttr_numOfButtons;
extern NSString * const kAttr_numOfBigButtons;
extern NSString * const kAttr_mode;
extern NSString * const kAttr_shadows;
extern NSString * const kAttr_watermark;

extern NSString * const kAttr_color;
extern NSString * const kAttr_alpha;
extern NSString * const kAttr_textalign;
extern NSString * const kAttr_align;
extern NSString * const kAttr_size;
extern NSString * const kAttr_x;
extern NSString * const kAttr_y;
extern NSString * const kAttr_width;
extern NSString * const kAttr_height;

// Constants for XML attributes for follow up modal, events and listeners added in v7.0.x of this pod
extern NSString * const kAttr_tap_events;
extern NSString * const kAttr_followup_id;
extern NSString * const kAttr_context_id;
extern NSString * const kAttr_validation;
extern NSString * const kAttr_validFormat;
extern NSString * const kAttr_name;
extern NSString * const kAttr_listeners;
extern NSString * const kAttr_type;

extern NSString * const kAttr_yoff;
extern NSString * const kAttr_xoff;
extern NSString * const kAttr_xTrailingOff;
extern NSString * const kAttr_modifier;

extern NSString * const kAttr_urlText;

//text alignment constants
extern NSString * const kAlignment_left;
extern NSString * const kAlignment_center;
extern NSString * const kAlignment_right;

//title mode constants
extern NSString * const kTitleMode_plain;
extern NSString * const kTitleMode_singlecurve;
extern NSString * const kTitleMode_doublecurve;
extern NSString * const kTitleMode_straight;
extern NSString * const kTitleMode_clear;

//title mode constants
extern NSString * const kTitleMode_peek;

//button mode constants
extern NSString * const kButtonMode_big;
extern NSString * const kButtonMode_url;
extern NSString * const kButtonMode_phone;
extern NSString * const kButtonMode_email;
extern NSString * const kButtonMode_allurl;
extern NSString * const kButtonMode_link;

//label modifer constants
extern NSString * const kLabelModifer_normal;
extern NSString * const kLabelModifer_bold;
extern NSString * const kLabelModifer_italics;
extern NSString * const kLabelModifer_bolditalics;

//input field type constants
extern NSString * const kInputFieldType_email;
extern NSString * const kInputFieldType_text;

@interface GTPageInterpreter : GTInterpreter


@end
