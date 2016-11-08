//
//  GTPageStyle.m
//  GTViewController
//
//  Created by Michael Harrison on 10/5/15.
//  Copyright © 2015 Michael Harrison. All rights reserved.
//

#import "GTPageStyle.h"

//font constants
NSString * const kFont_number			= @"STHeitiTC-Light";
NSString * const kFont_heading			= @"Helvetica-Bold";//default
NSString * const kFont_subheading		= @"STHeitiSC-Medium";
NSString * const kFont_peekheading		= @"STHeitiTC-Light";
NSString * const kFont_peeksubheading	= @"Helvetica";
NSString * const kFont_peekpanel		= @"HelveticaNeue-BoldItalic";
NSString * const kFont_question			= @"Helvetica-BoldOblique";
NSString * const kFont_straightquestion	= @"Helvetica-Bold";
NSString * const kFont_label			= @"Helvetica";
NSString * const kFont_boldlabel		= @"Helvetica-Bold";
NSString * const kFont_italicslabel		= @"Helvetica-Oblique";
NSString * const kFont_bolditalicslabel	= @"Helvetica-BoldOblique";

@implementation GTPageStyle

- (instancetype)init {
	
	self = [super init];
	if (self) {
		self.backgroundColor = [UIColor yellowColor];
		self.defaultTextColor = [UIColor whiteColor];
		self.straightQuestionBackgroundColor = [UIColor whiteColor];
		self.backgroundColor = [UIColor whiteColor];
		self.defaultTextColor = [UIColor whiteColor];
		self.defaultLabelBackgroundColor = [UIColor clearColor];
		self.defaultTitleBackgroundColor = [UIColor whiteColor];
		self.straightQuestionBackgroundColor = [UIColor whiteColor];
		self.clearTitleBackgroundColor = [UIColor clearColor];
		self.plainTitleBackgroundColor = [UIColor whiteColor];
		self.straightTitleBackgroundColor = [UIColor whiteColor];
		self.singleCurveTitleBackgroundColor = [UIColor whiteColor];
		self.subTitleBackgroundColor = [UIColor whiteColor];
	}
	return self;
}

/**
 *	Description:	Takes a hex string and returns a UIColor object that represents that hex color
 *	Parameters:		hexColor - NSString that is the hex representation of that desired color
 *	Returns:		A UIColor with those r, g, b and alpha values in hexColor
 */
+ (UIColor *)colorForHex:(NSString *)hexColor {
	if (hexColor) {
		unsigned long long rgbValue;
		hexColor = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
		
		// strip # if it appears
		if ([hexColor hasPrefix:@"#"]) {
			hexColor = [hexColor substringFromIndex:1];
		}
		
		// String should be 6 characters or 8 characters with an alpha component
		if (!([hexColor length] == 6 || [hexColor length] == 8)) {
			return nil;
		}
		
		//parse the string WITHOUT an alpha component and return the coresponding UIColor
		if ([hexColor length] == 6) {
			[[NSScanner scannerWithString:hexColor] scanHexLongLong:&rgbValue];
			
			return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
								   green:((float)((rgbValue & 0xFF00) >> 8))/255.0
									blue:((float)(rgbValue & 0xFF))/255.0
								   alpha:1.0];
			
			//parse the string WITH an alpha component and return the coresponding UIColor
		} else if ([hexColor length] == 8) {
			[[NSScanner scannerWithString:hexColor] scanHexLongLong:&rgbValue];
			
			return [UIColor colorWithRed:((float)((rgbValue & 0xFF000000) >> 32))/255.0
								   green:((float)((rgbValue & 0xFF0000) >> 16))/255.0
									blue:((float)((rgbValue & 0xFF00) >> 8))/255.0
								   alpha:((float)(rgbValue & 0xFF))/255.0];
		} else {
			return nil;
		}
		
		
	} else {
		return nil;
	}
	
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
	if (backgroundColor) {
		[self willChangeValueForKey:@"backgroundColor"];
		_backgroundColor = backgroundColor;
		[self didChangeValueForKey:@"backgroundColor"];
	}
}

- (NSString *)numberFontName {
	return kFont_number;
}

- (NSString *)headingFontName {
	return kFont_heading;
}

- (NSString *)subheadingFontName {
	return kFont_subheading;
}

- (NSString *)peekHeadingFontName {
	return kFont_peekheading;
}

- (NSString *)peekSubheadingFontName {
	return kFont_peeksubheading;
}

- (NSString *)peekPanelFontName {
	return kFont_peekpanel;
}

- (NSString *)questionFontName {
	return kFont_question;
}

- (NSString *)straightQuestionFontName {
	return kFont_straightquestion;
}

- (NSString *)labelFontName {
	return kFont_label;
}

- (NSString *)boldLabelFontName {
	return kFont_boldlabel;
}

- (NSString *)italicsLabelFontName {
	return kFont_italicslabel;
}

- (NSString *)boldItalicsLabelFontName {
	return kFont_bolditalicslabel;
}


@end
