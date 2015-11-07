//
//  UIImage+WebCache.h
//  SDWebImage
//
//  Created by  on 12-11-12.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageManager.h"

@interface UIImage (scale)

- (UIImage *)subImage:(CGRect)rect;
- (UIImage *)centerImage:(CGSize)size mask:(UIImage*)mask mergeImage:(UIImage *)mergeImage parentImage:(UIImage **)parentImage;
- (UIImage *)scaleToFixSize:(CGSize)aSize mask:(UIImage*)mask  mergeImage:(UIImage *)mergeImage;

@end


@interface UIImage (WebCache)

+ (NSString *)keyForImage:(NSURL *)url optionsKey:(SDWebImageOptions)options size:(CGSize)size;

+ (UIImage *)loadImageFromCacheWithUrl:(NSURL *)url optionsKey:(SDWebImageOptions)options size:(CGSize)size;

+ (UIImage *)loadImageFromCacheWithUrl:(NSURL *)url optionsKey:(SDWebImageOptions)options size:(CGSize)size fromDisk:(BOOL)fromDisk;

+ (UIImage *)loadImageFromCacheWithUrl:(NSURL *)url optionsKey:(SDWebImageOptions)options size:(CGSize)size  mask:(BOOL)mask primary:(BOOL)primary;

+ (UIImage *)loadImageFromCacheWithUrl:(NSURL *)url optionsKey:(SDWebImageOptions)options size:(CGSize)size  mask:(BOOL)mask primary:(BOOL)primary  fromDisk:(BOOL)fromDisk;

+ (void)removeFromCacheWithUrl:(NSURL *)url optionsKey:(SDWebImageOptions)options size:(CGSize)size mask:(BOOL)mask primary:(BOOL)primary;

- (UIImage *)imageSizeToFitsWithSize:(CGSize)size optionsKey:(SDWebImageOptions)options url:(NSURL *)url;

- (UIImage *)imageSizeToFitsWithSize:(CGSize)size optionsKey:(SDWebImageOptions)options url:(NSURL *)url primary:(BOOL)primary;


- (UIImage *)imageSizeToFitsWithSize:(CGSize)size optionsKey:(SDWebImageOptions)options url:(NSURL *)url key:(NSString**)key;

- (UIImage *)imageSizeToFitsWithSize:(CGSize)size optionsKey:(SDWebImageOptions)optionsKey url:(NSURL *)url mask:(UIImage*)mask key:(NSString**)key;

- (UIImage *)imageSizeToFitsWithSize:(CGSize)size optionsKey:(SDWebImageOptions)optionsKey url:(NSURL *)url mask:(UIImage*)mask mergeImage:(UIImage *)mergeImage key:(NSString**)key;

- (UIImage *)imageSizeToFitsWithSize:(CGSize)size optionsKey:(SDWebImageOptions)optionsKey url:(NSURL *)url primary:(BOOL)primary mask:(UIImage*)mask mergeImage:(UIImage *)mergeImage key:(NSString**)key;

@end
