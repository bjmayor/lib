//
//  UIImage+WebCache.m
//  SDWebImage
//
//  Created by  on 12-11-12.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "UIImage+WebCache.h"
#import "SDImageCache.h"

@implementation UIImage (scale)

- (UIImage *)subImage:(CGRect)rect
{
    if ( CGSizeEqualToSize( rect.size ,self.size ) )
    {
        return self;
    }
    CGFloat scale = self.scale;
    rect.size.height = scale* rect.size.height;
    rect.size.width = scale* rect.size.width;
    rect.origin.x = scale * rect.origin.x;
    rect.origin.y = scale * rect.origin.y;
    CGImageRef drawImage = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *clipImage = [UIImage imageWithCGImage:drawImage];
    CGImageRelease(drawImage);
    return clipImage;
}

/**
 中间切片
 
 1. 细宽的图片
 
 细长的图是指 宽高比例过大的，并且宽度 >>> size.width 的
 
 2. 细高的图片
 
 细长的图是指 宽高比例过小的，并且宽度 >>> size.width 的
 
 3. 偏小的
 
 int bitsPerComponent = 8;
 int bitsPerPixel = 32;
 int bytesPerRow = 4 * 1024;
 */

- (UIImage *)createWithBackgroudColor:( UIColor *)bgColor size:(CGSize)size subRect:(CGRect)subRect primary:(BOOL)primary parentImage:(UIImage **)parentImage;
{
    *parentImage = self;
    if ( primary )
    {
        return self;
    }
    UIImage *subImage = [self subImage:subRect];
    
    CGSize subSize = subImage.size;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size,NO,self.scale);
    
    CGContextRef context= UIGraphicsGetCurrentContext();
    //    CGContextTranslateCTM(context, 0, size.height);
    //    CGContextScaleCTM(context, 1.0, -1.0);
	CGContextSetFillColorWithColor( context, bgColor.CGColor );
	CGContextFillRect( context, rect );
	
    rect = CGRectMake((size.width - subSize.width)/2, (size.height - subSize.height)/2, subSize.width, subSize.height);
    [subImage drawInRect:rect];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return image;
    
}

- (UIImage *)centerImage:(CGSize)size mask:(UIImage*)mask  mergeImage:(UIImage *)mergeImage primary:(BOOL)primary parentImage:(UIImage **)parentImage;
{
    //判断是偏小的图片
    UIImage *image = nil;
    CGSize osize = size;
    size.width *= [UIScreen mainScreen].scale;
    size.height *= [UIScreen mainScreen].scale;
    if ( CGSizeEqualToSize(size, self.size))
    {
        image = self;
        //return self;
    }
    else if ( self.size.width < size.width && self.size.height < size.height )
    {
        image = [self createWithBackgroudColor:[UIColor blackColor] size:size subRect:CGRectMake(0, 0 , self.size.width, self.size.height ) primary:primary parentImage:parentImage];
        //return image;
    }
    //判断是否是细宽的图片。细高的图片窃取中间部分，不足部分补黑
    else if ( self.size.width > size.width && self.size.height < size.height )
    {
        image = [self createWithBackgroudColor:[UIColor blackColor] size:size subRect:CGRectMake((self.size.width-size.width)/2, 0 , size.width, self.size.height) primary:primary parentImage:parentImage];
        //return image;
    }
    //判断是否是细高的图片。细高的图片窃取中间部分，不足部分补黑
    else if ( self.size.height > size.height && self.size.width < size.width )
    {
        image = [self createWithBackgroudColor:[UIColor blackColor] size:size subRect:CGRectMake(0, (self.size.height-size.height)/2, self.size.width, size.height) primary:primary parentImage:parentImage];
        //return image;
    }
    else {
        size = osize;
        UIImage *simage = [self scaleToFixUnilateralSize:size mask:mask mergeImage:mergeImage];
        if ( parentImage != nil )
        {
            *parentImage = simage;
        }
        if ( primary )
        {
            image = simage;
            //return simage;
        }
        else
        {
            CGSize picSize = simage.size;
            if ( picSize.width < size.width && picSize.height < size.height )
            {
                image = simage;
                //return simage;
            }
            else
            {
                CGFloat clipx = (picSize.width - size.width)/2;
                CGFloat clipy = (picSize.height - size.height)/2;
                if ( clipx < 0.0f )
                {
                    clipx = 0.0f;
                    size.width = simage.size.width;
                }
                if ( clipy < 0.0f )
                {
                    clipy = 0.0f;
                    size.height = simage.size.height;
                }
                
                image = [simage subImage:CGRectMake(clipx, clipy, size.width, size.height)];
                //return image;
            }
        }
    }
    if ( parentImage != nil && *parentImage == nil )
    {
        *parentImage = image;
        
    }   
    image = [image imageUseMask:mask mergeImage:mergeImage];
    return image;
}

