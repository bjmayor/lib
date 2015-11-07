//
//  ReplayEditorView.m
//  YConference
//
//  Created by  on 13-3-21.
//  Copyright (c) 2013年  Ltd., Co. All rights reserved.
//

#import "HaloReplyTextView.h"
#import "HaloUITextView2.h"

#define KLayerOpacity       0.4
#define KBtnWidth           50
#define KContentMaxLength   500


@interface HaloReplyTextView ()<UITextViewDelegate,UITextFieldDelegate>
@property (nonatomic, strong) UIControl *backgroundView;
@property (nonatomic, assign) CGRect keyboardEndFrame;
@property (nonatomic, strong) UIView *controlView;

@end

@implementation HaloReplyTextView

+ (HaloReplyTextView *)replyEditorViewWithBlock:(ButtonBlock)block title:(NSString *)title maxCount:(NSInteger) maxCount editType:(EditType)type
{
    HaloReplyTextView *replyEditorView = [[HaloReplyTextView alloc]initWithFrame:CGRectZero type:type maxCount:maxCount];
    replyEditorView.buttonBlock = block;
    replyEditorView.titleLabel.text = title;
    return replyEditorView;
}

- (id)initWithFrame:(CGRect)frame type:(EditType)type maxCount:(NSInteger)maxCount
{
    self = [self initWithFrame:frame];
    if (self)
    {
        self.editType = type;
        self.backgroundColor = [UIColor clearColor];
        self.maxCount = maxCount;
        self.backgroundView  = [[UIControl alloc]initWithFrame:CGRectZero];
        self.backgroundView.backgroundColor = [UIColor blackColor];
        [self.backgroundView addTarget:self action:@selector(backgroundClicked) forControlEvents:UIControlEventTouchUpInside];
        self.backgroundView.layer.opacity = KLayerOpacity;
        [self addSubview:self.backgroundView];
        [self createControlView];
        [self addSubview:self.controlView];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)setDefaultText:(NSString *)text placeHolder:(NSString *)placeHolder
{
    switch (self.editType)
    {
        case EEditOneLine:
        case EEditOneLineSecure:
        {
            self.textField.text = text;
            self.textField.placeholder = placeHolder;
        }
            break;
        default:
        {
            self.textView.text = text;
            self.textView.placeHolder = placeHolder;
        }
            break;
    }
}

- (void)clearText
{
    switch (self.editType)
    {
        case EEditOneLine:
        case EEditOneLineSecure:
        {
            self.textField.text = nil;
        }
            break;
        default:
        {
            self.textView.text = nil;
        }
            break;
    }
}

- (NSString *)text
{
    switch (self.editType)
    {
        case EEditOneLine:
        case EEditOneLineSecure:
            return self.textField.text;
        default:
            return  self.textView.text;
    }
}

- (BOOL)becomeFirstResponder
{
    switch (self.editType)
    {
        case EEditOneLine:
        case EEditOneLineSecure:
            return [self.textField becomeFirstResponder];
        default:
            return [self.textView becomeFirstResponder];
    }
}

- (void)showReplyViewOnView:(UIView *)contentView
{
    self.frame = contentView.bounds;
    self.layer.opacity = 1;
    [contentView addSubview:self];
    CGRect rect = [[UIApplication sharedApplication] keyWindow].bounds;
    rect = [self convertRect:CGRectMake(0, rect.size.height, self.width, self.controlView.height) fromView:[[UIApplication sharedApplication] keyWindow]];
    self.controlView.frame = rect;
    [self confirmBtn];
    [self layoutControlView];
    if (self.textView)
    {
        [self.textView becomeFirstResponder];
    }
    else
    {
        [self.textField becomeFirstResponder];
    }
    
    [UIView animateWithDuration:.2f animations:^{
        self.backgroundView.layer.opacity = KLayerOpacity;
    } completion:^(BOOL finished) {
    }];
}

- (void)hideReplyView
{
    if (self.textView)
    {
        [self.textView resignFirstResponder];
    }
    else
    {
        [self.textField resignFirstResponder];
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundView.layer.opacity = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundView.frame = self.bounds;
}

#pragma mark -
#pragma mark keyboard
// Prepare to resize for keyboard.
- (void)keyboardWillShow:(NSNotification *)notification
{
 	NSDictionary *userInfo = [notification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect kbFrame;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&kbFrame];
    self.keyboardEndFrame = kbFrame;
    
    [self slideFrame:YES
               curve:animationCurve
            duration:animationDuration];
}

// Expand textview on keyboard dismissal
- (void)keyboardWillHide:(NSNotification *)notification
{

    NSDictionary *userInfo = [notification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&_keyboardEndFrame];
    [self slideFrame:NO
               curve:animationCurve
            duration:animationDuration];
    
    _keyboardEndFrame = CGRectZero;
}


- (void)slideFrame:(BOOL)up curve:(UIViewAnimationCurve)curve duration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        CGRect winRect = [[UIApplication sharedApplication] keyWindow].bounds;
        CGPoint point;
        if (up)
        {
             point = [self convertPoint:CGPointMake(0, winRect.size.height - self.keyboardEndFrame.size.height - self.controlView.height) fromView:[[UIApplication sharedApplication] keyWindow]];
        }
        else
        {
             point = [self convertPoint:CGPointMake(0, winRect.size.height - self.controlView.height) fromView:[[UIApplication sharedApplication] keyWindow]];
        }
        self.controlView.top = point.y;
        
    } completion:^(BOOL finished) {
    }];
}

