//
//  NSMutableDictionary+SubscriptingSupport.m
//  YConference
//
//  Created by Zchin Hsu on 12-9-11.
//  Copyright (c) 2012年  Ltd., Co. All rights reserved.
//

#import "NSMutableDictionaryExt.h"

@implementation NSMutableDictionary (SubscriptingSupport)

- (id)objectForKeyedSubscript:(id)key
{
    if (!key)
    {
        return nil;
    }
    
    return [self objectForKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(id)key
{
    if (!key)
    {
        return;
    }
    
    if (!object)
    {
        [self removeObjectForKey:key];
    }
    else
    {
        [self setObject:object forKey:key];
    }
}
@end
