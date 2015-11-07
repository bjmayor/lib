//
//  HaloUIActionSheet.h
//  HaloSlimFramework
//
//  Created by  on 13-5-28.
//
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface HaloUIActionSheet : UIView
@property(nonatomic, readonly, strong) NSMutableArray *items;

+ (id)actionSheetWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle;

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle;

- (void)setTitle:(NSString *)title;
//add Button
- (void)addItemWithTitle:(NSString *)title isRed:(BOOL)isRed block:(void(^)())block;

- (void)show;

- (void)showWithDismissBlock:(void(^)())block;

//Custom UI Fuction

// Use this property to customize the title text appearance. The dictionary keys are documented in UIStringDrawing.h
@property(nonatomic, strong) NSDictionary *titleAttributes UI_APPEARANCE_SELECTOR;
// Use this property to customize the message text appearance. The dictionary keys are documented in UIStringDrawing.h
@property(nonatomic, strong) NSDictionary *buttonTextAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSDictionary *cancelButtonTextAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSDictionary *redButtonTextAttributes UI_APPEARANCE_SELECTOR;


//use TextStyle to custom UI
- (void)setTitleFont:(UIFont *)font textStyle:(TextStyle *)style UI_APPEARANCE_SELECTOR;
- (void)setButtonTextFont:(UIFont *)font textStyle:(TextStyle *)style UI_APPEARANCE_SELECTOR;
- (void)setCancelButtonTextFont:(UIFont *)font textStyle:(TextStyle *)style UI_APPEARANCE_SELECTOR;
- (void)setRedButtonTextFont:(UIFont *)font textStyle:(TextStyle *)style UI_APPEARANCE_SELECTOR;
@end
