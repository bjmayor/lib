//
//  HaloUIAlertView.m
//  YConference
//
//  Created by  on 13-5-13.
//  Copyright (c) 2013年  Ltd., Co. All rights reserved.
//

#import "HaloUIAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageExt.h"


static const NSInteger AHViewAutoresizingFlexibleSizeAndMargins =
UIViewAutoresizingFlexibleLeftMargin |
UIViewAutoresizingFlexibleWidth |
UIViewAutoresizingFlexibleRightMargin |
UIViewAutoresizingFlexibleTopMargin |
UIViewAutoresizingFlexibleHeight |
UIViewAutoresizingFlexibleBottomMargin;

static const CGFloat AHAlertViewDefaultWidth = 276;
static const CGFloat AHAlertViewMinimumHeight = 100;
static const CGFloat AHAlertViewDefaultButtonHeight = 40;
static const CGFloat AHAlertViewDefaultTextFieldHeight = 26;
static const CGFloat AHAlertViewDefaultTextViewHeight = 100;
static const CGFloat AHAlertViewTitleLabelBottomMargin = 8;
static const CGFloat AHAlertViewMessageLabelBottomMargin = 16;
static const CGFloat AHAlertViewTextFieldBottomMargin = 8;
static const CGFloat AHAlertViewTextFieldLeading = -1;
static const CGFloat AHAlertViewButtonBottomMargin = 4;
static const CGFloat AHAlertViewButtonHorizontalSpacing = 0;

// This function may not be completely general. Works well enough for our purposes here.
static CGFloat CGAffineTransformGetAbsoluteRotationAngleDifference(CGAffineTransform t1, CGAffineTransform t2)
{
	CGFloat dot = t1.a * t2.a + t1.c * t2.c;
	CGFloat n1 = sqrtf(t1.a * t1.a + t1.c * t1.c);
	CGFloat n2 = sqrtf(t2.a * t2.a + t2.c * t2.c);
	return acosf(dot / (n1 * n2));
}

// Internal block type definitions
typedef void (^AHAnimationCompletionBlock)(BOOL);
typedef void (^AHAnimationBlock)();

@interface HaloUIAlertView () {
	// Flag to indicate whether this alert view has ever layed out its subviews
	BOOL hasLayedOut;
	// Flag to indicate whether keyboard is visible (or will soon be visible) on the screen
	BOOL keyboardIsVisible;
	// Flag to indicate whether the alert view is in the process of a dismissal animation
	BOOL isDismissing;
	// Vertical position of top edge of keyboard, when visible
	CGFloat keyboardHeight;
}

@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, strong) UIWindow *previousKeyWindow;
@property (nonatomic, strong) UIImageView *dimView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UITextField *plainTextField;
@property (nonatomic, strong) UITextField *secureTextField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) NSMutableArray *otherButtons;
@property (nonatomic, copy)   HaloAlertViewButtonBlock alertBlock;

//UI
@property (nonatomic, strong) NSMutableDictionary *buttonBackgroundImagesForControlStates;
@property (nonatomic, strong) NSMutableDictionary *cancelButtonBackgroundImagesForControlStates;
@property (nonatomic, strong) NSMutableDictionary *destructiveButtonBackgroundImagesForControlStates;

@end

@implementation HaloUIAlertView


#pragma mark- Static Method

+ (void)initialize
{
	[self applySystemAlertAppearance];
}

+ (void)applySystemAlertAppearance {
	// Set up default values for all UIAppearance-compatible selectors
    
    UIFont *normalFont = [UIFont iOS7SystemFontOfSize:16 attribute:UI7FontAttributeLight];
    UIFont *cancelFont = [UIFont iOS7SystemFontOfSize:16 attribute:UI7FontAttributeMedium];
    
	// Set default (blue glass) background image. See drawing code below.
	[[self appearance] setBackgroundImage:[self alertBackgroundImage]];
    
	// Empirically determined edge insets for system style alerts
	[[self appearance] setContentInsets:UIEdgeInsetsMake(16, 8, 8, 8)];
    
	// Configure text properties for title, message, and buttons so they accord with system defaults.
	[[self appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIFont boldSystemFontOfSize:17], UITextAttributeFont,
                                               [UIColor blackColor], UITextAttributeTextColor,
                                               nil]];
    
	[[self appearance] setMessageTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIFont systemFontOfSize:15], UITextAttributeFont,
                                                 [UIColor blackColor], UITextAttributeTextColor,
                                                 nil]];
    
    UIColor *btnFontColor = [UIColor colorWithRed:0 green:126.0/255 blue:245.0/255 alpha:1];
    
    
    
	[[self appearance] setButtonTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     normalFont, UITextAttributeFont,
                                                     btnFontColor, UITextAttributeTextColor,
                                                     nil]];
    
    [[self appearance] setButtonTitleHighlightedTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               cancelFont, UITextAttributeFont,
                                                               [btnFontColor colorWithAlphaComponent:0.3], UITextAttributeTextColor,
                                                                nil]];
    
	// Set basic button background images.
	[[self appearance] setButtonBackgroundImage:[self normalButtonBackgroundImage] forState:UIControlStateNormal];
	
	[[self appearance] setCancelButtonBackgroundImage:[self cancelButtonBackgroundImage] forState:UIControlStateNormal];
}

+ (HaloUIAlertView*)alertViewWithTitle:(NSString*) title message:(NSString*) message cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:otherButtonTitle, ...
{
    HaloUIAlertView *alert = [[HaloUIAlertView alloc] initWithTitle:title message:message];
    
    [alert setCancelButtonTitle:cancelButtonTitle];
    if ( otherButtonTitle != nil )
    {
        [alert addButtonWithTitle:otherButtonTitle];
        va_list arg_ptr;
        va_start ( arg_ptr, otherButtonTitle );
        
        NSString *p = va_arg( arg_ptr,NSString*);
        while ( p != nil )
        {
            [alert addButtonWithTitle:p];
            p = va_arg( arg_ptr,NSString*);
        }
        va_end(arg_ptr);
    }
    
    return alert;
}

