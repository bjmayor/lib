
//
//  HaloUITableCell.m
//  HaloSlimFramework
//
//  Created by  on 13-5-20.
//
//

#import "HaloUITableCell.h"
#import "HaloUITableView.h"
@implementation HaloUITableCellInnerView
- (void)drawRect:(CGRect)rect
{
	[self.cell drawContentView:rect];
}


- (void)setFrame:(CGRect)frame
{
    if(!self.transiting)
    {
        [super setFrame:frame];
    }
}

@end

@interface HaloUITableCell()
@property (nonatomic, strong) UIImageView *customSeparatorView;
@property (nonatomic, strong) HaloUITableCellInnerView *inner;
@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, assign) BOOL menuShowing;
@property (nonatomic, strong) NSMutableArray *rightButtons;
@property (nonatomic, assign) BOOL  disableSep;
@end

@implementation HaloUITableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _inner = [[HaloUITableCellInnerView alloc] initWithFrame:CGRectZero];
		_inner.cell = self;
		_inner.opaque = NO;
        _inner.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
		_inner.clipsToBounds = YES;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_inner];
        //disable multitouchable
        self.exclusiveTouch = YES;
        self.originalCenter = CGPointZero;

    }
    return self;
}

- (void)setUseGuesture:(BOOL)useGuesture
{
    _useGuesture = useGuesture;
//    if (useGuesture && self.contentView.gestureRecognizers.count == 0)
    {
        UIGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        recognizer.delegate = self;
        [self.contentView addGestureRecognizer:recognizer];
        self.backgroundView = [[UIView alloc] init];
        self.backgroundView.backgroundColor = self.backgroundColor;
        self.backgroundView.frame = self.bounds;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.menuShowing)
    {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.menuShowing)
    {
        [self enableMenuOpen:NO];
    }
    else
    {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!CGPointEqualToPoint(self.originalCenter, CGPointZero))
    {
        self.contentView.center = self.originalCenter;
    }
//    self.contentView.top = 0;
    self.inner.frame = self.contentView.bounds;
    
    if (_customSeparatorView)
    {
        self.customSeparatorView.frame = CGRectMake(0, (self.height - 0.5), self.contentView.width, 0.5);
    }
    
    if (self.useGuesture)
    {
        NSInteger j=1;
        for (NSInteger i=self.rightButtons.count - 1; i>=0; i--)
        {
            UIButton *btn = self.rightButtons[i];
            btn.frame = CGRectMake(self.width - [self rightButtonWidth]*j++, 0, [self rightButtonWidth], self.contentView.height);
        }
    }
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [_inner setNeedsDisplay];
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    _inner.transiting = YES;
    [super willTransitionToState:state];
}

- (void)didTransitionToState:(UITableViewCellStateMask)state
{
    _inner.transiting = NO;
    [super didTransitionToState:state];
    _inner.frame = self.contentView.bounds;
    [_inner setNeedsDisplay];
}

- (void)setSeparatorImage:(UIImage *)image
{
    if (self.disableSep)
    {
        return;
    }
    
    if (!self.customSeparatorView)
    {
        self.customSeparatorView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:self.customSeparatorView];
    }
    else
    {
        self.customSeparatorView.image = image;
    }
}

- (void)disableSeparator
{
    [self.customSeparatorView removeFromSuperview];
    self.customSeparatorView = nil;
    self.disableSep = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.indexPath = nil;
}

- (void)drawContentView:(CGRect)rect
{
    
}

#pragma mark - horizontal pan gesture methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {        
        CGPoint translation = [((UIPanGestureRecognizer *)gestureRecognizer) translationInView:[self superview]];
        
        // Check for horizontal gesture
        if (fabsf(translation.x) > fabsf(translation.y) && (translation.x < 0 || self.menuShowing))
        {
            return YES;
        }
        
        return NO;
    }
    return YES;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    BOOL anotherEditing = NO;
    if ([self.superview isKindOfClass:[HaloUITableView class]])
    {
        HaloUITableView *table = (HaloUITableView *)self.superview;
        if (table.cellForShowingButtons && table.cellForShowingButtons != self)
        {
            anotherEditing = YES;
        }
    }

    // if the gesture has just started, record the current centre location
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        self.originalCenter = self.contentView.center;
        [self hideRightButtons:NO];
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        // translate the center
        CGPoint translation = [recognizer translationInView:self];
        self.contentView.center = CGPointMake(self.originalCenter.x + translation.x, self.originalCenter.y);
        if (self.contentView.left > 0 || anotherEditing)
        {
            self.contentView.left = 0;
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (anotherEditing)
        {
            [((HaloUITableView *)self.superview) hideCellButtons];
            return;
        }
        DDLogVerbose(@"handlePan: %d",recognizer.state);
        if (self.contentView.left < (0 - self.rightButtons.count * [self rightButtonWidth] ))
        {
            CGPoint translation = [recognizer translationInView:self];
            if (translation.x < 0)
            {
                [self enableMenuOpen:YES];
            }
            else
            {
                [self enableMenuOpen:NO];
            }
        }
        else
        {
            [self enableMenuOpen:NO];
        }
    }
}

- (void)enableMenuOpen:(BOOL)open
{
    if (!open)
    {
        CGRect originalFrame = CGRectMake(0, 0, self.width, self.height);
        
        self.menuShowing = NO;
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.contentView.frame = originalFrame;
            self.originalCenter = self.contentView.center;
        } completion:^(BOOL finished) {
            [self hideRightButtons:YES];
        }];
    }
    else
    {
        self.menuShowing = YES;
        NSInteger count = self.rightButtons.count;
        CGRect originalFrame = CGRectMake(0 - count*[self rightButtonWidth], 0, self.width, self.height);
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.contentView.frame = originalFrame;
            self.originalCenter = self.contentView.center;
        } completion:nil];
    }
}
         
- (void)hideRightButtons:(BOOL)hidden
{
    for (UIButton *button in self.rightButtons)
    {
        button.hidden = hidden;
    }
}

- (void)setMenuShowing:(BOOL)menuShowing
{
    _menuShowing = menuShowing;
    if ([self.superview isKindOfClass:[HaloUITableView class]])
    {
        ((HaloUITableView *)self.superview).cellForShowingButtons = menuShowing ? self:nil;
    }
}

- (void)addRightButton:(UIButton *)button
{
    if (self.rightButtons == nil)
    {
        self.rightButtons = [NSMutableArray arrayWithCapacity:5];
    }
    button.top = 0.5;
    button.height = self.contentView.height - 1;
    button.hidden = YES;
    [self.rightButtons addObject:button];
    [self.backgroundView addSubview:button];
}

- (void)resetRightButtons
{
    [self.rightButtons removeAllObjects];
}

- (NSInteger)rightButtonWidth
{
    return 65;
}

- (void)showRightButtons
{
    [self hideRightButtons:NO];
    [self enableMenuOpen:YES];
}

- (void)endShowRightButtons
{
    [self enableMenuOpen:NO];
}

- (BOOL)showingRightButtons
{
    return self.menuShowing;
}

@end
