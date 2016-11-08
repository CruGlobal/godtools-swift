//
//  GTPageStyleAmharic.m
//  GTViewController
//
//  Created by Michael Harrison on 10/5/15.
//  Copyright © 2015 Michael Harrison. All rights reserved.
//

#import "GTPageStyleAmharic.h"

NSString * const  GTPageInterpreterAmharicFont_number			= @"AbyssinicaSIL";
NSString * const  GTPageInterpreterAmharicFont_heading			= @"NotoSansEthiopic-Bold";//default
NSString * const  GTPageInterpreterAmharicFont_subheading		= @"AbyssinicaSIL";
NSString * const  GTPageInterpreterAmharicFont_peekheading		= @"AbyssinicaSIL";
NSString * const  GTPageInterpreterAmharicFont_peeksubheading	= @"NotoSansEthiopic";
NSString * const  GTPageInterpreterAmharicFont_peekpanel		= @"NotoSansEthiopic";
NSString * const  GTPageInterpreterAmharicFont_question			= @"NotoSansEthiopic-Bold";
NSString * const  GTPageInterpreterAmharicFont_straightquestion	= @"NotoSansEthiopic-Bold";
NSString * const  GTPageInterpreterAmharicFont_instructions		= @"NotoSansEthiopic-Bold";
NSString * const  GTPageInterpreterAmharicFont_label			= @"NotoSansEthiopic";
NSString * const  GTPageInterpreterAmharicFont_boldlabel		= @"NotoSansEthiopic-Bold";
NSString * const  GTPageInterpreterAmharicFont_italicslabel		= @"NotoSansEthiopic";
NSString * const  GTPageInterpreterAmharicFont_bolditalicslabel	= @"NotoSansEthiopic-Bold";

@implementation GTPageStyleAmharic

- (NSString *)numberFontName {
	return GTPageInterpreterAmharicFont_number;
}

- (NSString *)headingFontName {
	return GTPageInterpreterAmharicFont_heading;
}

- (NSString *)subheadingFontName {
	return GTPageInterpreterAmharicFont_subheading;
}

- (NSString *)peekHeadingFontName {
	return GTPageInterpreterAmharicFont_peekheading;
}

- (NSString *)peekSubheadingFontName {
	return GTPageInterpreterAmharicFont_peeksubheading;
}

- (NSString *)peekPanelFontName {
	return GTPageInterpreterAmharicFont_peekpanel;
}

- (NSString *)questionFontName {
	return GTPageInterpreterAmharicFont_question;
}

- (NSString *)straightQuestionFontName {
	return GTPageInterpreterAmharicFont_straightquestion;
}

- (NSString *)instructionsFontName {
	return GTPageInterpreterAmharicFont_instructions;
}

- (NSString *)labelFontName {
	return GTPageInterpreterAmharicFont_label;
}

- (NSString *)boldLabelFontName {
	return GTPageInterpreterAmharicFont_boldlabel;
}

- (NSString *)italicsLabelFontName {
	return GTPageInterpreterAmharicFont_italicslabel;
}

- (NSString *)boldItalicsLabelFontName {
	return GTPageInterpreterAmharicFont_bolditalicslabel;
}

@end