- (UIImage *)centerImage:(CGSize)size mask:(UIImage*)mask mergeImage:(UIImage*)mergeImage parentImage:(UIImage **)parentImage
{
    return [self centerImage:size mask:mask mergeImage:mergeImage primary:NO parentImage:parentImage];
}

- (UIImage*)imageMerged:(UIImage*)image
{
    CGSize size = self.size;
	UIGraphicsBeginImageContextWithOptions(size,NO,[UIScreen mainScreen].scale);
	CGRect rect = CGRectMake(0, 0, size.width, size.height);
	[self drawInRect:rect];
	[image drawInRect:rect];
	UIImage  *newimage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newimage;
}

- (UIImage*)imageUseMask:(UIImage*)mask mergeImage:(UIImage *)mergeImage
{
    if ( mask == nil && mergeImage == nil )
    {
        return self;
    }
    if ( mask == nil && mergeImage != nil )
    {
        return [self imageMerged:mergeImage];
    }
    CGFloat scale = [UIScreen mainScreen].scale;
	CGFloat width = self.size.width  *scale;
	CGFloat height = self.size.height  *scale;
	CGContextRef mainViewContentContext;
	CGColorSpaceRef colorSpace;
	colorSpace = CGColorSpaceCreateDeviceRGB();
	// create a bitmap graphics context the size of the image
	mainViewContentContext = CGBitmapContextCreate (NULL, width, height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little);
	// free the rgb colorspace
	CGColorSpaceRelease(colorSpace);
	if (mainViewContentContext==NULL)
		return NULL;
	
	CGImageRef maskImage = mask.CGImage;
	CGContextClipToMask(mainViewContentContext, CGRectMake(0, 0, width, height), maskImage);
	CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, width,  height), self.CGImage);
	// Create CGImageRef of the main view bitmap content, and then
	// release that bitmap context
    if ( mergeImage != nil )
    {
        CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, width,  height), mergeImage.CGImage);
    }
	CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	// convert the finished resized image to a UIImage
	UIImage *theImage = nil;
	if ([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)])
	{
		theImage = [UIImage imageWithCGImage:mainViewContentBitmapContext scale:scale orientation:UIImageOrientationUp];
	}
	else
	{
		theImage = [UIImage imageWithCGImage:mainViewContentBitmapContext];
	}
    
	CGImageRelease(mainViewContentBitmapContext);
    
	return theImage;
}

