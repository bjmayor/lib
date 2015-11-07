//
//  ImageInfo.h
//  YContact
//
//  Created by peiqiang li on 12-3-16.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <Foundation/Foundation.h>
@interface ImageInfo : NSObject

@property(nonatomic, copy)NSURL  *imageUrl;
@property(nonatomic, strong)UIImage *image;
@property(nonatomic, copy)NSURL     *thumbnailUrl;
@property(nonatomic, strong)id       userInfo;
@property(nonatomic, copy)NSString  *prompt;
@end;