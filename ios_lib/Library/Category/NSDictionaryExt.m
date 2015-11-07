//
//  NSDictionary+SubscriptingSupport.m
//  YConference
//
//  Created by Zchin Hsu on 12-9-11.
//  Copyright (c) 2012年  Ltd., Co. All rights reserved.
//

#import "NSDictionaryExt.h"

@implementation NSDictionary (SubscriptingSupport)

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

@end