+ (HaloUIAlertView *)showAlertWithTitle:(NSString *)title message:(NSString *)message block:(HaloAlertViewButtonBlock)block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(id)otherButtonTitle, ...
{
    HaloUIAlertView *alert = [[HaloUIAlertView alloc] initWithTitle:title message:message];
    
    [alert setCancelButtonTitle:cancelButtonTitle];
    if ( otherButtonTitle != nil )
    {
        [alert addButtonWithTitle:otherButtonTitle];
        va_list arg_ptr;
        va_start ( arg_ptr, otherButtonTitle );
        
        NSString *p = va_arg( arg_ptr,NSString*);
        while ( p != nil )
        {
            [alert addButtonWithTitle:p];
            p = va_arg( arg_ptr,NSString*);
        }
        va_end(arg_ptr);
    }
    
    [alert show:block];
    
    return alert;
}

+ (HaloUIAlertView *)showAlertTipWithTitle:(NSString *)title message:(NSString *)message block:(HaloAlertViewButtonBlock)block
{
    HaloUIAlertView *alert = [[HaloUIAlertView alloc] initWithTitle:title message:message cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTableInBundle(@"ok",@"Global",[Halo bundle],nil), nil];
    [alert show:block];
    return alert;
}

+ (HaloUIAlertView *)showAlertWithMessage:(NSString *)message
{
    HaloUIAlertView *alert = [[HaloUIAlertView alloc] initWithTitle:nil message:message cancelButtonTitle:nil otherButtonTitles:NSLocalizedStringFromTableInBundle(@"ok",@"Global",[Halo bundle],nil), nil];
    [alert show:nil];
    return alert;
}


#pragma mark- Instatn Life cycle methods


- (id)initWithTitle:(NSString *)title message:(NSString *)message
{
	// The height of this frame is overridden in layoutSubviews, but it makes a good first approximation.
	CGRect frame = CGRectMake(0, 0, AHAlertViewDefaultWidth, AHAlertViewMinimumHeight);
	
	if((self = [super initWithFrame:frame]))
	{
		[super setBackgroundColor:[UIColor clearColor]];
        
		// Cache text properties for later use
		_title = title;
		_message = message;
        
		// Set default presentation and dismissal animation styles
		_presentationStyle = HaloAlertViewPresentationStylePop;
		_dismissalStyle = HaloAlertViewDismissalStyleFade;

        
		// Subscribe to orientation and keyboard visibility change notifications
//		[[NSNotificationCenter defaultCenter] addObserver:self
//												 selector:@selector(deviceOrientationChanged:)
//													 name:UIDeviceOrientationDidChangeNotification
//												   object:nil];
        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardFrameChanged:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardFrameChanged:)
													 name:UIKeyboardWillHideNotification
												   object:nil];
        
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [self initWithTitle:title message:message];
    if(self)
    {
        [self setCancelButtonTitle:cancelButtonTitle];
        if ( otherButtonTitles != nil )
        {
            [self addButtonWithTitle:otherButtonTitles];
            va_list arg_ptr;
            va_start ( arg_ptr, otherButtonTitles );
            
            NSString *p = va_arg( arg_ptr,NSString*);
            while ( p != nil )
            {
                [self addButtonWithTitle:p];
                p = va_arg( arg_ptr,NSString*);
            }		
            va_end(arg_ptr);
        }
    }
    return self;
}


- (void)setAlertViewAddtionalHeight:(CGFloat)height
{
    self.customViewHeight = height;
    [self setNeedsLayout];
}
#pragma mark - Button management methods

- (void)addTextViewWithContent:(NSString *)text
{
    UITextView *textView = [[UITextView alloc] init];
    textView.backgroundColor = [UIColor clearColor];
    textView.editable = NO;
    textView.text = text;
    self.textView = textView;
    
    [self addSubview:self.textView];
}

- (void)flashScrollIndicators
{
    [self.textView flashScrollIndicators];
}


