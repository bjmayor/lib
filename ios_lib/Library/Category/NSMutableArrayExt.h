//
//  NSMutableArrayExt.h
//  YContact
//
//  Created by  on 11-10-11.
//  Copyright 2011年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (NSMutableArrayExt)
- (void)insertObjects:(NSArray*)array;
- (void)insertObjectSafely:(id)anObject atIndex:(NSUInteger)index;
@end

@interface NSMutableArray (SubscriptingSupport)
- (id)objectAtIndexedSubscript:(NSUInteger)index;

@end
