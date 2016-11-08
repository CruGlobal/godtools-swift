//
//  GTFollowupThankYouView.h
//  GTViewController
//
//  Created by Ryan Carlson on 4/12/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TBXML.h"

#import "GTPageStyle.h"

@interface GTFollowupThankYouView : UIView

- (instancetype) initFromElement:(TBXMLElement *) thankYouElement
                       withFrame:(CGRect)frame
                   withPageStyle:(GTPageStyle *)style;

@end