// Internal utility to initialize a button while also wiring up the block associated with its touch action
- (UIButton *)buttonWithTitle:(NSString *)aTitle{
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.shadowOffset = CGSizeZero;
	[button setTitle:aTitle forState:UIControlStateNormal];
	[button addTarget:self action:@selector(buttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
	return button;
}

// Add a normal button with a title and a block to call when it is tapped.
- (void)addButtonWithTitle:(NSString *)title
{
	if(!self.otherButtons)
		self.otherButtons = [NSMutableArray array];
	
	UIButton *otherButton = [self buttonWithTitle:title];
	[self.otherButtons addObject:otherButton];
	[self addSubview:otherButton];
}


// Set the cancel button title and a block to call when it is tapped.
- (void)setCancelButtonTitle:(NSString *)title
{
	if(title) {
		UIButton *btn = [self buttonWithTitle:title];
        [btn addTarget:self action:@selector(buttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.cancelButton = btn;
		[self addSubview:self.cancelButton];
	} else {
		[self.cancelButton removeFromSuperview];
		self.cancelButton = nil;
	}
}

- (UIButton *)buttonAtIndex:(NSInteger)index;
{
    if (self.cancelButton)
    {
        return index ==0 ? self.cancelButton : self.otherButtons[index - 1];
    }
    else
    {
        return self.otherButtons[index];
    }
}

- (void)enableButtonWithTitle:(NSString *)title enable:(BOOL)enabel
{
    for(UIButton *btn in self.otherButtons)
    {
        if ([btn.titleLabel.text isEqualToString:title])
        {
            btn.enabled = enabel;
        }
    }
    if (self.cancelButton && [self.cancelButton.titleLabel.text isEqualToString:title])
    {
        self.cancelButton.enabled = enabel;
    }
}

- (void)enableButtonWithIndex:(NSInteger)index enable:(BOOL)enabel
{
    NSInteger otherIndex = -1;
    if (self.cancelButton)
    {
        if (index == 0)
        {
            self.cancelButton.enabled = enabel;
        }
        else
        {
            otherIndex = index - 1;
        }
    }
    else
    {
        otherIndex = index;
    }
    
    if (otherIndex >= 0)
    {
        UIButton *btn = self.otherButtons[otherIndex];
        btn.enabled = enabel;
    }
}


#pragma mark - Text field accessor

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex {
	return [self textFieldAtIndex:textFieldIndex throws:YES];
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex throws:(BOOL)shouldThrow
{
	// Lazily instantiate text fields if we haven't layed out yet.
	[self ensureTextFieldsForCurrentAlertStyle];
    
	// The text field corresponding to the index depends solely on which alert view style is currently set.
	switch(self.alertViewStyle)
	{
		case HaloAlertViewStyleLoginAndPasswordInput:
			if(textFieldIndex == 0)
				return self.plainTextField;
			else if(textFieldIndex == 1)
				return self.secureTextField;
			break;
            
		case HaloAlertViewStylePlainTextInput:
			if(textFieldIndex == 0)
				return self.plainTextField;
			break;
            
		case HaloAlertViewStyleSecureTextInput:
			if(textFieldIndex == 0)
				return self.secureTextField;
			break;
            
		default:
			break;
	}
    
	if(shouldThrow)
	{
		NSString *exceptionReason = [NSString stringWithFormat:@"Text field index %d was beyond bounds for current style.",
									 textFieldIndex];
		NSException *rangeException = [NSException exceptionWithName:NSRangeException reason:exceptionReason userInfo:nil];
		[rangeException raise];
	}
	
	return nil;
}

#pragma mark - Appearance selectors

- (void)setAlertViewStyle:(HaloAlertViewStyle)alertViewStyle
{
	_alertViewStyle = alertViewStyle;
    
	// Cause text fields or other views to be instantiated lazily next time we lay out
	[self setNeedsLayout];
}

// Appearance selector for setting background image of normal buttons
- (void)setButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state
{
	if(!self.buttonBackgroundImagesForControlStates)
		self.buttonBackgroundImagesForControlStates = [NSMutableDictionary dictionary];
	
    if (backgroundImage)
    {
        
        [self.buttonBackgroundImagesForControlStates setObject:backgroundImage
                                                        forKey:[NSNumber numberWithInteger:state]];
    }
}

// Appearance selector for getting background image of normal buttons
- (UIImage *)buttonBackgroundImageForState:(UIControlState)state
{
	return [self.buttonBackgroundImagesForControlStates objectForKey:[NSNumber numberWithInteger:state]];
}

// Appearance selector for setting background image of cancel buttons
- (void)setCancelButtonBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state
{
	if(!self.cancelButtonBackgroundImagesForControlStates)
		self.cancelButtonBackgroundImagesForControlStates = [NSMutableDictionary dictionary];
    if (backgroundImage)
    {
        [self.cancelButtonBackgroundImagesForControlStates setObject:backgroundImage
                                                              forKey:[NSNumber numberWithInteger:state]];
    }
}

// Appearance selector for getting background image of cancel buttons
- (UIImage *)cancelButtonBackgroundImageForState:(UIControlState)state
{
	return [self.cancelButtonBackgroundImagesForControlStates objectForKey:[NSNumber numberWithInteger:state]];
}


- (void)applyTextAttributes:(NSDictionary *)attributes toLabel:(UILabel *)label
{
	label.font = [attributes objectForKey:UITextAttributeFont];
	label.textColor = [attributes objectForKey:UITextAttributeTextColor];
	label.shadowColor = [attributes objectForKey:UITextAttributeTextShadowColor];
	label.shadowOffset = [[attributes objectForKey:UITextAttributeTextShadowOffset] CGSizeValue];
}

- (void)applyTextAttributes:(NSDictionary *)attributes toButton:(UIButton *)button
{
	button.titleLabel.font = [attributes objectForKey:UITextAttributeFont];
	[button setTitleColor:[attributes objectForKey:UITextAttributeTextColor] forState:UIControlStateNormal];
	[button setTitleShadowColor:[attributes objectForKey:UITextAttributeTextShadowColor] forState:UIControlStateNormal];
	button.titleLabel.shadowOffset = [[attributes objectForKey:UITextAttributeTextShadowOffset] CGSizeValue];
}

- (void)applyHighlightTextAttributes:(NSDictionary *)attributes toButton:(UIButton *)button
{
	button.titleLabel.font = [attributes objectForKey:UITextAttributeFont];
	[button setTitleColor:[attributes objectForKey:UITextAttributeTextColor] forState:UIControlStateHighlighted];
	[button setTitleShadowColor:[attributes objectForKey:UITextAttributeTextShadowColor] forState:UIControlStateHighlighted];
	button.titleLabel.shadowOffset = [[attributes objectForKey:UITextAttributeTextShadowOffset] CGSizeValue];
}

- (void)applyBackgroundImages:(NSDictionary *)imagesForStates toButton:(UIButton *)button
{
	[imagesForStates enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[button setBackgroundImage:obj forState:[key integerValue]];
	}];
}

- (void)applyAppearanceAttributesToButtons
{
	if(self.cancelButton)
	{
		[self applyBackgroundImages:self.cancelButtonBackgroundImagesForControlStates
						   toButton:self.cancelButton];
		[self applyTextAttributes:self.buttonTitleTextAttributes toButton:self.cancelButton];
        [self applyHighlightTextAttributes:self.buttonTitleHighlightedTextAttributes toButton:self.cancelButton];
	}
    
	for(UIButton *otherButton in self.otherButtons)
	{
		[self applyBackgroundImages:self.buttonBackgroundImagesForControlStates
						   toButton:otherButton];
		[self applyTextAttributes:self.buttonTitleTextAttributes toButton:otherButton];
        [self applyHighlightTextAttributes:self.buttonTitleHighlightedTextAttributes toButton:otherButton];
	}
}

- (void)setTitleFont:(UIFont *)font textStyle:(TextStyle *)style
{
    [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     font, UITextAttributeFont,
                                                     style.color, UITextAttributeTextColor,
                                                     style.shadowColor, UITextAttributeTextShadowColor,
                                                     style.shadowOffset, UITextAttributeTextShadowOffset,
                                                     nil]];
}

- (void)setMessageFont:(UIFont *)font textStyle:(TextStyle *)style
{
    [self setMessageTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                  font, UITextAttributeFont,
                                  style.color, UITextAttributeTextColor,
                                  style.shadowColor, UITextAttributeTextShadowColor,
                                  style.shadowOffset, UITextAttributeTextShadowOffset,
                                  nil]];
}

- (void)setButtonTitleFont:(UIFont *)font textStyle:(TextStyle *)style
{
    [self setButtonTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                    font, UITextAttributeFont,
                                    style.color, UITextAttributeTextColor,
                                    style.shadowColor, UITextAttributeTextShadowColor,
                                    style.shadowOffset, UITextAttributeTextShadowOffset,
                                    nil]];
}
- (void)setButtonTitleHighlightedFont:(UIFont *)font textStyle:(TextStyle *)style
{
    [self setButtonTitleHighlightedTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        font, UITextAttributeFont,
                                        style.color, UITextAttributeTextColor,
                                        style.shadowColor, UITextAttributeTextShadowColor,
                                        style.shadowOffset, UITextAttributeTextShadowOffset,
                                        nil]];
}