- (UIImage*)scaleToSize:(CGSize)size mask:(UIImage *)mask mergeImage:(UIImage *)mergeImage
{
    size.width = floorf(size.width);
    size.height = floorf(size.height);
    UIGraphicsBeginImageContextWithOptions(size,NO,[UIScreen mainScreen].scale);
    
	[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage  *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    image = [image imageUseMask:mask mergeImage:mergeImage];
	return image;
}

- (UIImage*)scaleToFixSize:(CGSize)aSize mask:(UIImage *)mask mergeImage:(UIImage *)mergeImage
{
	CGSize picSize = self.size;
    while ( picSize.width > aSize.width || picSize.height > aSize.height )
    {
        float scale = ((float)aSize.width/picSize.width);
        if ( scale >= 1.0f )
        {
            scale = ((float)aSize.height/picSize.height);
            if ( scale >= 1.0f )
            {
                break;
            }
        }
        picSize.width *= scale;
        picSize.height *= scale;
    }
    picSize.width = floorf(picSize.width);
    picSize.height = floorf(picSize.height);
	return [self scaleToSize:picSize mask:mask mergeImage:mergeImage];
}

- (UIImage *)scaleToFixUnilateralSize:(CGSize)aSize mask:(UIImage *)mask  mergeImage:(UIImage *)mergeImage
{
    CGSize picSize = self.size;
    while ( picSize.width > aSize.width && picSize.height > aSize.height )
    {
        float scale = 1.0f;
        if ( picSize.height > picSize.width )
        {
            scale = ((float)aSize.width/picSize.width);
        }
        else
        {
            scale = (float)aSize.height/picSize.height;
        }
        
        if ( scale >= 1.0f )
        {
            break;
        }
        picSize.width *= scale;
        picSize.height *= scale;
    }
    picSize.width = floorf(picSize.width);
    picSize.height = floorf(picSize.height);
	return [self scaleToSize:picSize mask:mask mergeImage:mergeImage];
}

@end

@implementation UIImage (WebCache)

+ (NSString*)keyForImage:(NSURL *)url optionsKey:(SDWebImageOptions)options size:(CGSize)size
{
    int m = 0;
    NSString *key = nil;
    if ( (options & SDWebImageScaleSizeToFits) != 0 ) // scale image
    {
        m = SDWebImageScaleSizeToFits;
    }
    else if ( (options & SDWebImageClipCenterToFits) != 0 ) // clip image
    {
        m = SDWebImageClipCenterToFits;
    }
    if ( m == 0 )
    {
        key = [url absoluteString];
    }
    else
    {
        key = [NSString stringWithFormat:@"%@_%d_%d_%d",[url absoluteString],m,(int)size.width,(int)size.height];
    }
    return key;
}

+ (UIImage *)loadImageFromCacheWithUrl:(NSURL *)url optionsKey:(SDWebImageOptions)options size:(CGSize)size
{
    return [self loadImageFromCacheWithUrl:url optionsKey:options size:size fromDisk:YES];
}

+ (UIImage *)loadImageFromCacheWithUrl:(NSURL *)url optionsKey:(SDWebImageOptions)options size:(CGSize)size fromDisk:(BOOL)fromDisk
{
    NSString *key = [self keyForImage:url optionsKey:options size:size];
    UIImage *image = nil;
    if ( key != nil && key.length > 0 )
    {
        image = [[SDImageCache sharedImageCache] imageFromKey:key fromDisk:fromDisk];
    }
    return image;
}

+ (UIImage *)loadImageFromCacheWithUrl:(NSURL *)url optionsKey:(SDWebImageOptions)options size:(CGSize)size  mask:(BOOL)mask primary:(BOOL)primary
{
    return [self loadImageFromCacheWithUrl:url optionsKey:options size:size mask:mask primary:primary fromDisk:YES];
}

+ (UIImage *)loadImageFromCacheWithUrl:(NSURL *)url optionsKey:(SDWebImageOptions)options size:(CGSize)size  mask:(BOOL)mask primary:(BOOL)primary  fromDisk:(BOOL)fromDisk
{
    NSString *key = [self keyForImage:url optionsKey:options size:size];
    if ( primary )
    {
        key = [UIImage parentImageCacheKey:key suffix:(mask?@"png":@"jpg")];
    }
    UIImage *image = [[SDImageCache sharedImageCache] imageFromKey:key fromDisk:fromDisk];
    return image;
}

+ (void)removeFromCacheWithUrl:(NSURL *)url optionsKey:(SDWebImageOptions)options size:(CGSize)size mask:(BOOL)mask primary:(BOOL)primary
{
    NSString *key = [self keyForImage:url optionsKey:options size:size];
    if ( primary )
    {
        key = [UIImage parentImageCacheKey:key suffix:(mask?@"png":@"jpg")];
    }
    [[SDImageCache sharedImageCache] removeImageForKey:key fromDisk:NO];
}

- (UIImage *)imageSizeToFitsWithSize:(CGSize)size optionsKey:(SDWebImageOptions)optionsKey url:(NSURL *)url key:(NSString**)key
{
    return [self imageSizeToFitsWithSize:size optionsKey:optionsKey url:url primary:NO mask:nil mergeImage:nil key:key];
}

- (UIImage *)imageSizeToFitsWithSize:(CGSize)size optionsKey:(SDWebImageOptions)optionsKey url:(NSURL *)url mask:(UIImage*)mask key:(NSString**)key
{
    return [self imageSizeToFitsWithSize:size optionsKey:optionsKey url:url primary:NO mask:mask mergeImage:nil key:key];
}

- (UIImage *)imageSizeToFitsWithSize:(CGSize)size optionsKey:(SDWebImageOptions)optionsKey url:(NSURL *)url mask:(UIImage*)mask mergeImage:(UIImage *)mergeImage key:(NSString**)key
{
    return [self imageSizeToFitsWithSize:size optionsKey:optionsKey url:url primary:NO mask:mask mergeImage:mergeImage key:key];
}

- (UIImage *)imageSizeToFitsWithSize:(CGSize)size optionsKey:(SDWebImageOptions)optionsKey  url:(NSURL *)url
{
    return [self imageSizeToFitsWithSize:size optionsKey:optionsKey url:url key:nil];
}

- (UIImage *)imageSizeToFitsWithSize:(CGSize)size optionsKey:(SDWebImageOptions)options url:(NSURL *)url primary:(BOOL)primary
{
    return [self imageSizeToFitsWithSize:size optionsKey:options url:url   primary:primary  mask:nil mergeImage:nil key:nil];
}

+ (NSString *)parentImageCacheKey:( NSString *)key suffix:(NSString *)suffix
{
    return [NSString stringWithFormat:@"%@_parent@2x.%@",key,suffix];
}

- (UIImage *)imageSizeToFitsWithSize:(CGSize)size optionsKey:(SDWebImageOptions)optionsKey url:(NSURL *)url primary:(BOOL)primary mask:(UIImage*)mask mergeImage:(UIImage*)mergeImage key:(NSString**)key
{
    NSString *ckey = [UIImage keyForImage:url optionsKey:optionsKey size:size];
    if ( primary )
    {
        NSString *pkey = [UIImage parentImageCacheKey:ckey suffix:(mask==nil?@"jpg":@"png")];
        UIImage *image = [[SDImageCache sharedImageCache] imageFromKey:pkey];
        if ( image )
        {
            return image;
        }
    }
    UIImage *img = nil;
    UIImage *parentImage = nil;
    if ( (optionsKey & SDWebImageScaleSizeToFits) != 0 ) // scale image
    {
        img = [self scaleToFixSize:size mask:mask mergeImage:mergeImage];
    }
    else if (  (optionsKey & SDWebImageClipCenterToFits) != 0 ) // clip image
    {
        img = [self centerImage:size mask:mask mergeImage:mergeImage primary:primary parentImage:&parentImage];
    }
    else
    {
        img = self;
    }
    
    if ( img != self )
    {
        if ( !primary )
        {
            NSData *data = (mask==nil)?UIImageJPEGRepresentation(img,1.0f):UIImagePNGRepresentation(img) ;
            [[SDImageCache sharedImageCache] storeImage:img imageData:data forKey:ckey toDisk:YES cache:NO];
        }
        if ( parentImage != nil )
        {
            NSData *data = (mask==nil)?UIImageJPEGRepresentation(parentImage,1.0f):UIImagePNGRepresentation(parentImage) ;
            NSString *pkey = [UIImage parentImageCacheKey:ckey suffix:(mask==nil?@"jpg":@"png")];
            [[SDImageCache sharedImageCache] storeImage:parentImage imageData:data forKey:pkey toDisk:YES cache:NO];
        }    
    }
    if ( key != nil )
    {
        *key = ckey;
    }
    return img;
}

@end
