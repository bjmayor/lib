//
//  NSMutableArrayExt.m
//  YContact
//
//  Created by  on 11-10-11.
//  Copyright 2011年 . All rights reserved.
//

#import "NSMutableArrayExt.h"

@implementation NSMutableArray (NSMutableArrayExt)

- (void)insertObjects:(NSArray*)array
{
    NSRange range = NSMakeRange(0, [array count]);     
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [self insertObjects:array atIndexes:indexSet];
}

- (void)insertObjectSafely:(id)anObject atIndex:(NSUInteger)index;
{
    if (index < self.count)
    {
        [self insertObject:anObject atIndex:index];
    }
    else
    {
        [self addObject:anObject];
    }
}
@end

@implementation NSMutableArray (SubscriptingSupport)

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
    if (index >= self.count)
    {
        return nil;
    }
    
    return [self objectAtIndex:index];
}

//- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index
//{
//    if (index < self.count)
//    {
//        if (object)
//        {
//            [self replaceObjectAtIndex:index withObject:object];
//        }
//        else
//        {
//            [self removeObjectAtIndex:index];
//        }
//    }
//    else
//    {
//        if (!object)
//        {
//#ifdef __DEBUG__
//            LOG_DEBUG(@"Warning: [NSMutableArray setObject:atIndex:]: attempt to insert nil value (at index: %d)", index);
//#endif
//
//            return;
//        }
//
//        [self addObject:object];
//    }
//}

@end
