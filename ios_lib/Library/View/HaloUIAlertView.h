//
//  HaloUIAlertView.h
//  YConference
//
//  Created by  on 13-5-13.
//  Copyright (c) 2013年  Ltd., Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef enum {
    HaloAlertViewStyleDefault = 0,
    HaloAlertViewStyleSecureTextInput,
    HaloAlertViewStylePlainTextInput,
    HaloAlertViewStyleLoginAndPasswordInput,
} HaloAlertViewStyle;

typedef enum {
	HaloAlertViewPresentationStylePop = 0,
	HaloAlertViewPresentationStyleFade,
} HaloAlertViewPresentationStyle;

typedef enum {
    HaloAlertViewDismissalStyleFade,
	HaloAlertViewDismissalStyleTumble,
	HaloAlertViewDismissalStyleZoomDown,
	HaloAlertViewDismissalStyleZoomOut,
} HaloAlertViewDismissalStyle;

@class HaloUIAlertView;

typedef void (^HaloAlertViewButtonBlock)(HaloUIAlertView *alertView, NSInteger buttonIndex);

@interface HaloUIAlertView : UIView
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, strong)UITextView  *textView;
@property(nonatomic, readonly, assign, getter = isVisible) BOOL visible;
@property(nonatomic, assign) HaloAlertViewStyle alertViewStyle;
@property(nonatomic, assign) HaloAlertViewPresentationStyle presentationStyle;
@property(nonatomic, assign) HaloAlertViewDismissalStyle dismissalStyle;
@property(nonatomic, assign) CGFloat   customViewHeight;

// Resets all UIAppearance modifiers back to generic iOS alert styles
+ (void)applySystemAlertAppearance;

//Init
- (id)initWithTitle:(NSString *)title message:(NSString *)message;
- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)addButtonWithTitle:(NSString *)title;
- (void)setCancelButtonTitle:(NSString *)title;

//Use for update alert
- (void)addTextViewWithContent:(NSString *)text;

//Show & dissmiss
- (void)show;
- (void)show:(HaloAlertViewButtonBlock)block;
- (void)showWithStyle:(HaloAlertViewPresentationStyle)presentationStyle block:(HaloAlertViewButtonBlock)block;
- (void)showWithStyle:(HaloAlertViewPresentationStyle)presentationStyle dismissStyle:(HaloAlertViewDismissalStyle)dissmissStyle block:(HaloAlertViewButtonBlock)block;

- (void)dismiss;
- (void)dismissWithStyle:(HaloAlertViewDismissalStyle)dismissalStyle;

// Retrieve the text field corresponding to the supplied index:
// For HaloAlertViewStyleSecureTextInput and HaloAlertViewStylePlainTextInput styles, there is only one text field at index 0.
// For HaloAlertViewStyleLoginAndPasswordInput, the login field is at index 0, and the password field is at index 1.
- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex;

//core framewrok
- (UIButton *)buttonAtIndex:(NSInteger)index;

+ (HaloUIAlertView*)alertViewWithTitle:(NSString*) title message:(NSString*) message cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:otherButtonTitle, ... NS_REQUIRES_NIL_TERMINATION;

+ (HaloUIAlertView *)showAlertWithTitle:(NSString*) title message:(NSString*) message block:(HaloAlertViewButtonBlock)block cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:otherButtonTitle, ... NS_REQUIRES_NIL_TERMINATION;

+ (HaloUIAlertView *)showAlertTipWithTitle:(NSString*) title message:(NSString*) message block:(HaloAlertViewButtonBlock)block;

+ (HaloUIAlertView *)showAlertWithMessage:(NSString*)message;

- (void)enableButtonWithTitle:(NSString *)title enable:(BOOL)enabel;

- (void)enableButtonWithIndex:(NSInteger)index enable:(BOOL)enabel;

- (void)setAlertViewAddtionalHeight:(CGFloat)height;






//Custom UI Fuction

// Use this property to set the background image of alerts. For best results, use a resizable image.
@property(nonatomic, strong) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;
// Use this property to customize the insets surrounding the content of the alert.
// This does not affect leading between labels and other controls.
@property(nonatomic, assign) UIEdgeInsets contentInsets UI_APPEARANCE_SELECTOR;

// Use this property to customize the title text appearance. The dictionary keys are documented in UIStringDrawing.h
@property(nonatomic, copy) NSDictionary *titleTextAttributes UI_APPEARANCE_SELECTOR;
// Use this property to customize the message text appearance. The dictionary keys are documented in UIStringDrawing.h
@property(nonatomic, copy) NSDictionary *messageTextAttributes UI_APPEARANCE_SELECTOR;
// Use this property to customize the button title text appearance. The dictionary keys are documented in UIStringDrawing.h
@property(nonatomic, copy) NSDictionary *buttonTitleTextAttributes UI_APPEARANCE_SELECTOR;

@property(nonatomic, copy) NSDictionary *buttonTitleHighlightedTextAttributes UI_APPEARANCE_SELECTOR;

// Use these methods to set/get the background image for control state(s) of normal buttons.
- (void)setButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIImage *)buttonBackgroundImageForState:(UIControlState)state UI_APPEARANCE_SELECTOR;

// Use these methods to set/get the background image for control state(s) of cancel buttons.
- (void)setCancelButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (UIImage *)cancelButtonBackgroundImageForState:(UIControlState)state UI_APPEARANCE_SELECTOR;

//use TextStyle to custom UI
- (void)setTitleFont:(UIFont *)font textStyle:(TextStyle *)style UI_APPEARANCE_SELECTOR;
- (void)setMessageFont:(UIFont *)font textStyle:(TextStyle *)style UI_APPEARANCE_SELECTOR;
- (void)setButtonTitleFont:(UIFont *)font textStyle:(TextStyle *)style UI_APPEARANCE_SELECTOR;
- (void)setButtonTitleHighlightedFont:(UIFont *)font textStyle:(TextStyle *)style UI_APPEARANCE_SELECTOR;
@end
