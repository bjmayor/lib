//
//  HaloRecyclerManager.m
//  YContact
//
//  Created by peiqiang li on 12-3-8.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "HaloRecyclerManager.h"
@interface HaloRecyclerManager()
{
    NSMutableDictionary*    _reusableViewDiction;
}
@property(nonatomic,retain)NSMutableDictionary*    reusableViewDiction;
@end
@implementation HaloRecyclerManager
@synthesize reusableViewDiction = _reusableViewDiction;
- (id)init
{
    self = [super init];
    if (self)
    {
        self.reusableViewDiction = [NSMutableDictionary dictionaryWithCapacity:10];
        
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc addObserver: self
               selector: @selector(reduceMemoryUsage)
                   name: UIApplicationDidReceiveMemoryWarningNotification
                 object: nil];
        
    }
    return self;
}
- (void)recycleView:(UIView<HaloRecyclableView> *)view
{
    NSString* reuseIdentifier = nil;
    if ([view respondsToSelector:@selector(reuseIdentifier)]) {
        reuseIdentifier = [view reuseIdentifier];;
    }
    if (nil == reuseIdentifier) {
        return;
    }
    
    NSMutableArray* views = [_reusableViewDiction objectForKey:reuseIdentifier];
    if (nil == views) {
        views = [[NSMutableArray alloc] init];
        [_reusableViewDiction setObject:views forKey:reuseIdentifier];
    }
    [views addObject:view];
}

- (id)dequeueReusableViewWithIdentifier:(NSString *)reuseIdentifier
{
    if (!reuseIdentifier)
    {
        return nil;
    }
    NSMutableArray* views = [_reusableViewDiction objectForKey:reuseIdentifier];
    UIView<HaloRecyclableView>* view = [views lastObject];
    if (nil != view) {
        [views removeLastObject];
    }
    return view;
}
- (void)removeAllViews {
    [_reusableViewDiction removeAllObjects];
}

- (void)reduceMemoryUsage
{
    [self removeAllViews];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