#pragma mark - Presentation and dismissal methods

- (void)show {
	[self showWithStyle:self.presentationStyle];
}

- (void)showWithStyle:(HaloAlertViewPresentationStyle)presentationStyle block:(HaloAlertViewButtonBlock)block
{
    self.alertBlock = block;
    [self showWithStyle:presentationStyle];
}

- (void)showWithStyle:(HaloAlertViewPresentationStyle)presentationStyle dismissStyle:(HaloAlertViewDismissalStyle)dissmissStyle block:(HaloAlertViewButtonBlock)block
{
    self.alertBlock = block;
    self.dismissalStyle = dissmissStyle;
    [self showWithStyle:presentationStyle];
}

- (void)show:(HaloAlertViewButtonBlock)block
{
    self.alertBlock = block;
    [self showWithStyle:self.presentationStyle];
}

- (void)showWithStyle:(HaloAlertViewPresentationStyle)style
{
	self.presentationStyle = style;
    
	// Create a new alert-level UIWindow instance and make key. We need to do this so
	// we appear above the status bar and can fade it appropriately.
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	self.alertWindow = [[UIWindow alloc] initWithFrame:screenBounds];
	self.alertWindow.windowLevel = UIWindowLevelAlert;
	self.previousKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
	[self.alertWindow makeKeyAndVisible];
    
	// Create a new radial gradiant background image to do the screen dimming effect
	self.dimView = [[UIImageView alloc] initWithFrame:self.alertWindow.bounds];
	self.dimView.image = [self backgroundGradientImageWithSize:self.alertWindow.bounds.size];
	self.dimView.userInteractionEnabled = YES;
	
	[self.alertWindow addSubview:self.dimView];
	[self.alertWindow addSubview:self];
    
	[self layoutIfNeeded];
    
	// Animate the alert view itself onto the screen
	[self performPresentationAnimation];
    
//将Timer加到当前的runloop
    if (self.textView)
    {
        NSTimer *timer = [NSTimer timerWithTimeInterval:.3 target:self selector:@selector(flashScrollIndicators) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
}


- (void)dismiss {
	// Hide with the current dismissal style
	[self dismissWithStyle:self.dismissalStyle];
}

- (void)dismissWithStyle:(HaloAlertViewDismissalStyle)style
{
	self.dismissalStyle = style;
    
	// Flag any methods that might want to change our transform that we're in the midst of a dismissal
	isDismissing = YES;
    
	// Force editing of any currently active text fields.
	[self endEditing:YES];
    
	[self performDismissalAnimation];
}

- (void)buttonWasPressed:(UIButton *)sender
{
	if(self.alertBlock)
    {
        NSInteger index = 0;
        if (sender == self.cancelButton)
        {
            index = 0;
        }
        else
        {
            index = [self.otherButtons indexOfObject:sender] + 1;
        }
		self.alertBlock(self,index);
    }
	// Automatically dismiss after the button tap event is propagated.
	[self dismissWithStyle:self.dismissalStyle];
    
}

#pragma mark - Presentation and dismissal animation utilities

- (void)performPresentationAnimation
{
	if(self.presentationStyle == HaloAlertViewPresentationStylePop)
	{
		// This animation makes the alert view zoom into view, overshoot slightly, and finally
		// settle in where it should be. It is very similar to the system animation for presenting alert views.
		
		// This implementation was inspired by Jeff LaMarche's article on custom UIAlertViews. Thanks!
		// See: http://iphonedevelopment.blogspot.com/2010/05/custom-alert-views.html
		CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animation];
		bounceAnimation.duration = 0.4;
		bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		bounceAnimation.values = [NSArray arrayWithObjects:
								  [NSNumber numberWithFloat:0.01],
								  [NSNumber numberWithFloat:1.1],
								  [NSNumber numberWithFloat:0.9],
								  [NSNumber numberWithFloat:1.0],
								  nil];
		
		[self.layer addAnimation:bounceAnimation forKey:@"transform.scale"];
        
		// While the alert view pops in, the background overlay fades in
		CABasicAnimation *fadeInAnimation = [CABasicAnimation animation];
		fadeInAnimation.duration = 0.4;
		fadeInAnimation.fromValue = [NSNumber numberWithFloat:0];
		fadeInAnimation.toValue = [NSNumber numberWithFloat:1];
		[self.dimView.layer addAnimation:fadeInAnimation forKey:@"opacity"];
	}
	else if(self.presentationStyle == HaloAlertViewPresentationStyleFade)
	{
		// This presentation animation is a slightly more subtle presentation with a gentle fade in.
        
		self.dimView.alpha = self.alpha = 0;
        
		[UIView animateWithDuration:0.3
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^
		 {
			 self.dimView.alpha = self.alpha = 1;
		 }
						 completion:nil];
	}
	else
	{
		// Views appear immediately when added
	}
	// As we're appearing, the first text field should become active.
	[[self textFieldAtIndex:0 throws:NO] becomeFirstResponder];
}

- (void)performDismissalAnimation
{
	// This block is called at the completion of the dismissal animations.
	AHAnimationCompletionBlock completionBlock = ^(BOOL finished)
	{
		// Remove relevant views.
		[self.dimView removeFromSuperview];
		[self removeFromSuperview];
        
		// Restore previous key window and tear down our own window
		[self.previousKeyWindow makeKeyWindow];
		self.alertWindow = nil;
		self.previousKeyWindow = nil;
        
		// We are no longer dismissing and can be re-presented or destroyed.
		isDismissing = NO;
	};
	
	if(self.dismissalStyle == HaloAlertViewDismissalStyleTumble)
	{
		// This animation does a Tweetbot-style tumble animation where the alert view "falls"
		// off the screen while rotating slightly off-kilter. Use sparingly.
		[UIView animateWithDuration:0.6
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^
		 {
			 CGPoint offset = CGPointMake(0, self.superview.bounds.size.height * 1.5);
			 offset = CGPointApplyAffineTransform(offset, self.transform);
			 self.transform = CGAffineTransformConcat(self.transform, CGAffineTransformMakeRotation(-M_PI_4));
			 self.center = CGPointMake(self.center.x + offset.x, self.center.y + offset.y);
			 self.dimView.alpha = 0;
		 }
						 completion:completionBlock];
	}
	else if(self.dismissalStyle == HaloAlertViewDismissalStyleFade)
	{
		// This animation subtly fades out the alert view over a short period.
		[UIView animateWithDuration:0.25
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:^
		 {
			 self.dimView.alpha = self.alpha = 0;
		 }
						 completion:completionBlock];
	}
	else if(self.dismissalStyle == HaloAlertViewDismissalStyleZoomDown)
	{
		// This animation zooms the alert view down, "into" the screen, while fading.
		[UIView animateWithDuration:0.3
							  delay:0.0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^
		 {
			 self.transform = CGAffineTransformConcat(self.transform, CGAffineTransformMakeScale(0.01, 0.01));
			 self.dimView.alpha = self.alpha = 0;
		 }
						 completion:completionBlock];
	}
	else if(self.dismissalStyle == HaloAlertViewDismissalStyleZoomOut)
	{
		// This animation zooms the alert view out, "toward" the viewer, while fading.
		[UIView animateWithDuration:0.25
							  delay:0.0
							options:UIViewAnimationOptionCurveLinear
						 animations:^
		 {
			 self.transform = CGAffineTransformConcat(self.transform, CGAffineTransformMakeScale(10, 10));
			 self.dimView.alpha = self.alpha = 0;
		 }
						 completion:completionBlock];
	}
	else
	{
		completionBlock(YES);
	}
}

#pragma mark - Layout calculation methods

- (void)layoutSubviews
{
	[super layoutSubviews];
    
	// Calculate the rectangle into which we should lay out our subviews, then extend the height infinitely downward
	CGRect boundingRect = self.bounds;
	boundingRect = UIEdgeInsetsInsetRect(boundingRect, self.contentInsets);
	boundingRect.size.height = FLT_MAX;
    
	// Lay out the various subviews, keeping track of the permissible bounding rectangle at each step.
	boundingRect = [self layoutTitleLabelWithinRect:boundingRect];
	boundingRect = [self layoutMessageLabelWithinRect:boundingRect];
	boundingRect = [self layoutTextFieldsWithinRect:boundingRect];
    boundingRect = [self layoutTextViewWithinRect:boundingRect];
	boundingRect = [self layoutButtonsWithinRect:boundingRect];
    
	// Since we now know the downward extent of all of the subviews, we know the proper bounds to assign ourselves.
	CGRect newBounds = CGRectMake(0, 0, self.bounds.size.width, boundingRect.origin.y + self.customViewHeight);
	self.bounds = newBounds;
    
	// Configure the background image view.
	[self layoutBackgroundImageView];
    
	// Rotate and position the alert view based on the new layout.
	[self reposition];
}

- (CGRect)layoutTitleLabelWithinRect:(CGRect)boundingRect
{
	// Lazily generate a title label.
	if(!self.titleLabel && self.title)
		self.titleLabel = [self addLabelAsSubview];
    
	// Assign appropriate text attributes to this label, then calculate a suitable frame for it.
	[self applyTextAttributes:self.titleTextAttributes toLabel:self.titleLabel];
	self.titleLabel.text = self.title;
	CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font
										constrainedToSize:boundingRect.size
											lineBreakMode:NSLineBreakByWordWrapping];
	self.titleLabel.frame = CGRectMake(boundingRect.origin.x, boundingRect.origin.y,
									   boundingRect.size.width, titleSize.height);
    
	// Adjust and return the bounding rect for the rest of the layout.
	CGFloat margin = (titleSize.height > 0) ? AHAlertViewTitleLabelBottomMargin : 0;
	boundingRect.origin.y = boundingRect.origin.y + titleSize.height + margin;
	return boundingRect;
}

