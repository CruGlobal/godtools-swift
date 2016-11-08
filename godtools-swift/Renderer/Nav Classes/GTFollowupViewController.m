//
//  GTFollowUpViewController.m
//  GTViewController
//
//  Created by Ryan Carlson on 4/12/16.
//  Copyright © 2016 Michael Harrison. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTFollowUpViewController.h"

#import "GTFileLoader.h"
#import "GTInputFieldView.h"
#import "GTFollowupModalView.h"
#import "GTFollowupThankYouView.h"

NSString *const GTFollowupViewControllerParameterName_Name                      = @"name";
NSString *const GTFollowupViewControllerParameterName_Email                     = @"email";
NSString *const GTFollowupViewControllerFieldSubscriptionNotificationName       = @"org.cru.godtools.GTFollowupModalView.followupSubscriptionNotificationName";
NSString *const GTFollowupViewControllerFieldSubscriptionEventName              = @"followup:subscribe";
NSString *const GTFollowupViewControllerFieldKeyEmail                           = @"org.cru.godtools.GTFollowupModalView.fieldKeyEmail";
NSString *const GTFollowupViewControllerFieldKeyName                            = @"org.cru.godtools.GTFollowupModalView.fieldKeyName";
NSString *const GTFollowupViewControllerFieldKeyFollowupId                      = @"org.cru.godtools.GTFollowupModalView.fieldKeyFollowupId";

@interface GTFollowupViewController ()

@property (weak, nonatomic)         UITextField *activeField;
@property (assign, nonatomic)       CGFloat originalHeight;
@property (assign, nonatomic)       CGRect visibleFrame;
@property (strong, nonatomic)       NSString *packageCode;
@property (strong, nonatomic)       NSString *LanguageCode;

@end

@implementation GTFollowupViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lookForSendFollowupListener:)
                                                 name:UISnuffleButtonNotificationButtonTapEvent
                                               object:nil];

}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UISnuffleButtonNotificationButtonTapEvent
                                               object:nil];
}


- (void)setFollowupView:(GTFollowupModalView *)followupModalView {
    self.followupModalView = followupModalView;
    self.followupThankYouView = followupModalView.thankYouView;
    [self.view insertSubview:self.followupModalView atIndex:0];
    [self.view insertSubview:self.followupThankYouView belowSubview:self.followupModalView];
    self.originalHeight = followupModalView.frame.size.height;
    
    [self.followupModalView.inputFieldViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GTInputFieldView *inputFieldView = obj;
        inputFieldView.inputTextField.delegate = self;
    }];
    
    return;
}


- (void)setFollowupView:(GTFollowupModalView *)followupModalView andThankYouView:(GTFollowupThankYouView *)thankYouView {
    self.followupModalView = followupModalView;
    self.followupThankYouView = thankYouView;
    self.view = followupModalView;
    self.originalHeight = followupModalView.frame.size.height;
    
    [self.followupModalView.inputFieldViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GTInputFieldView *inputFieldView = obj;
        inputFieldView.inputTextField.delegate = self;
    }];
    
    return;
}

- (void)setPackageCode:(NSString *)packageCode andLanguageCode:(NSString *)languageCode {
    self.packageCode = packageCode;
    self.LanguageCode = languageCode;
}


- (void)transitionToThankYou {
    [self.view addSubview:self.followupThankYouView];
    
    [self.followupModalView.inputFieldViews enumerateObjectsUsingBlock:^(GTInputFieldView *inputFieldView, NSUInteger idx, BOOL * _Nonnull stop) {
        if([inputFieldView.inputTextField isFirstResponder]) {
            [inputFieldView.inputTextField resignFirstResponder];
        }
    }];
    
    [UIView animateWithDuration:2.0 animations:^{
        [self.view bringSubviewToFront:self.followupThankYouView];
    }];
}


- (void) lookForSendFollowupListener:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    NSString *eventName = [userInfo valueForKey:UISnuffleButtonNotificationButtonTapEventKeyEventName];
    
    if ([[eventName lowercaseString]isEqualToString:GTFollowupViewControllerFieldSubscriptionEventName]) {
        [self sendFollowupSubscribeListener];
    }
}


