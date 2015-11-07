//
// REActivityView.h
// REActivityViewController
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "REActivityView.h"
NSString *REActivitySubject = @"subject";
NSString *REActivityText = @"text";
NSString *REActivityImage = @"image";
NSString *REActivityURL = @"url";
NSString *REActivityCoordinate = @"coordinate";

@interface REActivityView()
@property (nonatomic,strong) UIWindow *alertWindow;
@property (nonatomic,strong) UIWindow *previousKeyWindow;
@property (nonatomic,strong) UIView *dimView;
@end
@implementation REActivityView

- (id)initWithActivities:(NSArray *)activities
{
    CGRect frame = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        _activities = activities;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 39, frame.size.width, self.frame.size.height - 104)];
        _scrollView.backgroundColor = [UIColor colorWithRGBA:0xeeeeeeff];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_scrollView];
        
        NSInteger index = 0;
        NSInteger row = -1;
        NSInteger page = -1;
        for (REActivity *activity in _activities) {
            NSInteger col;
            
            col = index%3;
            if (index % 3 == 0) row++;
            if (IS_IPHONE_5) {
                if (index % 12 == 0) {
                    row = 0;
                    page++;
                }
            } else {
                if (index % 9 == 0) {
                    row = 0;
                    page++;
                }
            }

            UIView *view = [self viewForActivity:activity
                                           index:index
                                               x:(20 + col*80 + col*20) + page * frame.size.width
                                               y:row*80 + row*20];
            [_scrollView addSubview:view];
            index++;
        }
        _scrollView.contentSize = CGSizeMake((page +1) * frame.size.width, _scrollView.frame.size.height);
        _scrollView.pagingEnabled = YES;
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 74, frame.size.width, 10)];
//        _pageControl.backgroundColor = [UIColor whiteColor];
        _pageControl.alpha = 0.85;
        _pageControl.numberOfPages = page + 1;
        [_pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_pageControl];
        
        if (_pageControl.numberOfPages <= 1) {
            _pageControl.hidden = YES;
            _scrollView.scrollEnabled = NO;
        }
        
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        NSInteger height = 50;
        _cancelButton.frame = CGRectMake(0, self.height - height, self.width, height);
        _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        

        NSString *fupath = [[NSBundle mainBundle] pathForResource:@"REActivityViewController" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:fupath];
        
        [_cancelButton setTitle:NSLocalizedStringFromTableInBundle(@"button.cancel", @"REActivityViewController",bundle, @"Cancel") forState:UIControlStateNormal];
        UIFont *cancelFont = [UIFont iOS7SystemFontOfSize:17 attribute:UI7FontAttributeMedium];
        UIColor *btnFontColor = [UIColor systemBlue];
        [_cancelButton setTitleColor:btnFontColor forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:cancelFont];
        [_cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
    }
    return self;
}

- (UIView *)viewForActivity:(REActivity *)activity index:(NSInteger)index x:(NSInteger)x y:(NSInteger)y
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, y, 80, 80)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, 0, 59, 59);
    button.layer.cornerRadius = 11.0f;
    button.layer.masksToBounds = YES;
