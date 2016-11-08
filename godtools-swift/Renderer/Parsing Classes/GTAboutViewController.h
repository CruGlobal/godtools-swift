//
//  AboutViewController.h
//  Snuffy
//
//  Created by Michael Harrison on 4/08/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTFileLoader.h"

@protocol GTAboutViewControllerDelegate;

@interface GTAboutViewController : UIViewController

@property (nonatomic, weak  ) IBOutlet UINavigationItem *navigationTitle;

- (instancetype)initWithDelegate:(id<GTAboutViewControllerDelegate>)delegate fileLoader:(GTFileLoader *)fileLoader;
- (void)loadAboutPageWithFilename:(NSString *)filename;

@end


@protocol GTAboutViewControllerDelegate <NSObject>

- (UIView *)viewOfPageViewController;

@optional
- (void)hideNavToolbar;

@end