- (void) sendFollowupSubscribeListener {
    
    __block NSMutableDictionary *followupDetailsDictionary = [[NSMutableDictionary alloc]init];
    [followupDetailsDictionary setValue:self.followupModalView.followupId forKey:GTFollowupViewControllerFieldKeyFollowupId];
    
    [self.followupModalView.inputFieldViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GTInputFieldView *inputFieldView = obj;
        
        if ([inputFieldView.parameterName isEqualToString:GTFollowupViewControllerParameterName_Name] && inputFieldView.inputFieldValue) {
            [followupDetailsDictionary setValue:inputFieldView.inputFieldValue forKey:GTFollowupViewControllerFieldKeyName];
        } else if ([inputFieldView.parameterName isEqualToString:GTFollowupViewControllerParameterName_Email] && inputFieldView.inputFieldValue) {
            [followupDetailsDictionary setValue:inputFieldView.inputFieldValue forKey:GTFollowupViewControllerFieldKeyEmail];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GTFollowupViewControllerFieldSubscriptionNotificationName
                                                        object:nil
                                                      userInfo:followupDetailsDictionary];
}


#pragma mark - Animation methods to prevent text field from being hidden

-(void)keyboardWillShow:(NSNotification *) notification {
    if (self.view.frame.origin.y < 0) {
        return;
    }
    
    [self moveView:notification];
}

-(void)keyboardWillHide:(NSNotification *) notification {
    
    if (self.view.frame.origin.y >= 0) {
        return;
    }
    
    [self resetViewPosition:notification];
}


//method to move the view up when the keyboard would cover the "active" textField
-(void)moveView:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    CGRect inputFieldViewFrame = self.activeField.superview.frame;
    
    CGRect unobscuredByKeyboardFrame = self.view.frame;
    unobscuredByKeyboardFrame.size.height -= CGRectGetHeight(keyboardFrame);
    
    // offset the height of the inputFieldView, b/c it is a label stacked on an input
    // if just the frame is considered, then the label could show while the input is hidden
    unobscuredByKeyboardFrame.size.height -= CGRectGetHeight(inputFieldViewFrame);
    
    self.visibleFrame = unobscuredByKeyboardFrame;
    
    if (CGRectContainsPoint(unobscuredByKeyboardFrame, inputFieldViewFrame.origin) ) {
        return;
    }

    CGFloat viewVerticalDelta = (CGRectGetMinY(inputFieldViewFrame) + CGRectGetHeight(inputFieldViewFrame)) - CGRectGetHeight(unobscuredByKeyboardFrame);
    UIViewAnimationCurve animationCurve;
    NSTimeInterval animationDuration;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];

    [self animateViewWithVerticalDelta:viewVerticalDelta
                     animationDuration:animationDuration
                        animationCurve:animationCurve];
}


- (void) animateViewWithVerticalDelta:(CGFloat)verticalDelta animationDuration:(NSTimeInterval) animationDuration animationCurve:(UIViewAnimationCurve)animationCurve {
    
    self.visibleFrame = CGRectMake(CGRectGetMinX(self.visibleFrame),
                                   CGRectGetMinY(self.visibleFrame),
                                   CGRectGetWidth(self.visibleFrame),
                                   CGRectGetHeight(self.visibleFrame) + verticalDelta);

    // Get animation info from userInfo
    CGRect newViewFrame = self.view.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];

    newViewFrame.origin.y -= verticalDelta;
    newViewFrame.size.height += verticalDelta;

    self.view.frame = newViewFrame;
    
    [UIView commitAnimations];
}


- (void) resetViewPosition:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    [self animateViewWithVerticalDelta:self.originalHeight - CGRectGetHeight(self.view.frame)
                     animationDuration:animationDuration
                        animationCurve:animationCurve];
}

- (CGFloat)calculateVerticalDeltaFromCurrentField:(UIView *)currentField toNextField:(UIView *)nextField {
    
    return CGRectGetMinY(nextField.frame) - CGRectGetMinY(currentField.frame);
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
    if (![textField.superview.superview viewWithTag:textField.tag + 1]) {
        [textField setReturnKeyType:UIReturnKeyDone];
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    
    UIResponder *nextResponder = [textField.superview.superview viewWithTag:nextTag];
    
    if (nextResponder) {
        UITextField *nextActiveField = (UITextField*)nextResponder;
        
        //nextActiveField.superview because the UITextField is in a container UIView.  The container UIView
        //is the one whose y-position we care about.  The UITextField y-position is relative to the container
        //and is not helpful here
        CGFloat verticalDelta = CGRectContainsPoint(self.visibleFrame, nextActiveField.superview.frame.origin) ? 0 :
        [self calculateVerticalDeltaFromCurrentField:self.activeField.superview
                                         toNextField:nextActiveField.superview];
        
        self.activeField = nextActiveField;

        [self animateViewWithVerticalDelta:verticalDelta
                         animationDuration:0.3
                            animationCurve:UIViewAnimationCurveEaseOut];
        
        if (![nextActiveField.superview.superview viewWithTag:++nextTag]) {
            [nextActiveField setReturnKeyType:UIReturnKeyDone];
        }
        
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}


#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}


#pragma mark - UISnuffleButtonTapDelegate methods

- (BOOL)validateFields {
    NSArray *inputValidationErrors = [self inputValidationErrors];

    if ([inputValidationErrors count]) {
        [[[UIAlertView alloc] initWithTitle:[[GTFileLoader sharedInstance] localizedString:@"GTFollowupViewController_validation_title"]
                                    message:[inputValidationErrors componentsJoinedByString:@"\n"]
                                   delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        return NO;
    }

    return YES;
}

- (NSString *)currentLanguageCode {
    return self.LanguageCode;
}


- (NSString *)currentPackageCode {
    return self.packageCode;
}


- (CGRect)pageFrame {
    return self.followupModalView.frame;
}

- (UIView *)viewOfPageViewController {
    return self.followupModalView;
}

- (NSArray *)inputValidationErrors {
    __block NSMutableArray *validationErrors = @[].mutableCopy;
    
    [self.followupModalView.inputFieldViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GTInputFieldView *inputFieldView = obj;
        
        if (![inputFieldView isValid]) {
            [validationErrors addObject:[inputFieldView validationMessage]];
        }
    }];
    
    return validationErrors;
}

@end