//    button.layer.borderColor = [UIColor blackColor].CGColor;
//    button.layer.borderWidth = 1;
    button.tag = index;
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:activity.image forState:UIControlStateNormal];
    button.accessibilityLabel = activity.title;
    [view addSubview:button];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, button.bottom + 6, 80, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.text = activity.title;
    label.font = [UIFont systemFontOfSize:12];
    label.numberOfLines = 0;
    [label setNumberOfLines:0];
    [label sizeToFit];
    CGRect frame = label.frame;
    frame.origin.x = roundf((view.frame.size.width - frame.size.width) / 2.0f);
    label.frame = frame;
    [view addSubview:label];
    
    return view;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // For iPhone and iPod
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        NSInteger index = 0;
        NSInteger row = -1;
        NSInteger page = -1;
        NSInteger height = 0;
        for (UIView *view in [_scrollView subviews]) {
            NSInteger col;
            CGRect frame = view.frame;
            if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
                col = index%3;
                if (index % 3 == 0) row++;
                if (IS_IPHONE_5) {
                    if (index % 12 == 0) {
                        row = 0;
                        page++;
                    }
                } else {
                    if (index % 9 == 0) {
                        row = 0;
                        page++;
                    }
                }
                
                frame.origin.x = (20 + col*80 + col*20) + page * self.frame.size.width;
                
            } else {
                col = index%4;
                if (index % 4 == 0) row++;
                if (index % 8 == 0) {
                    row = 0;
                    page++;
                }
                
                if (IS_IPHONE_5) {
                    frame.origin.x = (48 + col*80 + col*50) + page * self.frame.size.width;
                } else {
                    frame.origin.x = (20 + col*80 + col*40) + page * self.frame.size.width;
                }
            }
            
            frame.origin.y = row*80 + (row+1)*20;
            view.frame = frame;
            height = MAX(height,view.bottom);
            index++;
        }
        
        _scrollView.height = height + 20;
        _pageControl.numberOfPages = page + 1;
        
        if (_pageControl.numberOfPages <= 1) {
            _pageControl.hidden = YES;
            _scrollView.scrollEnabled = NO;
        } else {
            _pageControl.hidden = NO;
            _scrollView.scrollEnabled = YES;
        }
        
        _scrollView.top = self.bottom - self.scrollView.height - self.cancelButton.height;
        if (!_pageControl.hidden)
        {
            _scrollView.top -= _pageControl.height;
        }
        _scrollView.contentSize = CGSizeMake((page +1) * self.frame.size.width, _scrollView.frame.size.height);
        _scrollView.pagingEnabled = YES;
        _pageControl.frame = CGRectMake(0, self.scrollView.bottom, _pageControl.width, _pageControl.height);
        
        [self pageControlValueChanged:_pageControl];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // For iPad
        CGRect frame = _cancelButton.frame;
        frame.origin.y = self.frame.size.height - 47 - 16;
        frame.origin.x = (self.frame.size.width - frame.size.width) / 2.0f;
        _cancelButton.frame = frame;
    }
}

#pragma mark -
#pragma mark Button action

- (void)dismiss
{
//    [_activityViewController dismissViewControllerAnimated:YES completion:nil];
    // This block is called at the completion of the dismissal animations.
	dispatch_block_t block = ^{
		// Remove relevant views.
		[self removeFromSuperview];
        
		// Restore previous key window and tear down our own window
		[self.previousKeyWindow makeKeyWindow];
		self.alertWindow = nil;
		self.previousKeyWindow = nil;
	};
	
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.dimView.alpha = 0;
                         self.top = self.bottom;
                     }
                     completion:^(BOOL finished) {
                         block();
                     }];

}

- (void)buttonPressed:(UIButton *)button
{
    REActivity *activity = [_activities objectAtIndex:button.tag];
    if (activity.actionBlock) {
        activity.actionBlock(activity, self);
    }
    [self dismiss];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}

#pragma mark -

- (void)pageControlValueChanged:(UIPageControl *)pageControl
{
    CGFloat pageWidth = _scrollView.contentSize.width /_pageControl.numberOfPages;
    CGFloat x = _pageControl.currentPage * pageWidth;
    [_scrollView scrollRectToVisible:CGRectMake(x, 0, pageWidth, _scrollView.frame.size.height) animated:YES];
}


- (void)show:(UIViewController *)viewController
{
    self.viewController = viewController;
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	self.alertWindow = [[UIWindow alloc] initWithFrame:screenBounds];
	self.alertWindow.windowLevel = UIWindowLevelAlert;
	self.previousKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
	[self.alertWindow makeKeyAndVisible];
    
	// Create a new radial gradiant background image to do the screen dimming effect
    
    self.dimView = [[UIView alloc] initWithFrame:self.alertWindow.bounds];
    self.dimView.userInteractionEnabled = YES;
    self.dimView.backgroundColor = [UIColor blackColor];

    [self.alertWindow addSubview:self.dimView];
    [self.alertWindow addSubview:self];
    self.dimView.alpha = 0.0;
    self.top = self.bottom;
    [UIView animateWithDuration:0.3 animations:^{
        self.dimView.alpha = 0.4;
        self.top = 0;
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}
@end