- (CGRect) layoutMessageLabelWithinRect:(CGRect)boundingRect
{
	// Lazily generate a message label.
	if(!self.messageLabel && self.message)
		self.messageLabel = [self addLabelAsSubview];
    
	// Assign appropriate text attributes to this label, then calculate a suitable frame for it.
	[self applyTextAttributes:self.messageTextAttributes toLabel:self.messageLabel];
	self.messageLabel.text = self.message;
	CGSize messageSize = [self.messageLabel.text sizeWithFont:self.messageLabel.font
											constrainedToSize:boundingRect.size
												lineBreakMode:NSLineBreakByWordWrapping];
	self.messageLabel.frame = CGRectMake(boundingRect.origin.x, boundingRect.origin.y,
										 boundingRect.size.width, messageSize.height);
    
	// Adjust and return the bounding rect for the rest of the layout.
	CGFloat margin = (messageSize.height > 0) ? AHAlertViewMessageLabelBottomMargin : 0;
	boundingRect.origin.y = boundingRect.origin.y + messageSize.height + margin;
	return boundingRect;
}

// Internal utility to create or destroy text fields based on current alert view style
- (void)ensureTextFieldsForCurrentAlertStyle
{
	BOOL wantsPlainTextField = (self.alertViewStyle == HaloAlertViewStylePlainTextInput ||
								self.alertViewStyle == HaloAlertViewStyleLoginAndPasswordInput);
	BOOL wantsSecureTextField = (self.alertViewStyle == HaloAlertViewStyleSecureTextInput ||
								 self.alertViewStyle == HaloAlertViewStyleLoginAndPasswordInput);
    
	if(!wantsPlainTextField)
	{
		[self.plainTextField removeFromSuperview];
		self.plainTextField = nil;
	}
	else if(wantsPlainTextField && !self.plainTextField)
	{
		self.plainTextField = [[UITextField alloc] initWithFrame:CGRectZero];
		self.plainTextField.backgroundColor = [UIColor whiteColor];
		self.plainTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
		self.plainTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		self.plainTextField.returnKeyType = UIReturnKeyNext;
		self.plainTextField.borderStyle = UITextBorderStyleLine;
		[self addSubview:self.plainTextField];
	}
    
	if(!wantsSecureTextField)
	{
		[self.secureTextField removeFromSuperview];
		self.secureTextField = nil;
	}
	else if(wantsSecureTextField && !self.secureTextField)
	{
		self.secureTextField = [[UITextField alloc] initWithFrame:CGRectZero];
		self.secureTextField.backgroundColor = [UIColor whiteColor];
		self.secureTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
		self.secureTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		self.secureTextField.returnKeyType = UIReturnKeyNext;
		self.secureTextField.borderStyle = UITextBorderStyleLine;
		self.secureTextField.secureTextEntry = YES;
		[self addSubview:self.secureTextField];
	}
}

