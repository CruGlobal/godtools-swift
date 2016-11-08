//
//  FileLoader.h
//  Snuffy
//
//  Created by Tom Flynn on 12/11/10.
//  Copyright 2010 CCCA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GTFileLoader : NSObject

@property (nonatomic, strong, readonly)	NSBundle *bundle;
@property (nonatomic, strong)			NSString *language;

+ (GTFileLoader *)sharedInstance;
+ (instancetype)fileLoader;

- (NSString *)pathOfPackagesDirectory;
- (NSString *)pathOfFileWithFilename:(NSString *)filename;

- (NSString *)localizedString:(NSString *)key;
- (UIImage *)imageWithFilename:(NSString *)filename;

- (void)cacheImageWithFileName:(NSString *)filename;
- (void)clearCache;

@end
