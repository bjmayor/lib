//
//  HaloDebug_UserTouchMap.m
//  Dota
//
//  Created by Zchin Hsu on 13-2-20.
//  Copyright (c) 2013年 Zchin Hsu. All rights reserved.
//

#import <objc/runtime.h>
#import <QuartzCore/CALayer.h>
#import "HaloDebug_UserTouchMap.h"


#pragma mark -

@interface HaloDebugTapIndicator : UIImageView
@end

#pragma mark -

@implementation HaloDebugTapIndicator

static inline float radians(double degrees) { return degrees * M_PI / 180.0f; }

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self )
	{
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeCenter;
//		self.image = [UIImage imageNamed:@"tap.png"];
        self.image = [UIImage imageNamed:@"Halo.bundle/images/touch"];
	}
	return self;
}

- (void)startAnimation
{
	self.alpha = 1.0f;
	self.transform = CGAffineTransformMakeScale( 0.8f, 0.8f );
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:1.0f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(didAppearingAnimationStopped)];
	
	self.alpha = 0.0f;
	self.transform = CGAffineTransformIdentity;
	
	[UIView commitAnimations];
}

- (void)didAppearingAnimationStopped
{
	[self removeFromSuperview];
}

@end


#pragma mark -

@interface HaloDebugTapBorder : UIImageView
@end

#pragma mark -

@implementation HaloDebugTapBorder

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if ( self )
	{
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = NO;
		self.layer.borderWidth = 1.0f;
		self.layer.borderColor = [UIColor redColor].CGColor;
	}
	return self;
}

- (void)startAnimation
{
	self.alpha = 1.0f;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:1.0f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(didAppearingAnimationStopped)];
	
	self.alpha = 0.0f;
	
	[UIView commitAnimations];
}

- (void)didAppearingAnimationStopped
{
	[self removeFromSuperview];
}

@end



#pragma mark -

@implementation UIWindow(HaloDebug_UserTouchMap)

static void (* _origSendEvent)( id, SEL, UIEvent * );

+ (void)swizzle
{
	static BOOL __swizzled = NO;
	if ( NO == __swizzled )
	{
		Method method;
		IMP implement;
		
		method = class_getInstanceMethod( [UIWindow class], @selector(sendEvent:) );
		_origSendEvent = (void *)method_getImplementation( method );
        
		implement = class_getMethodImplementation( [UIWindow class], @selector(mySendEvent:) );
		method_setImplementation( method, implement );
        
		__swizzled = YES;
	}
}

- (void)mySendEvent:(UIEvent *)event
{
	static NSTimeInterval __timeStamp = 0.0;
    
	if ( _origSendEvent )
	{
		_origSendEvent( self, _cmd, event );
	}
    
	UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
	if ( self != keyWindow )
    {
		return;
    }
    
	if ( UIEventTypeTouches == event.type )
	{
		NSSet * allTouches = [event allTouches];
		if ( 1 == [allTouches count] )
		{
			UITouch * touch = [[allTouches allObjects] objectAtIndex:0];
			if ( 1 == [touch tapCount] )
			{
				CGPoint location = [touch locationInView:keyWindow];
                
//				NSLog( @"touch.phase = %d", touch.phase );
				
				if ( UITouchPhaseBegan == touch.phase )
				{
					__timeStamp = touch.timestamp;
					
					HaloDebugTapBorder * border = [[HaloDebugTapBorder alloc] initWithFrame:touch.view.bounds];
					[touch.view addSubview:border];
					[border startAnimation];
				}
				else if ( UITouchPhaseMoved == touch.phase )
				{
//					[model recordDragAtLocation:location];
				}
				else if ( UITouchPhaseEnded == touch.phase || UITouchPhaseCancelled == touch.phase )
				{
					HaloDebugTapIndicator * indicator = [[HaloDebugTapIndicator alloc] initWithFrame:CGRectMake(0, 0, 50.0f, 50.0f)] ;
					indicator.center = location;
					[keyWindow addSubview:indicator];
					[indicator startAnimation];
					NSTimeInterval diff = touch.timestamp - __timeStamp;
					if ( diff <= 0.3f )
					{
//						[model recordTapAtLocation:location];
					}
				}
			}
		}
	}	
}

@end


@implementation HaloDebug_UserTouchMap

@end