- (CGRect)layoutTextFieldsWithinRect:(CGRect)boundingRect
{
	// Ensure we have text fields to lay out.
	[self ensureTextFieldsForCurrentAlertStyle];
    
	NSMutableArray *textFields = [NSMutableArray arrayWithCapacity:2];
    
	if(self.plainTextField)
		[textFields addObject:self.plainTextField];
	if(self.secureTextField)
		[textFields addObject:self.secureTextField];
    
	// Position the text fields in the current bounding rectangle.
	for(UITextField *textField in textFields)
	{
		CGRect fieldFrame = CGRectMake(boundingRect.origin.x, boundingRect.origin.y,
									   boundingRect.size.width, AHAlertViewDefaultTextFieldHeight);
		textField.frame = fieldFrame;
        
		CGFloat leading = (textField != [textFields lastObject]) ? AHAlertViewTextFieldLeading : 0;
		boundingRect.origin.y = CGRectGetMaxY(fieldFrame) + leading;
	}
    
	// Adjust and return the bounding rect for the rest of the layout.
	if([textFields count] > 0)
		boundingRect.origin.y += AHAlertViewTextFieldBottomMargin;
	return boundingRect;
}

- (CGRect)layoutTextViewWithinRect:(CGRect)boundingRect
{
    if (self.textView)
    {
        self.textView.frame = CGRectMake(boundingRect.origin.x, boundingRect.origin.y, boundingRect.size.width, AHAlertViewDefaultTextViewHeight);
        boundingRect.origin.y = CGRectGetMaxY(self.textView.frame) + 8;
        DDLogInfo(@"HaloalertView Layout TextView");
    }
    return boundingRect;
}

- (CGRect)layoutButtonsWithinRect:(CGRect)boundingRect
{
	[self applyAppearanceAttributesToButtons];
    
	NSArray *allButtons = [self allButtonsInHIGDisplayOrder];
    
	if([self shouldUseSingleRowButtonLayout])
	{
		CGFloat buttonOriginX = self.bounds.origin.x;
		CGFloat buttonWidth = ((self.bounds.size.width + AHAlertViewButtonHorizontalSpacing) / [allButtons count]);
		buttonWidth -= AHAlertViewButtonHorizontalSpacing;
        
        
        int i = 0;
		for(UIButton *button in allButtons)
		{
			CGRect buttonFrame = CGRectMake(buttonOriginX, boundingRect.origin.y,
											buttonWidth, AHAlertViewDefaultButtonHeight);
            
            [self addStrokeLineViewBtnFram:buttonFrame horizon:YES];
            
			button.frame = buttonFrame;
            
			buttonOriginX = CGRectGetMaxX(buttonFrame) + AHAlertViewButtonHorizontalSpacing;
            
            if (i == 1)
            {
                [self addStrokeLineViewBtnFram:buttonFrame horizon:NO];
            }
            
            i++;
		}
		
		boundingRect.origin.y = CGRectGetMaxY([[allButtons lastObject] frame]);
	}
	else
	{
        
		for(UIButton *button in allButtons)
		{
            
			CGRect buttonFrame = CGRectMake(boundingRect.origin.x, boundingRect.origin.y,
											boundingRect.size.width, AHAlertViewDefaultButtonHeight);
            
            [self addStrokeLineViewBtnFram:buttonFrame horizon:YES];
            
			button.frame = buttonFrame;
            
			CGFloat margin = (button != [allButtons lastObject]) ? AHAlertViewButtonBottomMargin : 0;
			boundingRect.origin.y = CGRectGetMaxY(buttonFrame) + margin;
            
            
		}
        
	}
	return boundingRect;
}

