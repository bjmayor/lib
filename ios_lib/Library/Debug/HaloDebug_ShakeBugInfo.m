//
//  ShakeBugInfo.m
//  ShackBug
//
//  Created by sub on 13-6-4.
//  Copyright (c) 2013年 Sub. All rights reserved.
//

#import "HaloDebug_ShakeBugInfo.h"
#import "HaloDebug_ShakeBugManager.h"

@implementation HaloDebug_ShakeBugInfo

- (HaloDebug_ShakeBugInfo *)init
{
    self = [super init];
    if (self)
    {
        self.severity = 50;
    }
    return  self;
}

@end
