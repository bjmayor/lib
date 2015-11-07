/* 
 
 Copyright (c) 2011, Philip Kluz (Philip.Kluz@zuui.org)
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of Philip Kluz, 'zuui.org' nor the names of its contributors may 
 be used to endorse or promote products derived from this software 
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL PHILIP KLUZ BE LIABLE FOR ANY DIRECT, 
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

/*
 * NOTE: Before editing the values below make sure they make 'sense'. Unexpected behavior might occur if for instance the 'REVEAL_LEFT_EDGE'
 *		 were to be lower than the left trigger level...
 */

// 'REVEAL_LEFT_EDGE' defines the point on the x-axis up to which the rear view is shown.


// 'REVEAL_LEFT_EDGE_OVERDRAW' defines the maximum offset that can occur after the 'REVEAL_LEFT_EDGE' has been reached.
#define REVEAL_LEFT_EDGE_OVERDRAW 60.0f

#define REVEAL_RIGHT_EDGE_OVERDRAW 5.f
// 'REVEAL_VIEW_TRIGGER_LEVEL_LEFT' defines the least amount of offset that needs to be panned until the front view snaps to the right edge.
#define REVEAL_VIEW_TRIGGER_LEVEL_LEFT 125.0f

// 'REVEAL_VIEW_TRIGGER_LEVEL_RIGHT' defines the least amount of translation that needs to be panned until the front view snaps _BACK_ to the left edge.
#define REVEAL_VIEW_TRIGGER_LEVEL_RIGHT 200.0f

// 'VELOCITY_REQUIRED_FOR_QUICK_FLICK' is the minimum speed of the finger required to instantly trigger a reveal/hide.
#define VELOCITY_REQUIRED_FOR_QUICK_FLICK 1300.0f

#define ANIMATION_DURATION_TIME 0.25f

#define ANIMATION_SPEED_ELEMENT 0.15f

#define ANIMATION_DURATION_MIN_TIME 0.15f

// Required for the shadow cast by the front view.
#import <QuartzCore/QuartzCore.h>

#import "ZUUIRevealController.h"


@interface ZUUIRevealController()<UIGestureRecognizerDelegate>

// Private Properties:
@property (strong, nonatomic) UIView *frontView;
@property (strong, nonatomic) UIView *rearView;
@property (assign, nonatomic) float previousPanOffset;
@property (strong, nonatomic) UIView *blackView;
@property (nonatomic, assign) Direction targetRearDirection;

// Private Methods:
- (CGFloat)_calculateOffsetForTranslationInView:(CGFloat)x;
- (void)_revealAnimationTriggerDirection:(Direction)direction speed:(CGFloat)speed;
- (void)_concealAnimationTriggerDirection:(Direction)direction speed:(CGFloat)speed;

- (void)_addFrontViewControllerToHierarchy:(UINavigationController *)frontViewController;
- (void)_addRearViewControllerToHierarchy:(UIViewController *)rearViewController;
- (void)_removeFrontViewControllerFromHierarchy:(UIViewController *)frontViewController;
- (void)_removeRearViewControllerFromHierarchy:(UIViewController *)rearViewController;

- (void)_swapCurrentFrontViewControllerWith:(UINavigationController *)newFrontViewController animated:(BOOL)animated couldChangeOpen:(BOOL)couldChangeOpen;

// Work in progress:
// - (void)_performRearViewControllerSwap:(UIViewController *)newRearViewController;
// - (void)setRearViewController:(UIViewController *)rearViewController; // Delegate Call.

@end

@implementation ZUUIRevealController

@synthesize previousPanOffset = _previousPanOffset;
@synthesize currentFrontViewPosition = _currentFrontViewPosition;
@synthesize frontViewController = _frontViewController;
@synthesize leftRearViewController = _leftRearViewController;
@synthesize rightRearViewController = _rightRearViewController;
@synthesize frontView = _frontView;
@synthesize rearView = _rearView;
@synthesize delegate = _delegate;

#pragma mark - Initialization


- (id)initWithFrontViewController:(UINavigationController *)aFrontViewController leftRearViewController:(HaloUIViewController *)leftViewController rightRearViewController:(HaloUIViewController *)rightViewController
{
	self = [super init];
	
	if (nil != self)
	{
        self.rearViewRevealWidth = 280;
		self.frontViewController = aFrontViewController;
		self.leftRearViewController = leftViewController ;
        self.rightRearViewController = rightViewController ;
	}
	
	return self;
}