- (void)addStrokeLineViewBtnFram:(CGRect)frame  horizon:(BOOL)horizon
{
    CGRect lineFrame = CGRectZero;
    if (horizon)
    {
        lineFrame = CGRectMake(frame.origin.x,  frame.origin.y, frame.size.width, 0.5);
    }
    else
    {
        lineFrame = CGRectMake(frame.origin.x, frame.origin.y, 0.5, frame.size.height);
    }
    UIView *strokeView = [[UIView alloc] initWithFrame:lineFrame];
    strokeView.backgroundColor = [[UIColor alloc] initWithWhite:(182.0/255.0) alpha:1];
    [self addSubview:strokeView];
}

- (void)layoutBackgroundImageView
{
	// Lazily create background image view and set its properties.
	if(!self.backgroundImageView)
	{
		self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
//        self.backgroundColor = [UIColor redColor];
		self.backgroundImageView.autoresizingMask = AHViewAutoresizingFlexibleSizeAndMargins;
		self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
		[self insertSubview:self.backgroundImageView atIndex:0];
	}
    
	self.backgroundImageView.image = self.backgroundImage;
}

// Utility method to add a new center-aligned, multi-line label to this alert view
- (UILabel *)addLabelAsSubview
{
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.numberOfLines = 0;
	[self addSubview:label];
	
	return label;
}

// If there are exactly two buttons, we position them side-by-side rather than stacked, regardless of title widths.
- (BOOL)shouldUseSingleRowButtonLayout
{
	NSInteger buttonCount =
    [self.otherButtons count] +
    ((self.cancelButton) ? 1 : 0);
    
	if(buttonCount != 2)
		return NO;
    
	UIButton *cancelButtonOrNil = self.cancelButton;
	UIButton *onlyOtherButtonOrNil = nil;
	if([self.otherButtons count] == 1)
		onlyOtherButtonOrNil = [self.otherButtons objectAtIndex:0];
    
	return (cancelButtonOrNil && onlyOtherButtonOrNil);
}

// This method tries to compensate for HIG recommendations regarding button layout, but does so incompletely.
- (NSArray *)allButtonsInHIGDisplayOrder
{
	// Add all buttons to a common array, starting with destructive, followed by normal, finishing with cancel.
	NSMutableArray *allButtons = [NSMutableArray array];
    if([self.otherButtons count] > 0)
    {
		[allButtons addObjectsFromArray:self.otherButtons];
    }
	if(self.cancelButton)
    {
        [allButtons addObject:self.cancelButton];
    }
    
	// If there are just two buttons, position them side-by-side, cancel button first.
	if([self shouldUseSingleRowButtonLayout])
	{
		allButtons = [NSMutableArray arrayWithObjects:self.cancelButton, [allButtons objectAtIndex:0], nil];
	}
    
	return allButtons;
}

#pragma mark - Keyboard helpers

- (void)keyboardFrameChanged:(NSNotification *)notification
{
	// Toggle keyboard visibility flag based on which notification we're receiving.
	keyboardIsVisible = ![notification.name isEqualToString:UIKeyboardWillHideNotification];
    
	// Retrieve keyboard frame in screen space and transform it to window space.
	CGRect keyboardFrame = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	keyboardHeight = keyboardFrame.size.height;
    
	// If the keyboard will soon be invisible, zero-out the stored height.
	if(!keyboardIsVisible)
		keyboardHeight = 0.0;
    
	// If we're not currently dismissing, we should position ourselves to account for the keyboard.
	if(!isDismissing)
		[self setNeedsLayout];
}

#pragma mark - Orientation helpers

- (CGAffineTransform)transformForCurrentOrientation
{
	// Calculate a rotation transform that matches the current interface orientation.
	CGAffineTransform transform = CGAffineTransformIdentity;
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if(orientation == UIInterfaceOrientationPortraitUpsideDown)
		transform = CGAffineTransformMakeRotation(M_PI);
	else if(orientation == UIInterfaceOrientationLandscapeLeft)
		transform = CGAffineTransformMakeRotation(-M_PI_2);
	else if(orientation == UIInterfaceOrientationLandscapeRight)
		transform = CGAffineTransformMakeRotation(M_PI_2);
	
	return transform;
}

