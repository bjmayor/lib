//
//  ReplayEditorView.h
//  YConference
//
//  Created by  on 13-3-21.
//  Copyright (c) 2013年  Ltd., Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HaloUITextField2.h"
#import "HaloUITextView2.h"
#import <QuartzCore/QuartzCore.h>
@class HaloReplyTextView;
typedef enum
{
    EEditOneLine,
    EEditOneLineSecure,
    EEditMultipleLine,
}
EditType;

typedef enum
{
    ECloseButton,
    ESendButton
}ReplyEditorButtonType;

typedef void(^ButtonBlock)(HaloReplyTextView *replyView,ReplyEditorButtonType type,NSString *sendString);

@interface HaloReplyTextView : UIView
@property (nonatomic, copy) ButtonBlock  buttonBlock;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) EditType editType;
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, strong) HaloUITextField2 *textField;
@property (nonatomic, strong) HaloUITextView2 *textView;

+ (HaloReplyTextView *)replyEditorViewWithBlock:(ButtonBlock)block title:(NSString *)title maxCount:(NSInteger) maxCount editType:(EditType)type;
- (id)initWithFrame:(CGRect)frame type:(EditType)type maxCount:(NSInteger)maxCount;
- (void)setDefaultText:(NSString *)text placeHolder:(NSString *)placeHolder;
- (void)showReplyViewOnView:(UIView *)contentView;
- (void)hideReplyView;
- (void)setButtonBlock:(ButtonBlock)buttonBlock;
- (void)clearText;
- (NSString *)text;
- (void)setOKButtonIcon:(UIImage *)icon forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setCancelButtonIcon:(UIImage *)icon forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
@end
