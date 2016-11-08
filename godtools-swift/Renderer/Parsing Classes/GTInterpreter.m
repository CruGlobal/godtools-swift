//
//  GTInterpreter.m
//  Snuffy
//
//  Created by Michael Harrison on 4/16/14.
//
//

#import "GTInterpreter.h"

#import "GTPageInterpreter.h"
#import "GTPageStyle.h"
#import "GTPageStyleAmharic.h"

@implementation GTInterpreter

+ (instancetype)interpreterWithXMLPath:(NSString *)xmlPath fileLoader:(GTFileLoader *)fileLoader pageView:(UIView *)view delegate:(id<GTInterpreterDelegate>)delegate panelTapDelegate:(id<UIRoundedViewTapDelegate>)panelDelegate buttonTapDelegate:(id<UISnuffleButtonTapDelegate>)buttonDelegate{
	
	GTPageStyle *pageStyle;
	
	if ([fileLoader.language isEqualToString:@"am-ET"]) {
		
		pageStyle = [[GTPageStyleAmharic alloc] init];
		
	} else {
		
		pageStyle = [[GTPageStyle alloc] init];
		
	}
	
	return [[GTPageInterpreter alloc] initWithXMLPath:xmlPath fileLoader:fileLoader pageStyle:pageStyle pageView:view delegate:delegate panelTapDelegate:panelDelegate buttonTapDelegate:buttonDelegate];
}

//render elements on page from xml representation
- (void)renderPage {}
- (void)renderButtonsOnPage {}
- (void)renderPanelOnPageForButtonTag:(NSInteger)tag {}

//get object from xml
- (NSMutableArray *)arrayWithUrls { return nil; }
- (UIImageView *)watermark { return nil; }

//cache functions
- (void)cacheImages {}

@end
