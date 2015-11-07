//
//  HaloDebug_UserTouchMap.h
//  Dota
//
//  Created by Zchin Hsu on 13-2-20.
//  Copyright (c) 2013年 Zchin Hsu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIWindow(HaloDebug_UserTouchMap)

+ (void)swizzle;
- (void)mySendEvent:(UIEvent *)event;

@end


#pragma mark -

@interface HaloDebug_UserTouchMap : NSObject

@end