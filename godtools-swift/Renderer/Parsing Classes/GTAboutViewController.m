//
//  AboutViewController.m
//  Snuffy
//
//  Created by Michael Harrison on 4/08/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "GTAboutViewController.h"
#import	"GTPage.h"

@interface GTAboutViewController () <GTPageDelegate>

@property (nonatomic, strong) GTPage					*aboutPage;
@property (nonatomic, strong) id<GTAboutViewControllerDelegate>	aboutDelegate;
@property (nonatomic, strong) GTFileLoader				*fileLoader;
@property (nonatomic, strong) NSString					*filename;
@property (nonatomic, weak  ) IBOutlet UILabel          *share;
@property (nonatomic, weak  ) IBOutlet UINavigationBar  *navigationBar;
@property (nonatomic, weak  ) IBOutlet UIScrollView     *scrollView;

@property (nonatomic, strong) NSArray *allURLsButtonArray;

- (IBAction)dismissAbout:(id)sender;

- (void)emailLink:(NSString *)website;
- (void)copyLink:(NSString *)website;
- (void)openInSafari:(NSString *)website;
- (void)emailAllLinks;
- (void)copyAllLinks;

@end

@implementation GTAboutViewController

- (instancetype)initWithDelegate:(id<GTAboutViewControllerDelegate>)delegate fileLoader:(GTFileLoader *)fileLoader {
	
	self = [super init];
	
	if (self) {
		
		self.aboutDelegate	= delegate;
		self.fileLoader		= fileLoader;
		
	}
	
    return self;
}

- (void)loadAboutPageWithFilename:(NSString *)filename {
	
	self.filename	= filename;
	
}

-(IBAction)dismissAbout:(id)sender {
	
	[self dismissViewControllerAnimated:YES completion:nil];
    
	if ([self.aboutDelegate respondsToSelector:@selector(hideNavToolbar)]) {
		
		[self.aboutDelegate hideNavToolbar];
		
	}
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
    
	//if the filename has been set by the initializer but has not been rendered and saved in self.aboutPage then render it.
	if (self.filename && !self.aboutPage) {
		
		[self loadAboutPageWithFilename:self.filename];
		
	}
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.aboutPage.superview) {
		[self.aboutPage removeFromSuperview];
	}
	
	CGRect parentFrame = self.aboutDelegate.viewOfPageViewController.frame;
	self.aboutPage	= [[GTPage alloc] initWithFilename:self.filename frame:parentFrame delegate:self fileLoader:self.fileLoader];
	self.scrollView.backgroundColor = self.aboutPage.backgroundColor;
	self.navigationBar.tintColor = self.aboutPage.backgroundColor;
	[self.scrollView addSubview:self.aboutPage];
	[self.aboutPage viewHasTransitionedIn];
	
	//dynamically grab scroll hieght
	CGFloat maxheight = 0;
	for (UIView *subview in self.aboutPage.subviews) {
		maxheight = fmax(maxheight, CGRectGetMaxY(subview.frame));
	}
	self.aboutPage.frame = CGRectMake(0, 0, parentFrame.size.width, maxheight + 10);
	[self.scrollView setContentSize:CGSizeMake(parentFrame.size.width, maxheight + 10)];
	
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - GTPageDelegate

- (UIView *)viewOfPageViewController {
	
	return self.aboutDelegate.viewOfPageViewController;
}

- (void)page:(GTPage *)page didReceiveTapOnURL:(NSURL *)url {
    __weak typeof (self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:url.absoluteString
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:[self.fileLoader localizedString:@"GTViewController_urlButton_copy"]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [weakSelf copyLink:alertController.title];
                                                       }];
    
    UIAlertAction *emailAction = [UIAlertAction actionWithTitle:[self.fileLoader localizedString:@"GTViewController_urlButton_email"]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [weakSelf emailLink:alertController.title];
                                                        }];
    
    UIAlertAction *openAction = [UIAlertAction actionWithTitle:[self.fileLoader localizedString:@"GTViewController_urlButton_open"]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [weakSelf openInSafari:alertController.title];
                                                       }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[self.fileLoader localizedString:@"GTViewController_urlButton_cancel"]
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [weakSelf dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    
    [alertController addAction:copyAction];
    [alertController addAction:emailAction];
    [alertController addAction:openAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)page:(GTPage *)page didReceiveTapOnPhoneNumber:(NSString *)phoneNumber {
	
	NSString *phoneNumberString = [@"tel:" stringByAppendingString:phoneNumber];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumberString]];
	
}

- (void)page:(GTPage *)page didReceiveTapOnEmailAddress:(NSString *)emailAddress {
	
	NSString *emailString = [@"mailto:" stringByAppendingString:emailAddress];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailString]];
	
}

- (void)page:(GTPage *)page didReceiveTapOnAllUrls:(NSArray *)urlArray {
    __weak typeof (self) weakSelf = self;
    
    self.allURLsButtonArray	= urlArray;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[self.fileLoader localizedString:@"GTViewController_allUrlsButton_title"]
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *emailAction = [UIAlertAction actionWithTitle:[self.fileLoader localizedString:@"GTViewController_allUrlsButton_email"]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [weakSelf emailAllLinks];
                                                        }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[self.fileLoader localizedString:@"GTViewController_allUrlsButton_cancel"]
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [weakSelf dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    
    [alertController addAction:emailAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)emailLink:(NSString *)website {
	NSString *emailString = [[NSString alloc] initWithFormat:@"mailto:?subject=%@&body=http://%@", [self.fileLoader localizedString:@"GTViewController_shareEmail_subject"], website];
	NSString *escaped = [emailString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:escaped]];
}

-(void)copyLink:(NSString *)website {
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	pasteboard.string = website;
}

-(void)openInSafari:(NSString *)website {
	NSString *urlString = website	= ( [website hasPrefix:@"http"] ?
									   website :
									   [@"http://" stringByAppendingString:website] );
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

-(void)emailAllLinks {
    NSArray	*array					  = self.allURLsButtonArray;
    NSMutableString	*websiteString    = [NSMutableString string];
    NSUInteger i, count               = [array count];
	
	for (i = 0; i < count; i++) {
		NSObject * dictObj = [array objectAtIndex:i];
		[websiteString appendFormat:@"%@ - http://%@,\n", [dictObj valueForKey:@"title"],[dictObj valueForKey:@"url"]];
	}
	
	NSString *emailString = [[NSString alloc] initWithFormat:@"mailto:?subject=%@&body=%@", [self.fileLoader localizedString:@"GTViewController_shareAllEmail_subject"], [websiteString substringFromIndex:0]];
	NSString *escaped = [emailString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:escaped]];
}

-(void)copyAllLinks {
	
    UIPasteboard *pasteboard          = [UIPasteboard generalPasteboard];
    NSArray	*array					  = self.allURLsButtonArray;
    NSMutableString	*websiteString    = [NSMutableString string];
    NSUInteger i, count               = [array count];
	
	for (i = 0; i < count; i++) {
		NSObject * dictObj = [array objectAtIndex:i];
		[websiteString appendFormat:@"http://%@\n", [dictObj valueForKey:@"url"]];
	}
	
	pasteboard.string = websiteString;
}

@end