#pragma mark - Reveal Callbacks

// Slowly reveal or hide the rear view based on the translation of the finger.
- (void)revealGesture:(UIPanGestureRecognizer *)recognizer
{
    
	// 2. 手势开始
	if (UIGestureRecognizerStateBegan == [recognizer state])
	{
		// Check if a delegate exists
		if ([self.delegate conformsToProtocol:@protocol(ZUUIRevealControllerDelegate)])
		{
			//检测是要收起还是展开
			if (FrontViewPositionOrigin == self.currentFrontViewPosition)
			{
                //LOG_DEBUG(@"open");
				if ([self.delegate respondsToSelector:@selector(revealController:willRevealRearViewController:)])
				{
					[self.delegate revealController:self willRevealRearViewController:self.targetRearDirection == Left ? self.leftRearViewController : self.rightRearViewController];
				}
			}
			else
			{
                //LOG_DEBUG(@"hiden");
				if ([self.delegate respondsToSelector:@selector(revealController:willHideRearViewController:)])
				{
					[self.delegate revealController:self willHideRearViewController:self.targetRearDirection == Left ? self.leftRearViewController : self.rightRearViewController];
				}
			}
		}
	}
	// 3.手势完成
	if (UIGestureRecognizerStateEnded == [recognizer state])
	{
        //LOG_DEBUG(@"gesture end");
        //LOG_DEBUG(@"target is %d",self.targetRearDirection);
        
        CGFloat speed = [recognizer velocityInView:self.view].x;
		// Case a): 手指快速滑动
		if (fabs(speed) > VELOCITY_REQUIRED_FOR_QUICK_FLICK)
		{
            //计算动画时间
            CGFloat animationSpeed = (fabs(speed) - VELOCITY_REQUIRED_FOR_QUICK_FLICK)/VELOCITY_REQUIRED_FOR_QUICK_FLICK;
            if(animationSpeed > 1)
            {
                animationSpeed = 1;
            }
            
            if (speed > 0.0f && self.targetRearDirection == Left)
            {
                //LOG_DEBUG(@"end, reveal left");
                [self _revealAnimationTriggerDirection:Left speed:animationSpeed];
            }
            else if (speed < 0.0f && self.targetRearDirection == Right)
            {
                //LOG_DEBUG(@"end, reveal right");
                [self _revealAnimationTriggerDirection:Right speed:animationSpeed];
            }
            else
            {
                //LOG_DEBUG(@"end, conceal");
                [self _concealAnimationTriggerDirection:self.targetRearDirection speed:animationSpeed];
            }
		}
		// Case b) 慢速pan/darg
		else
		{
            //LOG_DEBUG(@"slow pan");
            float dynamicTriggerLevel  = 0;
            if (self.targetRearDirection == Left)
            {
                dynamicTriggerLevel = (FrontViewPositionOrigin == self.currentFrontViewPosition) ? REVEAL_VIEW_TRIGGER_LEVEL_LEFT : REVEAL_VIEW_TRIGGER_LEVEL_RIGHT;
            }
            else
            {
                dynamicTriggerLevel = REVEAL_RIGHT_EDGE;
            }
			
            
			//LOG_DEBUG(@"dynamicTriggerLevel is %f",dynamicTriggerLevel);
            //LOG_DEBUG(@"self.frontView.frame.origin.x is %f",self.frontView.frame.origin.x);
            
			if (fabs(self.frontView.frame.origin.x) >= dynamicTriggerLevel && (self.frontView.frame.origin.x != self.rearViewRevealWidth || self.frontView.frame.origin.x != -REVEAL_RIGHT_EDGE))
			{
                //LOG_DEBUG(@"slow pan ,reveal");
				[self _revealAnimationTriggerDirection:self.targetRearDirection speed:0];
			}
			else if (fabs(self.frontView.frame.origin.x) < dynamicTriggerLevel && fabs(self.frontView.frame.origin.x) != 0.0f)
			{
                //LOG_DEBUG(@"slow pan ,conceal");
				[self _concealAnimationTriggerDirection:self.targetRearDirection speed:0];
			}
		}
		
		// Now adjust the current state enum.
		if (self.frontView.frame.origin.x == -REVEAL_RIGHT_EDGE)
		{
            //LOG_DEBUG(@"set right");
            self.currentFrontViewPosition = FrontViewPositionLeft;
		}
		else if(self.frontView.frame.origin.x == self.rearViewRevealWidth)
		{
            //LOG_DEBUG(@"set left");
			self.currentFrontViewPosition = FrontViewPositionRight;
		}
        else
        {
            //LOG_DEBUG(@"set origin");
			self.currentFrontViewPosition = FrontViewPositionOrigin;
            self.targetRearDirection = None;
        }
		
		return;
	}
	
	// 4.手势正在in progress
	if (FrontViewPositionOrigin == self.currentFrontViewPosition)
	{
        //从初始位置滑动
        //LOG_DEBUG(@"gesture inprogress");
        //LOG_DEBUG(@"Inprogress locationx is %f",[recognizer translationInView:self.view].x);
        
        float offset = [self _calculateOffsetForTranslationInView:[recognizer translationInView:self.view].x];
        //LOG_DEBUG(@"offset is %f",offset);
        if (offset > 0)
        {
            if (![self.delegate revealController:self shouldRevealRearViewController:self.leftRearViewController])
            {
                //LOG_DEBUG(@"left is disable");
                self.frontView.frame = CGRectMake(0, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
                return;
            }
        }
        else if(offset < 0)
        {
            if (![self.delegate revealController:self shouldRevealRearViewController:self.rightRearViewController])
            {
                //LOG_DEBUG(@"right is disable");
                 self.frontView.frame = CGRectMake(0, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
                return;
            }
        }
        //LOG_DEBUG(@"offset is %f",offset);
        self.frontView.frame = CGRectMake(offset, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
        
        CGFloat rate = 0;
        if (self.targetRearDirection == Left)
        {
            rate = fabs(self.frontView.frame.origin.x)/self.rearViewRevealWidth;
        }
        else
        {
            rate = fabs(self.frontView.frame.origin.x)/REVEAL_RIGHT_EDGE;
        }
         
        self.blackView.alpha = self.coverOpactity*(1-rate);
        [self bringItForwardWithAnimation:NO rate:rate speed:0 rearViewController:self.targetRearDirection];
	}
	else
	{
        //LOG_DEBUG(@"trans x = %f",[recognizer translationInView:self.view].x);
        //LOG_DEBUG(@"gesture progress , self.target is %d",self.targetRearDirection);
        
        NSInteger positiveOrNegative = self.targetRearDirection == Left ? 1 : -1;
        
        if (([recognizer translationInView:self.view].x >= 0.0f && self.targetRearDirection == Left) ||
            ([recognizer translationInView:self.view].x <= 0.0f && self.targetRearDirection == Right))
        {
            //LOG_DEBUG(@"gesture open 1 , self.target is %d",self.targetRearDirection);
            float offset = 0;
            if (self.targetRearDirection == Left)
            {
                offset = [self _calculateOffsetForTranslationInView:positiveOrNegative * (self.rearViewRevealWidth + fabs([recognizer translationInView:self.view].x))];
            }
            else
            {
                offset = [self _calculateOffsetForTranslationInView:positiveOrNegative * (REVEAL_RIGHT_EDGE + fabs([recognizer translationInView:self.view].x))];
            }
            
            self.frontView.frame = CGRectMake(offset, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
            
        }
        else if ([recognizer translationInView:self.view].x < 0 &&[recognizer translationInView:self.view].x  > -self.rearViewRevealWidth)
        {
            //LOG_DEBUG(@"tatget is %d",self.targetRearDirection);
            //LOG_DEBUG(@"frontView.origin.x = %f",self.frontView.frame.origin.x);
            
            CGFloat offsetX = positiveOrNegative * (self.rearViewRevealWidth - fabs([recognizer translationInView:self.view].x));
            self.frontView.frame = CGRectMake( offsetX, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
            
            CGFloat rate = (self.rearViewRevealWidth -fabs(self.frontView.frame.origin.x))/self.rearViewRevealWidth;
            self.blackView.alpha = self.coverOpactity * rate;
            [self dropItBackWithAnimation:NO rate:rate speed:0 rearViewController:self.targetRearDirection];
        }
        else if ([recognizer translationInView:self.view].x > 0 && [recognizer translationInView:self.view].x < REVEAL_RIGHT_EDGE)
        {
            CGFloat offsetX = positiveOrNegative * (REVEAL_RIGHT_EDGE - [recognizer translationInView:self.view].x);
            self.frontView.frame = CGRectMake( offsetX, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
            
            CGFloat rate = (REVEAL_RIGHT_EDGE -fabs(self.frontView.frame.origin.x))/REVEAL_RIGHT_EDGE;
            self.blackView.alpha = self.coverOpactity * rate;
            [self dropItBackWithAnimation:NO rate:rate speed:0 rearViewController:self.targetRearDirection];
        }
        else
        {
            //LOG_DEBUG(@"gesture open 3");
            self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
        }
	}
}

// Instantaneously toggle the rear view's visibility.
- (void)revealToggle:(Direction)direction
{
    id targetRevealViewController = direction == Left ? self.leftRearViewController : self.rightRearViewController;
    
	if (FrontViewPositionOrigin == self.currentFrontViewPosition)
	{
        
//		// Check if a delegate exists and if so, whether it is fine for us to revealing the rear view.
//		if ([self.delegate respondsToSelector:@selector(revealController:shouldRevealRearViewController:)])
//		{
//			if (![self.delegate revealController:self shouldRevealRearViewController:targetRevealViewController])
//			{
//				return;
//			}
//		}
		
		// Dispatch message to delegate, telling it the 'rearView' _WILL_ reveal, if appropriate:
		if ([self.delegate respondsToSelector:@selector(revealController:willRevealRearViewController:)])
		{
			[self.delegate revealController:self willRevealRearViewController:targetRevealViewController];
		}
		
		[self _revealAnimationTriggerDirection:direction speed:0];
		self.currentFrontViewPosition = direction == Left ? FrontViewPositionRight : FrontViewPositionLeft;
	}
	else
	{
//		// Check if a delegate exists and if so, whether it is fine for us to hiding the rear view.
//		if ([self.delegate respondsToSelector:@selector(revealController:shouldHideRearViewController:)])
//		{
//			if (![self.delegate revealController:self shouldHideRearViewController:targetRevealViewController])
//			{
//				return;
//			}
//		}
		// Dispatch message to delegate, telling it the 'rearView' _WILL_ hide, if appropriate:
		if ([self.delegate respondsToSelector:@selector(revealController:willHideRearViewController:)])
		{
			[self.delegate revealController:self willHideRearViewController:targetRevealViewController];
		}
		
		[self _concealAnimationTriggerDirection:direction speed:0];
		self.currentFrontViewPosition = FrontViewPositionOrigin;
	}
}


- (void)leftRevealToggle:(id)sender
{
    [self revealToggle:Left];
}

- (void)rightRevealToggle:(id)sender
{
    [self revealToggle:Right];
}

- (void)setFrontViewController:(UINavigationController *)frontViewController
{
	[self setFrontViewController:frontViewController animated:NO couldChangeOpen:NO];
}

- (void)setFrontViewController:(UINavigationController *)frontViewController animated:(BOOL)animated
{
    [self setFrontViewController:frontViewController animated:animated couldChangeOpen:YES];
}

- (void)setFrontViewController:(UINavigationController *)frontViewController animated:(BOOL)animated couldChangeOpen:(BOOL)couldChangeOpen
{
    if (nil != frontViewController)
    {
        if ( _frontViewController == frontViewController && couldChangeOpen)
        {
            [self revealToggle:self.targetRearDirection];
        }
        else if(_frontViewController != frontViewController)
        {
            [self _swapCurrentFrontViewControllerWith:frontViewController animated:animated couldChangeOpen:couldChangeOpen];
        }
    }
    
    if (!couldChangeOpen)
    {
        [self enabelFrontViewUserInteraction:YES];
    }
}

#pragma mark - Helper

- (void)_revealAnimationTriggerDirection:(Direction)direction speed:(CGFloat)speed
{
    //LOG_DEBUG(@"<<<<<<<<<<<<duration is %f>>>>>>>>>",ANIMATION_DURATION_TIME - speed*ANIMATION_SPEED_ELEMENT);
    if (direction == Left)
    {
        [self.leftRearViewController willMoveToParentViewController:self];
        if ([UIDevice iosMainVersion] < 7)
        {
            self.leftRearViewController.view.frame = self.leftRearViewController.view.bounds;
        }
    }
    else if (direction == Right)
    {
        [self.rightRearViewController willMoveToParentViewController:self];
        if ([UIDevice iosMainVersion] < 7)
        {
            self.rightRearViewController.view.frame = self.rightRearViewController.view.bounds;
        }
    }
    
	[UIView animateWithDuration:[self calculateDurationTime:speed] animations:^
	{
        self.frontView.frame = CGRectMake(direction == Left ? self.rearViewRevealWidth : -REVEAL_RIGHT_EDGE , 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
        self.blackView.alpha = .0f;
        [self bringItForwardWithAnimation:YES rate:1.f speed:speed rearViewController:direction];
        
	}
	completion:^(BOOL finished)
	{
//        //LOG_DEBUG(@"<><><><<><><<><><><><><><><><><>animation done");
		// Dispatch message to delegate, telling it the 'rearView' _DID_ reveal, if appropriate:
		if ([self.delegate respondsToSelector:@selector(revealController:didRevealRearViewController:)])
		{
			[self.delegate revealController:self didRevealRearViewController:direction == Left ? self.leftRearViewController : self.rightRearViewController];
		}
        if (direction == Left)
        {
            [self.leftRearViewController didMoveToParentViewController:self];
        }
        else if (direction == Right)
        {
            [self.rightRearViewController didMoveToParentViewController:self];
        }
	}];

}

- (void)_concealAnimationTriggerDirection:(Direction)direction speed:(CGFloat)speed
{
    //LOG_DEBUG(@"<<<<<<<<<<<<duration is %f>>>>>>>>>",[self calculateDurationTime:speed]);
	[UIView animateWithDuration:(ANIMATION_DURATION_TIME - speed*ANIMATION_SPEED_ELEMENT) animations:^
	{
		self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
        self.blackView.alpha = .5f;
        [self dropItBackWithAnimation:YES rate:1 speed:speed rearViewController:direction];
	}
	completion:^(BOOL finished)
	{
//        //LOG_DEBUG(@"<><><><<><><<><><><><><><><><><>animation done");
		// Dispatch message to delegate, telling it the 'rearView' _DID_ hide, if appropriate:
		if ([self.delegate respondsToSelector:@selector(revealController:didHideRearViewController:)])
		{
			[self.delegate revealController:self didHideRearViewController:direction == Left ? self.leftRearViewController : self.rightRearViewController];
            
            [self.leftRearViewController.view.layer removeAllAnimations];
            [self.rightRearViewController.view.layer removeAllAnimations];
		}
	}];
    
}

/*
 * Note: If someone wants to bother to implement a better (smoother) function. Go for it and share!
 */
- (CGFloat)_calculateOffsetForTranslationInView:(CGFloat)x
{
	CGFloat result;
	NSInteger flag = x > 0 ? 1: -1;
    
    if (self.targetRearDirection == Left)
    {
        if (fabs(x) <= self.rearViewRevealWidth)
        {
            // Translate linearly.
            result = fabs(x);
        }
        else if (fabs(x) <= self.rearViewRevealWidth+(M_PI*REVEAL_LEFT_EDGE_OVERDRAW/2.0f))
        {
            // and eventually slow translation slowly.
            result = REVEAL_LEFT_EDGE_OVERDRAW*sin((fabs(x)-self.rearViewRevealWidth)/REVEAL_LEFT_EDGE_OVERDRAW)+self.rearViewRevealWidth;
        }
        else
        {
            // ...until we hit the limit.
            result = self.rearViewRevealWidth+REVEAL_LEFT_EDGE_OVERDRAW;
        }
    }
    else
    {
        if (fabs(x) <= REVEAL_RIGHT_EDGE)
        {
            // Translate linearly.
            result = fabs(x);
        }
        else if (fabs(x) <= REVEAL_RIGHT_EDGE+(M_PI*REVEAL_RIGHT_EDGE_OVERDRAW/2.0f))
        {
            // and eventually slow translation slowly.
            result = REVEAL_RIGHT_EDGE_OVERDRAW*sin((fabs(x)-REVEAL_RIGHT_EDGE)/REVEAL_RIGHT_EDGE_OVERDRAW)+REVEAL_RIGHT_EDGE;
        }
        else
        {
            // ...until we hit the limit.
            result = REVEAL_RIGHT_EDGE+REVEAL_RIGHT_EDGE_OVERDRAW;
        }
        //右侧禁止划出offset
        if (result > REVEAL_RIGHT_EDGE)
        {
            result = REVEAL_RIGHT_EDGE;
        }
    }
    
	return result*flag;
}


- (void)_swapCurrentFrontViewControllerWith:(UINavigationController *)newFrontViewController animated:(BOOL)animated couldChangeOpen:(BOOL)couldChangeOpen
{
	if ([self.delegate respondsToSelector:@selector(revealController:willSwapToFrontViewController:)])
	{
		[self.delegate revealController:self willSwapToFrontViewController:newFrontViewController];
	}
	
	CGFloat xSwapOffsetExpanded;
	CGFloat xSwapOffsetNormal;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		xSwapOffsetExpanded = [[UIScreen mainScreen] bounds].size.width;
		xSwapOffsetNormal = 0.0f;
	}
	else
	{
		xSwapOffsetExpanded = self.frontView.frame.origin.x;
		xSwapOffsetNormal = self.frontView.frame.origin.x;
	}
	
	if (animated)
	{
		[UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
			self.frontView.frame = CGRectMake(xSwapOffsetExpanded, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
		completion:^(BOOL finished)
		{
			[self _removeFrontViewControllerFromHierarchy:self.frontViewController];
			 
			
			_frontViewController = newFrontViewController;
			 
			[self _addFrontViewControllerToHierarchy:newFrontViewController];
			 
			[UIView animateWithDuration:ANIMATION_DURATION_TIME delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
				self.frontView.frame = CGRectMake(xSwapOffsetNormal, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
			}
			completion:^(BOOL finished)
			{
				[self revealToggle:self.targetRearDirection];
				  
				if ([self.delegate respondsToSelector:@selector(revealController:didSwapToFrontViewController:)])
				{
					[self.delegate revealController:self didSwapToFrontViewController:newFrontViewController];
				}
			}];
		}];
	}
	else
	{
		[self _removeFrontViewControllerFromHierarchy:self.frontViewController];
		[self _addFrontViewControllerToHierarchy:newFrontViewController];
		
		_frontViewController = newFrontViewController;
		
		if ([self.delegate respondsToSelector:@selector(revealController:didSwapToFrontViewController:)])
		{
			[self.delegate revealController:self didSwapToFrontViewController:newFrontViewController];
		}
		if (couldChangeOpen)
        {
            [self revealToggle:self.targetRearDirection];
        }
	}
}

#pragma mark - UIViewController Containment

- (void)_addFrontViewControllerToHierarchy:(UINavigationController *)frontViewController
{
	[self addChildViewController:frontViewController];
    frontViewController.view.frame = CGRectMake(0.0f, 0.0f, self.frontView.width, self.frontView.height);
    
	[self.frontView addSubview:frontViewController.view];
    
    //添加滑动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(revealGesture:)];
    panGestureRecognizer.delegate = self;
    [frontViewController.view addGestureRecognizer:panGestureRecognizer];


    
    //添加单击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFrontView:)];
    tapGesture.delegate = self;

    UIView *view = frontViewController.view;
    [view addGestureRecognizer:tapGesture];
//    else
    {
        [frontViewController.view addGestureRecognizer:tapGesture];
    }
//    tapGesture.delaysTouchesBegan = YES;
    [tapGesture requireGestureRecognizerToFail:panGestureRecognizer];
    
    
	if ([frontViewController respondsToSelector:@selector(didMoveToParentViewController:)])
	{
		[frontViewController didMoveToParentViewController:self];
	}
}

- (void)_addRearViewControllerToHierarchy:(UIViewController *)rearViewController
{
	[self addChildViewController:rearViewController];
    
    if ([UIDevice iosMainVersion] < 7)
    {
        rearViewController.view.frame = CGRectMake(0.0f, 0.0f, self.rearView.width, self.rearView.height);
    }
    else
    {
        rearViewController.view.frame = CGRectMake(0.0f, 20.0f, self.rearView.width, self.rearView.height);
    }

	[self.rearView addSubview:rearViewController.view];
		
	if ([rearViewController respondsToSelector:@selector(didMoveToParentViewController:)])
	{
		[rearViewController didMoveToParentViewController:self];
	}
}

- (void)_removeFrontViewControllerFromHierarchy:(UIViewController *)frontViewController
{
	[frontViewController.view removeFromSuperview];
    [frontViewController removeFromParentViewController];
//    self.frontViewController = nil;
    
	if ([frontViewController respondsToSelector:@selector(removeFromParentViewController:)])
	{
		[frontViewController removeFromParentViewController];		
	}
}

- (void)_removeRearViewControllerFromHierarchy:(UIViewController *)rearViewController
{
	[rearViewController.view removeFromSuperview];
    [rearViewController removeFromParentViewController];
    
	if ([rearViewController respondsToSelector:@selector(removeFromParentViewController:)])
	{
		[rearViewController removeFromParentViewController];
	}
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.scaleRate = 1.0;
    self.coverOpactity = 0.0;
    
    if (self.scaleRate != 1.0)
    {
        _leftRearViewController.view.layer.transform = CATransform3DMakeScale(self.scaleRate, self.scaleRate, self.scaleRate);
        _rightRearViewController.view.layer.transform = CATransform3DMakeScale(self.scaleRate, self.scaleRate, self.scaleRate);
    }

    
	self.frontView = [[UIView alloc] initWithFrame:self.view.bounds];
	self.rearView = [[UIView alloc] initWithFrame:self.view.bounds];
	
	self.frontView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.frontView.autoresizesSubviews = YES;
	self.rearView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.rearView.autoresizesSubviews = YES;
    
	[self.view addSubview:self.rearView];
	[self.view addSubview:self.frontView];
	
	/* Create a fancy shadow aroung the frontView.
	 *
	 * Note: UIBezierPath needed because shadows are evil. If you don't use the path, you might not
	 * not notice a difference at first, but the keen eye will (even on an iPhone 4S) observe that 
	 * the interface rotation _WILL_ lag slightly and feel less fluid than with the path.
	 */
    
	UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.frontView.bounds];
	self.frontView.layer.masksToBounds = NO;
	self.frontView.layer.shadowColor = [UIColor blackColor].CGColor;
	self.frontView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	self.frontView.layer.shadowOpacity = 1.0f;
	self.frontView.layer.shadowRadius = 2.5f;
	self.frontView.layer.shadowPath = shadowPath.CGPath;
	
	// Init the position with only the front view visible.
    
	self.previousPanOffset = 0.0f;
	self.currentFrontViewPosition = FrontViewPositionOrigin;
    
//    [self _addRearViewControllerToHierarchy:self.leftRearViewController];
//    [self _addRearViewControllerToHierarchy:self.rightRearViewController];
    
	[self _addFrontViewControllerToHierarchy:self.frontViewController];
    
    if (self.coverOpactity > 0)
    {
        UIView *blackView = [[UIView alloc] initWithFrame:self.rearView.frame];
        blackView.backgroundColor = [UIColor blackColor];
        blackView.alpha = self.coverOpactity;
        UITapGestureRecognizer *blackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBlackView:)];
        blackTap.delegate = self;
        [blackView addGestureRecognizer:blackTap];
        self.blackView = blackView;
    }
    
    [self.frontView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
}

- (void)didReceiveMemoryWarningWhenNotInTop
{    
    [super didReceiveMemoryWarningWhenNotInTop];
    for (UIViewController *v in self.childViewControllers)
    {
        [v removeFromParentViewController];
    }

	self.frontView = nil;
    [self.blackView removeFromSuperview];
    self.blackView = nil;
    self.rearView = nil;
}



//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//	return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//}

#pragma mark - Memory Management

- (void)dealloc
{
    [self.frontView removeObserver:self forKeyPath:@"frame"];
}

#pragma mark - Reveal  Management
	
- (void)dropItBackWithAnimation:(BOOL)animation rate:(CGFloat)rate speed:(CGFloat)speed rearViewController:(Direction)direction;
{
    CGFloat scale = 1 - (1-self.scaleRate)*rate;
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.toValue = [NSNumber numberWithDouble:scale];
    scaleAnimation.duration = animation ? [self calculateDurationTime:speed]: 0.f;
    scaleAnimation.repeatCount = 0.f;
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.autoreverses = NO;
    scaleAnimation.fillMode = kCAFillModeBoth;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    if (direction == Left)
    {
        [self.leftRearViewController.view.layer addAnimation:scaleAnimation forKey:nil];
    }
    else if (direction == Right)
    {
        [self.rightRearViewController.view.layer addAnimation:scaleAnimation forKey:nil];
    }
    
}

- (void)bringItForwardWithAnimation:(BOOL)animation rate:(CGFloat)rate speed:(CGFloat)speed rearViewController:(Direction)direction;
{
    CGFloat scale = self.scaleRate + (1- self.scaleRate)*rate;
    
    // Scale
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.toValue = [NSNumber numberWithDouble:scale];
    scaleAnimation.duration = animation ? [self calculateDurationTime:speed]: 0.f;
    scaleAnimation.repeatCount = 0.f;
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.autoreverses = NO;
    scaleAnimation.fillMode = kCAFillModeBoth;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:(rate == 1 ?kCAMediaTimingFunctionEaseInEaseOut : kCAMediaTimingFunctionEaseOut)];
    
    if (direction == Left)
    {
        [self.leftRearViewController.view.layer addAnimation:scaleAnimation forKey:nil];
    }
    else if (direction == Right)
    {
        [self.rightRearViewController.view.layer addAnimation:scaleAnimation forKey:nil];
    }
}

- (CGFloat)calculateDurationTime:(CGFloat)speed
{
    CGFloat result = ANIMATION_DURATION_TIME - speed*ANIMATION_SPEED_ELEMENT;
    return result < ANIMATION_DURATION_MIN_TIME ? ANIMATION_DURATION_MIN_TIME : result;
}

#pragma mark- Gesture

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        
        if (fabs([panGestureRecognizer velocityInView:self.view].x) < fabs([panGestureRecognizer velocityInView:self.view].y))
        {
            return NO;
        }
        
        // 1. Ask the delegate (if appropriate) if we are allowed to do the particular interaction:
        if ([self.delegate conformsToProtocol:@protocol(ZUUIRevealControllerDelegate)])
        {
            //判断手势方向
            BOOL toLeft = [panGestureRecognizer velocityInView:self.view].x > 0;
            // Case a): We're going to be revealing.
            if (FrontViewPositionOrigin == self.currentFrontViewPosition)
            {
                if ([self.delegate respondsToSelector:@selector(revealController:shouldRevealRearViewController:)])
                {
                    if (![self.delegate revealController:self shouldRevealRearViewController:toLeft ? self.leftRearViewController : self.rightRearViewController])
                    {
                        return NO;
                    }
                }
            }
            // Case b): We're going to be concealing.
            else
            {
                if ([self.delegate respondsToSelector:@selector(revealController:shouldHideRearViewController:)])
                {
                    if (![self.delegate revealController:self shouldHideRearViewController:toLeft ? self.leftRearViewController : self.rightRearViewController])
                    {
                        return NO;
                    }
                }
            }
        }
    }
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        if (self.frontView.left == self.rearViewRevealWidth || self.frontView.left == -REVEAL_RIGHT_EDGE)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    return YES;
}

- (void)tapFrontView:(UIGestureRecognizer *)gestureRecognizer
{
    [self revealToggle:self.targetRearDirection];
}

- (void)tapBlackView:(UIGestureRecognizer *)gestureRecognizer
{
    [self.blackView removeFromSuperview];
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    if (self.frontView.origin.x != 0)
//    {
//        return NO;
//    }
//
//    return YES;
//}

#pragma mark- Oberserver
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"])
    {
        CGRect newRect = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        CGFloat newX = newRect.origin.x;
        if (newX > 0)
        {
            self.targetRearDirection = Left;
            
            [self.blackView removeFromSuperview];
            [self.leftRearViewController.view addSubview:self.blackView];
            
            if (![self.childViewControllers containsObject:self.leftRearViewController])
            {                
                [self _addRearViewControllerToHierarchy:self.leftRearViewController];
                [self _removeRearViewControllerFromHierarchy:self.rightRearViewController];
            }
        }
        else if (newX < 0 && self.rightRearViewController)
        {
            self.targetRearDirection = Right;
            
            [self.blackView removeFromSuperview];
            [self.rightRearViewController.view addSubview:self.blackView];
            
            if (![self.childViewControllers containsObject:self.rightRearViewController])
            {
                [self _removeRearViewControllerFromHierarchy:self.leftRearViewController];
                [self _addRearViewControllerToHierarchy:self.rightRearViewController];
            }
            
        }

        [self enabelFrontViewUserInteraction:newX == 0 || newX == self.rearViewRevealWidth || newX == -REVEAL_RIGHT_EDGE];
        
    }
}

- (void)enabelFrontViewUserInteraction:(BOOL)enable
{
    self.frontViewController.view.userInteractionEnabled = enable;
}
@end