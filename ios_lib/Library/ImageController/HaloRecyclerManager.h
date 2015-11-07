//
//  HaloRecyclerManager.h
//  YContact
//
//  Created by peiqiang li on 12-3-8.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HaloRecyclableView.h"
@interface HaloRecyclerManager : NSObject
- (id)dequeueReusableViewWithIdentifier:(NSString *)identifier;
- (void)recycleView:(UIView<HaloRecyclableView>*)view;
- (void)removeAllViews;
@end
