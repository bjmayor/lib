//
//  HaloRecyclableView.h
//  YContact
//
//  Created by peiqiang li on 12-3-8.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HaloRecyclableView <NSObject>
@property (nonatomic, readwrite, copy) NSString* reuseIdentifier;
- (void)prepareForReuse;
@end
