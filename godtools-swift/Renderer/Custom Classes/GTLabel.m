//
//  GTLabel.m
//  GTViewController
//
//  Created by Ryan Carlson on 4/8/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TBXML.h"

#import "GTLabel.h"
#import "GTPageInterpreter.h"

@implementation GTLabel


- (instancetype)initWithElement:(TBXMLElement *)element parentTextAlignment:(UITextAlignment)panelAlign xPos:(CGFloat)xpostion yPos:(CGFloat)ypostion container:(UIView *)container style:(GTPageStyle *)style {
    
    if (!(ypostion >= 0)) {
        ypostion = DEFAULT_PANEL_OFFSET_Y;
    }
    
    if (element != nil) {
        
        //read attributes for label
        NSString	*text		=								[TBXML textForElement:element];
        NSString	*modifier	=								[TBXML valueOfAttributeNamed:kAttr_modifier forElement:element];
        UIColor		*color		=	[GTPageStyle colorForHex:	[TBXML valueOfAttributeNamed:kAttr_color	forElement:element]];
        NSString	*alpha		=								[TBXML valueOfAttributeNamed:kAttr_alpha	forElement:element];
        NSString	*align		=								[TBXML valueOfAttributeNamed:kAttr_align	forElement:element];
        NSString	*textalign	=								[TBXML valueOfAttributeNamed:kAttr_textalign	forElement:element];
        NSString	*size		=								[TBXML valueOfAttributeNamed:kAttr_size		forElement:element];
        NSString	*x			=								[TBXML valueOfAttributeNamed:kAttr_x		forElement:element];
        NSString	*y			=								[TBXML valueOfAttributeNamed:kAttr_y		forElement:element];
        NSString	*w			=								[TBXML valueOfAttributeNamed:kAttr_width	forElement:element];
        CGFloat    xTrailingOffset =                            round([[TBXML valueOfAttributeNamed:kAttr_xTrailingOff		forElement:element] floatValue]);
        NSString	*h			=								[TBXML valueOfAttributeNamed:kAttr_height	forElement:element];
        CGFloat		xoffset		=								round([[TBXML valueOfAttributeNamed:kAttr_xoff		forElement:element] floatValue]);
        CGFloat		yoffset		=								round([[TBXML valueOfAttributeNamed:kAttr_yoff		forElement:element] floatValue]);
        
        //init variables for object parameters
        CGRect			frame			= CGRectZero;
        UITextAlignment textAlignment	= panelAlign;
        BOOL			resize			= YES;
        UIColor			*bgColor		= nil;
        NSUInteger		textSize		= DEFAULT_TEXTSIZE_LABEL;
        NSString		*font			= style.labelFontName;
        CGFloat			labelAlpha		= 1.0;
        
        //set parameters to attribute val or defaults	//attribute value															//default value
        //note: these defaults only apply to text labels inside panels
        if (x) {
            frame.origin.x = round([x floatValue]);
        } else {
            frame.origin.x = DEFAULT_X_LABEL;
        }
        
        if (y) {
            frame.origin.y = round([y floatValue]);
        } else {
            frame.origin.y = ypostion;
        }
        
        if (xoffset && xTrailingOffset) {
            frame.size.width = container.frame.size.width - xoffset - xTrailingOffset;
        } else if (w) {
            frame.size.width =	round([w floatValue]);
        } else {
            frame.size.width = (container ? container.frame.size.width - (2 * DEFAULT_X_LABEL) : 280);
        }
        
        if (h) {
            frame.size.height =	round([h floatValue]);
        } else {
            frame.size.height = DEFAULT_HEIGHT_LABEL;
        }
        
        if ((w != nil) && (h != nil)) {
            resize = NO;
        }
        
        if (!bgColor) {
            bgColor = style.defaultLabelBackgroundColor;
        }
        
        if (!color) {
            color = style.defaultTextColor;
        }
        
        if (size) {
            textSize = round(textSize * [size floatValue] / 100);
        }
        
        //if alignment is found calculate position based on alignment
        if ([align isEqualToString:kAlignment_left]) {
            
            frame.origin.x = DEFAULT_X_LABEL;
            
        } else if ([align isEqualToString:kAlignment_center]) {
            
            frame.origin.x = ( 0.5 * container.frame.size.width ) - ( 0.5 * frame.size.width );
            
        } else if ([align isEqualToString:kAlignment_right]) {
            
            frame.origin.x = container.frame.size.width - frame.size.width - DEFAULT_X_LABEL;
            
        }
        
        //apply offset
        frame.origin.x += xoffset;
        frame.origin.y += yoffset;

        if (alpha) {
            labelAlpha = [alpha floatValue];
        }
        
        if (modifier) {
            if		([modifier isEqual:kLabelModifer_bold])			{font		= style.boldLabelFontName;}
            else if	([modifier isEqual:kLabelModifer_italics])		{font		= style.italicsLabelFontName;}
            else if	([modifier isEqual:kLabelModifer_bolditalics])	{font		= style.boldItalicsLabelFontName;}
        }
        
        if (textalign) {
            if		([textalign isEqual:kAlignment_right])	{textAlignment		= NSTextAlignmentRight;}
            else if ([textalign isEqual:kAlignment_center])	{textAlignment		= NSTextAlignmentCenter;}
            else if ([textalign isEqual:kAlignment_left])	{textAlignment		= NSTextAlignmentLeft;}
        }
        
        
        return [self initWithFrame:frame autoResize:resize text:text color:color bgColor:bgColor alpha:labelAlpha alignment:textAlignment font:font size:textSize];
        
    } else {
        return nil;
    }
}

//Returns a label given label attributes
- (GTLabel *)initWithFrame:(CGRect)frame autoResize:(BOOL)resize text:(NSString *)text color:(UIColor *)color bgColor:(UIColor *)bgColor alpha:(CGFloat)alpha alignment:(UITextAlignment)textAlignment font:(NSString *)font size:(NSUInteger)size {
    GTLabel *tempLabel = [[GTLabel alloc] initWithFrame:frame];
    
    //Colors
    [tempLabel setBackgroundColor:bgColor];
    [tempLabel setTextColor:color];
    
    //Set Alpha
    if (alpha < 1) {
        [tempLabel setOpaque:NO];
        [tempLabel setAlpha:alpha];
    }
    
    //Text & Formatting
    [tempLabel setText:text];
    [tempLabel setFont:[UIFont fontWithName:font size:size]];
    [tempLabel setTextAlignment:textAlignment];
    [tempLabel setLineBreakMode:NSLineBreakByWordWrapping];
    
    //Size
    [tempLabel setNumberOfLines:0];
    if (resize) {
        [tempLabel sizeToFit];
    }
    
    //Reset width to fill the width available
    [tempLabel setFrame:CGRectMake(tempLabel.frame.origin.x, tempLabel.frame.origin.y, frame.size.width, tempLabel.frame.size.height)];
    
    return tempLabel;
}
@end
