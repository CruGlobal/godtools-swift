//
//  FileLoader.m
//  Snuffy
//
//  Created by Tom Flynn on 12/11/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import "GTFileLoader.h"

NSString * const GTViewControllerBundleName = @"GTViewController.bundle";

@interface GTFileLoader ()

@property (nonatomic, strong)	NSMutableDictionary	*imageCache;

- (NSString *)findPathForFileWithFilename:(NSString *)filename;
- (NSString *)filenameForDevicesResolutionWith:(NSString *)filename;

- (UIImage *)imageWithPath:(NSString *)path;

+ (BOOL)isRetina;

@end

@implementation GTFileLoader

@synthesize bundle = _bundle;

#pragma mark - initialization methods

+ (instancetype)sharedInstance {
    
    static GTFileLoader *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance					= [[GTFileLoader alloc] init];
        
    });
    
    return sharedInstance;
    
}

+ (instancetype)fileLoader {
    
    return [[GTFileLoader alloc] init];
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.imageCache					= [NSMutableDictionary dictionary];
        
    }
    
    return self;
}

#pragma mark - getter and setter methods

- (NSBundle *)bundle {
	
	if (!_bundle) {
		
		//NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:GTViewControllerBundleName];
		//_bundle = [NSBundle bundleWithPath:path];
		_bundle = [NSBundle mainBundle];
		
	}
	
	return _bundle;
}

#pragma mark - path methods

- (NSString *)pathOfPackagesDirectory {
    return [[NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"] stringByAppendingPathComponent:@"Packages"];
}

- (NSString *)pathOfConfigFile {
    
    return [self pathOfFileWithFilename:[self.language stringByAppendingString:@".xml"]];
}

- (NSString *)pathOfFileWithFilename:(NSString *)filename {
    
    NSString *devspecfilename	= [self filenameForDevicesResolutionWith:filename];
    NSString *path				= [self findPathForFileWithFilename:devspecfilename];
    
    if (!path) {
        path	= [self findPathForFileWithFilename:filename];
    }
    
    return path;
}

- (NSString *)findPathForFileWithFilename:(NSString *)filename {
    
    NSString *path = [self.pathOfPackagesDirectory stringByAppendingPathComponent:filename];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = [self.pathOfPackagesDirectory	stringByAppendingPathComponent:filename];
    }
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		path = [self.bundle pathForResource:[filename stringByDeletingPathExtension]
									 ofType:[filename pathExtension]]; //will return nil if it doesn't exist
	}
	
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = [[NSBundle mainBundle] pathForResource:[filename stringByDeletingPathExtension]
                                               ofType:[filename pathExtension]]; //will return nil if it doesn't exist
    }
    
    return path;
}

#pragma mark - string methods

- (NSString *)localizedString:(NSString *)key {
	
	return NSLocalizedStringFromTableInBundle(key, @"GTViewController", self.bundle, nil);
}

#pragma mark - image methods

- (UIImage *)imageWithFilename:(NSString *)filename {
    
    NSString	*path	= [self pathOfFileWithFilename:filename];
    if(!path)
        return nil;
    UIImage		*image	= self.imageCache[path];
    if (!image) {
        image = [UIImage imageWithContentsOfFile:path];
        self.imageCache[path]	= image;
    }
    
    return image;
}

#pragma mark - cache methods

- (void)cacheImageWithFileName:(NSString *)filename {
    
    NSString *path = [self pathOfFileWithFilename:filename];
    
    if (!self.imageCache[path]) {
        UIImage *image			= [UIImage imageWithContentsOfFile:path];
        self.imageCache[path]	= image;
    }
    
}

- (UIImage *)imageWithPath:(NSString *)path {
    
    UIImage		*image	= self.imageCache[path];
    
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:path];
        self.imageCache[path] = image;
    }
    
    return image;
}

- (void)clearCache {
    [self.imageCache removeAllObjects];
}

#pragma mark - misc methods

+ (BOOL)isRetina {
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0)) {
        return YES;
    } else {
        return NO;
    }
    
}

- (NSString *)filenameForDevicesResolutionWith:(NSString *)filename {
    
    //is it an iPhone4 (ie retina display) and
    //the image file is not a hi-res image already
    //if([deviceType isEqualToString:@"iPhone3,1"] && [filename rangeOfString:@"@2x"].location == NSNotFound) {
    if([[filename pathExtension] isEqualToString:@"png"] && [GTFileLoader isRetina] && [filename rangeOfString:@"@2x"].location == NSNotFound) {
        filename = [NSString stringWithFormat:@"%@@2x.%@",[filename stringByDeletingPathExtension], [filename pathExtension]];
    }
    
    return filename;
}

#pragma mark - dealloc

- (void)dealloc {
    
    [self clearCache];
    
}

@end
