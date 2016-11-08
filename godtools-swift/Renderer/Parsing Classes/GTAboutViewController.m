//
//  AboutViewController.m
//  Snuffy
//
//  Created by Michael Harrison on 4/08/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "GTAboutViewController.h"
#import	"GTPage.h"

@interface GTAboutViewController () <UIActionSheetDelegate, GTPageDelegate>

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
	
	//	UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:website]]
	//																			 applicationActivities:nil];
	//
	//	controller.excludedActivityTypes	= @[UIActivityTypePostToWeibo,
	//											UIActivityTypePrint,
	//											UIActivityTypeAssignToContact,
	//											UIActivityTypeSaveToCameraRoll,
	//											UIActivityTypePostToFlickr,
	//											UIActivityTypePostToVimeo,
	//											UIActivityTypePostToTencentWeibo,
	//											UIActivityTypeAirDrop];
	//
	//	[self.navigationController presentViewController:controller animated:YES completion:nil];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:url.absoluteString
															 delegate:self
													cancelButtonTitle:[self.fileLoader localizedString:@"GTViewController_urlButton_cancel"]
											   destructiveButtonTitle:nil
													otherButtonTitles:[self.fileLoader localizedString:@"GTViewController_urlButton_open"], [self.fileLoader localizedString:@"GTViewController_urlButton_email"], [self.fileLoader localizedString:@"GTViewController_urlButton_copy"], nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	
	[actionSheet showInView:self.view];
	
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
	
	self.allURLsButtonArray	= urlArray;
	
	// open a dialog with two custom buttons
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[self.fileLoader localizedString:@"GTViewController_allUrlsButton_title"]
															 delegate:self
													cancelButtonTitle:[self.fileLoader localizedString:@"GTViewController_allUrlsButton_cancel"]
											   destructiveButtonTitle:nil
													otherButtonTitles:[self.fileLoader localizedString:@"GTViewController_allUrlsButton_email"], [self.fileLoader localizedString:@"GTViewController_allUrlsButton_copy"], nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	
	[actionSheet showInView:self.view];
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if ([[actionSheet title] isEqual:[self.fileLoader localizedString:@"GTViewController_allUrlsButton_title"]]) {
		switch (buttonIndex) {
			case 0://email
				[self emailAllLinks];
				break;
			case 1://copy
				   //[self copyAllLinks];
				break;
			default:
				break;
		}
	} else {
		switch (buttonIndex) {
			case 0://open
				[self openInSafari:[actionSheet title]];
				break;
			case 1://email
				[self emailLink:[actionSheet title]];
				break;
			case 2://copy
				[self copyLink:[actionSheet title]];
				break;
			default:
				break;
		}
	}
	
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
