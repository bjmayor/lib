//
//  HaloUIManager.h
//  Hello World
//
//  Created by  on 13-5-19.
//  Copyright (c) 2013年 __Company__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HaloUIViewController;

@interface HaloUIManager : NSObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HaloUIManager)
@property (nonatomic, strong, readonly) UIWindow *window;
@property (nonatomic, strong, readonly) UIViewController *topViewController;
@property (nonatomic, assign) BOOL keyboardIsShown;
@property (nonatomic, assign) CGRect keyboardRect;
- (void)startFromViewController:(UIViewController *)viewController;
@end