- (void)reposition
{
	CGAffineTransform baseTransform = [self transformForCurrentOrientation];
    
	// This block contains all of the logic for how we position ourselves to account for the
	// presence of the keyboard and the current interface orientation.
	AHAnimationBlock layoutBlock = ^
	{
		self.transform = baseTransform;
        
		// Try to center ourselves in the space above the keyboard.
		CGPoint keyboardOffset = CGPointMake(0, -keyboardHeight);
		keyboardOffset = CGPointApplyAffineTransform(keyboardOffset, self.transform);
		CGRect superviewBounds = self.superview.bounds;
		superviewBounds.size.width += keyboardOffset.x;
		superviewBounds.size.height += keyboardOffset.y;
        
		CGPoint newCenter = CGPointMake(superviewBounds.size.width * 0.5, superviewBounds.size.height * 0.5);
		self.center = newCenter;
	};
    
	// Determine if the rotation we're about to undergo is 90 degrees or 180 degrees.
	CGFloat delta = CGAffineTransformGetAbsoluteRotationAngleDifference(self.transform, baseTransform);
	const CGFloat HALF_PI = 1.581; // Don't use M_PI_2 here; precision errors will cause incorrect results below.
	BOOL isDoubleRotation = (delta > HALF_PI);
    
	// If we've layed out before, we should rotate to the new orientation.
	if(hasLayedOut)
	{
		// Use the system rotation duration.
		CGFloat duration = [[UIApplication sharedApplication] statusBarOrientationAnimationDuration];
        
		// Egregious hax. iPad lies about its rotation duration.
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			duration = 0.4;
        
		// Simply double the animation duration if we're rotating a full 180 degrees.
		if(isDoubleRotation)
			duration *= 2;
        
		[UIView animateWithDuration:duration animations:layoutBlock];
	}
	else
	{
		// We've never layed out before, so we should do it without animating, to prevent weird rotations.
		layoutBlock();
	}
    
	hasLayedOut = YES;
}

#pragma mark - Drawing utilities for implementing system control styles

- (UIImage *)backgroundGradientImageWithSize:(CGSize)size
{
	CGPoint center = CGPointMake(size.width * 0.5, size.height * 0.5);
	CGFloat innerRadius = 0;
    CGFloat outerRadius = sqrtf(size.width * size.width + size.height * size.height) * 0.5;
    
	BOOL opaque = NO;
    UIGraphicsBeginImageContextWithOptions(size, opaque, [[UIScreen mainScreen] scale]);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    const size_t locationCount = 2;
    CGFloat locations[locationCount] = { 0.0, 1.0 };
    CGFloat components[locationCount * 4] = {
		0.0, 0.0, 0.0, 0.1, // More transparent black
		0.0, 0.0, 0.0, 0.7  // More opaque black
	};
	
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, locationCount);
	
    CGContextDrawRadialGradient(context, gradient, center, innerRadius, center, outerRadius, 0);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGColorSpaceRelease(colorspace);
    CGGradientRelease(gradient);
	
    return image;
}


#pragma mark - Class drawing utilities for implementing system control styles

+ (UIImage *)alertBackgroundImage
{
	CGRect rect = CGRectMake(0, 0, AHAlertViewDefaultWidth, AHAlertViewMinimumHeight);
    
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:6.0];
    
    UIColor *color = [[UIColor alloc] initWithWhite:0.9 alpha:1];
    UIImage *bgImg = [UIImage imageWithBezierPath:path color:color backgroundColor:color];
    
    return bgImg;
}

+ (UIImage *)normalButtonBackgroundImage
{
    return nil;
    
	const size_t locationCount = 4;
	CGFloat opacity = 1.0;
    CGFloat locations[locationCount] = { 0.0, 0.5, 0.5 + 0.0001, 1.0 };
    CGFloat components[locationCount * 4] = {
		179/255.0, 185/255.0, 199/255.0, opacity,
		121/255.0, 132/255.0, 156/255.0, opacity,
		87/255.0, 100/255.0, 130/255.0, opacity,
		108/255.0, 120/255.0, 146/255.0, opacity,
	};
	return [self glassButtonBackgroundImageWithGradientLocations:locations
													  components:components
												   locationCount:locationCount];
}

+ (UIImage *)cancelButtonBackgroundImage
{
    return nil;
    
	const size_t locationCount = 4;
	CGFloat opacity = 1.0;
    CGFloat locations[locationCount] = { 0.0, 0.5, 0.5 + 0.0001, 1.0 };
    CGFloat components[locationCount * 4] = {
		164/255.0, 169/255.0, 184/255.0, opacity,
		77/255.0, 87/255.0, 115/255.0, opacity,
		51/255.0, 63/255.0, 95/255.0, opacity,
		78/255.0, 88/255.0, 116/255.0, opacity,
	};
	return [self glassButtonBackgroundImageWithGradientLocations:locations
													  components:components
												   locationCount:locationCount];
}

+ (UIImage *)glassButtonBackgroundImageWithGradientLocations:(CGFloat *)locations
												  components:(CGFloat *)components
											   locationCount:(NSInteger)locationCount
{
	const CGFloat lineWidth = 1;
	const CGFloat cornerRadius = 4;
	UIColor *strokeColor = [UIColor colorWithRed:1/255.0 green:11/255.0 blue:39/255.0 alpha:1.0];
	
	CGRect rect = CGRectMake(0, 0, cornerRadius * 2 + 1, AHAlertViewDefaultButtonHeight);
    
	BOOL opaque = NO;
    UIGraphicsBeginImageContextWithOptions(rect.size, opaque, [[UIScreen mainScreen] scale]);
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, locationCount);
	
	CGRect strokeRect = CGRectInset(rect, lineWidth * 0.5, lineWidth * 0.5);
	UIBezierPath *strokePath = [UIBezierPath bezierPathWithRoundedRect:strokeRect cornerRadius:cornerRadius];
	strokePath.lineWidth = lineWidth;
	[strokeColor setStroke];
	[strokePath stroke];
	
	CGRect fillRect = CGRectInset(rect, lineWidth, lineWidth);
	UIBezierPath *fillPath = [UIBezierPath bezierPathWithRoundedRect:fillRect cornerRadius:cornerRadius];
	[fillPath addClip];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	CGFloat capHeight = floorf(rect.size.height * 0.5);
	return [image resizableImageWithCapInsets:UIEdgeInsetsMake(capHeight, cornerRadius, capHeight, cornerRadius)];
}

@end