- (void)backgroundClicked
{
    [self cancelReplay];
}

#pragma mark -
#pragma mark ControlView
- (void)createControlView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor whiteColor];
    
    switch (self.editType)
    {
        case EEditOneLine:
        case EEditOneLineSecure:
        {
            self.textField = [[HaloUITextField2 alloc]initWithFrame:CGRectMake(0, 0, 100, 30) placeHolder:KNilString keyboardType:UIKeyboardTypeDefault];
            self.textField.secureTextEntry = self.editType == EEditOneLineSecure;
            [self.textField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
            self.textField.delegate = self;
            self.textField.returnKeyType = UIReturnKeyDone;
            self.textField.enablesReturnKeyAutomatically = YES;
            self.textField.borderStyle = UITextBorderStyleLine;
            [view addSubview:self.textField];
        }
            break;
        default:
        {
            HaloUITextView2 *textView = [[HaloUITextView2 alloc]initWithFrame:CGRectZero];
            self.textView = textView;
            self.textView.textColor = [HaloTheme colorWithColorId:@"font_color1"];
            self.textView.delegate = self;
            self.textView.layer.borderColor = [UIColor blackColor].CGColor;
            self.textView.layer.borderWidth = 1;
            [view addSubview:textView];
            
        }
            break;
    }

    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];;
    [cancelBtn addTarget:self action:@selector(cancelReplay) forControlEvents:UIControlEventTouchUpInside];    
    self.cancelBtn = cancelBtn;
    [view addSubview:cancelBtn];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    titleLabel.numberOfLines = 1;
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel = titleLabel;
    [view addSubview:titleLabel];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn addTarget:self action:@selector(sendReplay) forControlEvents:UIControlEventTouchUpInside];
    self.sendBtn = sendBtn;
    [view addSubview:sendBtn];
    
    
    self.controlView = view;
}

- (void)layoutControlView
{
    self.cancelBtn.top = 0;
    self.cancelBtn.left = 0;
    
    [self.titleLabel sizeToFit];
    float maxWidth = self.controlView.width - self.cancelBtn.right * 2;
    if (self.titleLabel.width > maxWidth)
    {
        self.titleLabel.width = maxWidth;
    }
    self.titleLabel.center = CGPointMake(self.controlView.width / 2, self.cancelBtn.centerY);
    UIView *tempView = nil;
    if (self.textView)
    {
        tempView = self.textView;
        self.textView.frame = CGRectMake(KGap, self.titleLabel.bottom + KGap , self.controlView.width - 2 * KGap, 7.5* KGap);
    }
    else
    {
        tempView = self.textField;
        self.textField.frame = CGRectMake(KGap, self.titleLabel.bottom + KGap , self.controlView.width - 2 * KGap, 4 *KGap);
    }
    
    self.sendBtn.top = 0;
    self.sendBtn.right = self.width;

    self.controlView.height = tempView.bottom + KGap;
    
    
}


#pragma mark -
#pragma mark ButtonAction
- (void)sendReplay
{
    if (self.sendBtn.enabled)
    {
        self.sendBtn.enabled = NO;
        if (self.buttonBlock)
        {
            self.buttonBlock(self, ESendButton,[self text]);
        }
    }
}

- (void)cancelReplay
{
    if (self.buttonBlock)
    {
        self.buttonBlock(self, ECloseButton,[self text]);
    }

    [self hideReplyView];
}


#pragma mark - textFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendReplay];
    return YES;
}

#pragma mark -
#pragma mark textViewsDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    [self confirmBtn];
}

- (void)textFieldDidChange
{
    [self confirmBtn];
}

- (void)confirmBtn
{
    NSString *contentStr = [self text];
    
    if (contentStr.length > self.maxCount || ([contentStr trimSpaceAndReturn].length == 0 && self.editType != EEditOneLineSecure))
    {
        self.sendBtn.enabled = NO;
    }
    else
    {
        self.sendBtn.enabled = YES;
    }
}

- (void)didSetButton:(UIButton *)button icon:(UIImage *)icon forState:(UIControlState)state
{
    [button setImage:icon forState:state];
    [button sizeToFit];
    button.frame = CGRectInset(button.frame, -KGap, -KGap);
    [self setNeedsLayout];
}

- (void)setOKButtonIcon:(UIImage *)icon forState:(UIControlState)state
{
    [self didSetButton:self.sendBtn icon:icon forState:state];
}

- (void)setCancelButtonIcon:(UIImage *)icon forState:(UIControlState)state
{
    [self didSetButton:self.cancelBtn icon:icon forState:state];
}
@end
