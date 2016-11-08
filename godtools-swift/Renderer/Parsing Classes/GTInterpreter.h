//
//  GTInterpreter.h
//  Snuffy
//
//  Created by Michael Harrison on 4/16/14.
//
//

#import <Foundation/Foundation.h>
#import "GTFileLoader.h"
#import "UISnuffleButton.h"
#import "UIRoundedView.h"

@protocol GTInterpreterDelegate;

@interface GTInterpreter : NSObject

@property (nonatomic, weak) id<GTInterpreterDelegate> delegate;
@property (nonatomic, weak) id<UIRoundedViewTapDelegate> panelDelegate;
@property (nonatomic, weak) id<UISnuffleButtonTapDelegate> buttonDelegate;

+ (instancetype)interpreterWithXMLPath:(NSString *)xmlPath fileLoader:(GTFileLoader *)fileLoader pageView:(UIView *)view delegate:(id<GTInterpreterDelegate>)delegate panelTapDelegate:(id<UIRoundedViewTapDelegate>)panelDelegate buttonTapDelegate:(id<UISnuffleButtonTapDelegate>)buttonDelegate;

//render elements on page from xml representation
- (void)renderPage;
- (void)renderButtonsOnPage;
- (void)renderPanelOnPageForButtonTag:(NSInteger)tag;

//get object from xml
- (NSMutableArray *)arrayWithUrls;
- (UIImageView *)watermark;

//cache functions
- (void)cacheImages;

@end

@protocol GTInterpreterDelegate <NSObject>

@optional
- (void)registerListenerWithEventName:(NSString *)eventName target:(id)target selector:(SEL)selector parameter:(id)parameter;


@end