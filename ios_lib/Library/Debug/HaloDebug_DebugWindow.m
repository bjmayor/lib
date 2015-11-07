//
//  HaloDebug_DebugWindow.m
//  WCard
//
//  Created by Zchin Hsu on 13-4-24.
//  Copyright (c) 2013年 . All rights reserved.
//



#import "HaloDebug_DebugWindow.h"
#import "HaloDebug_DebugViewController.h"

#define KAnimationDuration 0.6


@implementation HaloDebug_DebugWindow

SYNTHESIZE_ARC_SINGLETON_FOR_CLASS(HaloDebug_DebugWindow)

- (id)init
{
    CGRect screenBound = [UIScreen mainScreen].bounds;
	self = [super initWithFrame:screenBound];
	if (self)
	{
		self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
		self.hidden = YES;
		self.windowLevel = UIWindowLevelStatusBar + 200;
        
		if ([self respondsToSelector:@selector(setRootViewController:)])
		{
			self.rootViewController = [HaloDebug_DebugViewController sharedInstance];
		}
		else
		{
			[self addSubview:[HaloDebug_DebugViewController sharedInstance].view];
		}
	}
    
	return self;
}

- (void)setHidden:(BOOL)hidden
{
    if (self.hidden == hidden)
    {
        return;
    }
    
	if (hidden)
	{
        self.left = 0;
        [UIView animateWithDuration:KAnimationDuration animations:^{

            self.left = self.width;
            
        } completion:^(BOOL finished) {

            [super setHidden:hidden];
            
            [[HaloDebug_DebugViewController sharedInstance] viewWillDisappear:NO];
            [[HaloDebug_DebugViewController sharedInstance] viewDidDisappear:NO];
        }];
	}
	else
	{
        [super setHidden:hidden];
        
        [[HaloDebug_DebugViewController sharedInstance] viewWillAppear:NO];
        [[HaloDebug_DebugViewController sharedInstance] viewDidAppear:NO];
        
        self.left = self.width;
        [UIView animateWithDuration:KAnimationDuration animations:^{
            
            self.left = 0;
        }];
	}
}

@end
