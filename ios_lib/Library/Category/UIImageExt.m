//
//  MNUIImage.m
//  juwu
//
//  Created by  on 11-7-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImageExt.h"

CGFloat DegreesToRadians(CGFloat degrees) ;
CGFloat RadiansToDegrees(CGFloat radians) ;

void addRoundedRectToPath(CGContextRef context, CGRect rect, float oval);

CGFloat DegreesToRadians(CGFloat degrees) {return degrees  *M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians  *180/M_PI;};

void addRoundedRectToPath(CGContextRef context, CGRect rect, float oval)
{
    if (oval == 0 ) 
    {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    float radius = oval;
    CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3  *M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, M_PI / 2, M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, M_PI, 3  *M_PI / 2, 0);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

@implementation UIImage (UIImageExt)

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;


- (UIImage*)scaleToSize:(CGSize)size 
{
    size.width = floorf(size.width);
    size.height = floorf(size.height);
    UIGraphicsBeginImageContextWithOptions(size,NO,[UIScreen mainScreen].scale);

	[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage  *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

- (UIImage*)scaleToFixSize:(CGSize)aSize
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
	return [self scaleToSize:picSize];
}

- (UIImage*)scaleToFixSizeIgnoreScale:(CGSize)aSize
{	
	CGSize picSize = self.size;
    while ( picSize.width > aSize.width || picSize.height > aSize.height )
    {
        float scale = ((float)aSize.width/picSize.width);
        if ( scale == 1.0f )
        {
            scale = ((float)aSize.height/picSize.height);
        }
        picSize.width *= scale;
        picSize.height *= scale;
    }	
    picSize.width = floorf(picSize.width);
    picSize.height = floorf(picSize.height);
    
    UIGraphicsBeginImageContextWithOptions(picSize,NO,1.0);
    
	[self drawInRect:CGRectMake(0, 0, picSize.width, picSize.height)];
	UIImage  *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

- (UIImage*)fixedImageSizeToFit:(CGFloat)maxEdgeLength
{
    CGSize imageSize = self.size;
    if (imageSize.width <= maxEdgeLength || imageSize.height <= maxEdgeLength)
    {
        return [self scaleAndRotateImage:imageSize];
    }
    CGSize   newSize = imageSize;
    if (imageSize.width < imageSize.height)
    {
        newSize.width = maxEdgeLength;
        newSize.height = floorf(imageSize.height*(maxEdgeLength/imageSize.width));
    }
    else
    {
        newSize.height = maxEdgeLength;
        newSize.width = floorf(imageSize.width*(maxEdgeLength/imageSize.height));
    }
    return [self scaleAndRotateImage:newSize];
}

- (UIImage*)clipImageToSize:(CGSize)size
{
    UIImage *tmp = self;
    if (self.size.width < size.width || self.size.height < size.height)
    {
        tmp = [self scaleToFixSize:size];
    }
    size.width = floorf(size.width);
    size.height = floorf(size.height);
    
    UIGraphicsBeginImageContextWithOptions(size,NO,[UIScreen mainScreen].scale);
    [tmp drawAtPoint:CGPointMake(0 - floorf((tmp.size.width - size.width)/2), 0 - floorf((tmp.size.height - size.height)/2))];
	UIImage  *newimage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newimage;

}

- (UIImage *)convertToGrayscale
{
    
    CGSize size = [self size];
    int width = size.width;
    int height = size.height;
	
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width  *height  *sizeof(uint32_t));
	
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width  *height  *sizeof(uint32_t));
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width  *sizeof(uint32_t), colorSpace, 
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast | kCGImageAlphaNone );
	
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
	
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y  *width + x];
			
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3  *rgbaPixel[RED] + 0.59  *rgbaPixel[GREEN] + 0.11  *rgbaPixel[BLUE];
			
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
	
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
	
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
	
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
	
    // we're done with image now too
    CGImageRelease(image);
	
    return resultUIImage;
     
    /*
    int width = self.size.width; 
    int height = self.size.height; 
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray(); 
    CGContextRef context = CGBitmapContextCreate (nil,width,height,8,0,colorSpace,kCGImageAlphaNone); 
    CGColorSpaceRelease(colorSpace); 
    if (context == NULL) 
    { 
        return nil; 
    } 
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), self.CGImage); 
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)]; 
    CGContextRelease(context); 
    return grayImage;
     */
}

- (UIImage*)imageUseMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([self CGImage], mask);
    return [UIImage imageWithCGImage:masked];
    
}


//- (UIImage*)imageUseMask:(UIImage*)mask 
//{
//    CGFloat scale = [[UIScreen mainScreen] scale];
//	CGFloat width = mask.size.width  *scale;
//	CGFloat height = mask.size.height  *scale;
//	CGContextRef mainViewContentContext;
//	CGColorSpaceRef colorSpace;
//	colorSpace = CGColorSpaceCreateDeviceRGB();
//	// create a bitmap graphics context the size of the image
//	mainViewContentContext = CGBitmapContextCreate (NULL, width, height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
//	// free the rgb colorspace
//	CGColorSpaceRelease(colorSpace);
//	if (mainViewContentContext==NULL)
//		return NULL;
//	
//	CGImageRef maskImage = mask.CGImage;
//	CGContextClipToMask(mainViewContentContext, CGRectMake(0, 0, width, height), maskImage);
//	CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, width,  height), self.CGImage);
//	
//	// Create CGImageRef of the main view bitmap content, and then
//	// release that bitmap context
//	CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
//	CGContextRelease(mainViewContentContext);
//	// convert the finished resized image to a UIImage
//	UIImage *theImage = nil;
//	if ([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)])
//	{
//		theImage = [UIImage imageWithCGImage:mainViewContentBitmapContext scale:scale orientation:UIImageOrientationUp];
//	}
//	else
//	{
//		theImage = [UIImage imageWithCGImage:mainViewContentBitmapContext];
//	}
//    
//	CGImageRelease(mainViewContentBitmapContext);
//	// return the image
//	return theImage;
//}

- (UIImage*)mirrorImage
{
    CGSize imagesize = self.size;
	CGRect rect = CGRectMake(0, 0, imagesize.width, imagesize.height);
    UIGraphicsBeginImageContextWithOptions(rect.size,NO,[UIScreen mainScreen].scale);
    
    CGContextRef context= UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform = CGAffineTransformMakeTranslation(imagesize.width, 0.0);
    transform = CGAffineTransformScale(transform, -1.0, 1.0);
    CGContextConcatCTM(context, transform);
    [self drawInRect:rect];
    
	UIImage  *newimage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newimage;
}

- (UIImage*)clipImageFrom:(CGFloat)left width:(CGFloat)width
{
    if (left<0 || left > self.size.width)
    {
        return self;
    }
    if (width < 1 || width > (self.size.width - left))
    {
        width = self.size.width - left;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, self.size.height),NO,[UIScreen mainScreen].scale);
    [self drawAtPoint:CGPointMake(0 - (self.size.width - left), 0)];
	UIImage  *newimage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newimage;
}

- (UIImage*)imageWithColor:(UIColor*)color
{
    CGSize imagesize = self.size;
	CGRect rect = CGRectMake(0, 0, imagesize.width, imagesize.height);
    
    UIGraphicsBeginImageContextWithOptions(rect.size,NO,[UIScreen mainScreen].scale);
    
    CGContextRef context= UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, imagesize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextClipToMask(context, rect, self.CGImage); 
    
	CGContextSetFillColorWithColor( context, color.CGColor );   
	CGContextFillRect( context, rect );
	UIImage  *newimage = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
	return newimage;
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

+ (UIImage*)imageMerged:(UIImage*)image withTopImage:(UIImage*)topImage insetSize:(CGSize)insetSize size:(CGSize)size
{
	UIGraphicsBeginImageContextWithOptions(size,NO,[UIScreen mainScreen].scale);
	CGRect rect = CGRectMake(0, 0, size.width, size.height);    
    CGRect r = CGRectInset(rect, insetSize.width, insetSize.height);
	[image drawInRect:r];
    [topImage drawInRect:rect];


	UIImage  *newimage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newimage;
}
+ (UIImage*)imageMerged:(UIImage*)image withTopImage:(UIImage*)topImage
{
	UIGraphicsBeginImageContextWithOptions(topImage.size,NO,[UIScreen mainScreen].scale);
	CGRect rect = CGRectMake((topImage.size.width - image.size.width)/2,(topImage.size.height - image.size.height)/2,image.size.width,image.size.height);
	[image drawInRect:rect];
    
    CGRect rect2 = CGRectMake(0, 0, topImage.size.width, topImage.size.height);
    [topImage drawInRect:rect2];
	UIImage  *newimage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newimage;
}

+ (UIImage*)imageMerged:(UIImage*)image withTopImage:(UIImage*)topImage offset:(CGPoint)offset
{
    UIGraphicsBeginImageContextWithOptions(image.size,NO,[UIScreen mainScreen].scale);
	CGRect rect = CGRectMake(0,0, image.size.width, image.size.height);
	[image drawInRect:rect];
    
    CGRect rect2 = CGRectMake(offset.x, offset.y, topImage.size.width, topImage.size.height);
    [topImage drawInRect:rect2];
	UIImage  *newimage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newimage;
}
- (UIImage*)imageMergedWithBg:(UIImage*)image expandSize:(CGSize)expandSize offset:(CGPoint)offset
{
    CGSize size = self.size;
	UIGraphicsBeginImageContextWithOptions(size,NO,[UIScreen mainScreen].scale);
	CGRect rect = CGRectMake(0, 0, size.width, size.height);
	[image drawInRect:rect];
    [self drawInRect:CGRectOffset(CGRectInset(rect, expandSize.width, expandSize.height),offset.x,offset.y)];
    
	UIImage  *newimage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newimage;
}

+ (UIImage *)image:(UIImage *)image mergedWithBgImage:(UIImage *)bgImage forSize:(CGSize)size
{
    bgImage = [bgImage stretchableImageWithLeftCapWidth:bgImage.size.width/2 topCapHeight:bgImage.size.height/2];
	CGRect borderRect = CGRectMake(0, 0, size.width, size.height);
    CGRect textureRect = CGRectMake((borderRect.size.width - image.size.width )/ 2, (borderRect.size.height - image.size.height )/ 2, image.size.width, image.size.height);
    
	UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [bgImage drawInRect:borderRect];
    [image drawInRect:textureRect];
	UIImage  *newimage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newimage;
}

+ (UIImage *)image:(UIImage *)image mergedWithBgImage:(UIImage *)bgImage topSize:(CGSize)topSize bgSize:(CGSize)bgSize
{
    
    CGSize imageSize = topSize.height > bgSize.height ? topSize : bgSize;
    
	CGRect bgRect = CGRectMake((imageSize.width - bgSize.width)/2, (imageSize.height - bgSize.height)/2, bgSize.width, bgSize.height);
    CGRect topRect = CGRectMake((imageSize.width - topSize.width)/2, (imageSize.height - topSize.height)/2, topSize.width, topSize.height);
    
    
	UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    [bgImage drawInRect:bgRect];
    [image drawInRect:topRect];
	UIImage  *newimage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newimage;
}

- (UIImage *)roundCorner
{
    int w = self.size.width;
    int h = self.size.height;
    
	CGSize size = CGSizeMake(w, h);
    UIGraphicsBeginImageContextWithOptions(size,NO,[UIScreen mainScreen].scale);
   	CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGRect rect = CGRectMake(0, 0, w, h);
    addRoundedRectToPath(context, rect, 3.0f);
    CGContextClosePath(context);
    CGContextClip(context);
    
	[self drawInRect:CGRectMake(0, 0, w, h)];
    
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return imageOut;    
}

-(UIImage *)imageAtRect:(CGRect)rect
{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    
    return subImage;
    
}

- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (!CGSizeEqualToSize(imageSize, targetSize)) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) 
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width  *scaleFactor;
        scaledHeight = height  *scaleFactor;
        
            // center the image
        
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight)  *0.5; 
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth)  *0.5;
        }
    }
    
    
        // this is actually the interesting part:
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, [UIScreen mainScreen].scale);

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) DDLogError(@"could not scale image");
    
    
    return newImage ;
}


- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (!CGSizeEqualToSize(imageSize, targetSize)) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor) 
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width  *scaleFactor;
        scaledHeight = height  *scaleFactor;
        
            // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight)  *0.5; 
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth)  *0.5;
        }
    }
    
    
        // this is actually the interesting part:
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, [UIScreen mainScreen].scale);

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) DDLogError(@"could not scale image");
    
    
    return newImage ;
}


- (UIImage *)imageByScalingToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
        //   CGSize imageSize = sourceImage.size;
        //   CGFloat width = imageSize.width;
        //   CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
        //   CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
        // this is actually the interesting part:
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, [UIScreen mainScreen].scale);

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) DDLogError(@"could not scale image");
    
    
    return newImage ;
}


- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    return [self imageRotatedByDegrees:RadiansToDegrees(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees 
{   
        // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
        // Create the bitmap context
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, [UIScreen mainScreen].scale);

    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
        // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
        //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
        // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

- (UIImage*)scaleAndRotateImage:(CGSize)targetSize
{
    
    CGFloat  scaleRatio = targetSize.width/self.size.width;
    CGRect bounds = CGRectMake(0, 0, 0, 0);
    
    bounds.size.width = targetSize.width;
    bounds.size.height = targetSize.height;
    
    
    CGImageRef imgRef =self.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    if (width < bounds.size.width && height < bounds.size.height)
    {
        return self;
    }
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    UIImageOrientation orient =self.imageOrientation;
    switch(orient)
    {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0  *M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0  *M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid?image?orientation"];
            break;
    }
    
    bounds.size = CGSizeMake(floorf(bounds.size.width), floorf(bounds.size.height));
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, [UIScreen mainScreen].scale);

    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
    {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, floorf(width), floorf(height)), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)clipImageToSquare
{
    CGSize sizeOrigin = self.size;
    if (sizeOrigin.width != sizeOrigin.height)
    {
        CGFloat clipHeight = sizeOrigin.width > sizeOrigin.height ? sizeOrigin.height : sizeOrigin.width;
        CGFloat offsetX = ceil((self.size.width - clipHeight)/2);
        CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], CGRectMake(offsetX, 0, clipHeight, clipHeight));
        UIImage *squareImg = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        return squareImg;
    }
    else
    {
        return self;
    }
}

- (UIImage *)stretchableMiddleImage
{
    return [self stretchableImageWithLeftCapWidth:self.size.width/2 topCapHeight:self.size.height/2];
}

+ (UIImage *)imageWithBezierPath:(UIBezierPath *)path color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor
{
    UIGraphicsBeginImageContextWithOptions((CGSizeMake(path.bounds.origin.x * 2 + path.bounds.size.width, path.bounds.origin.y * 2 + path.bounds.size.height)), NO, .0);
    
    if (backgroundColor) {
        [backgroundColor set];
        [path fill];
    }
    if (color) {
        [color set];
        [path stroke];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)saveToCameralRoll:(ALAssetsLibraryWriteImageCompletionBlock)block
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:self.CGImage
                              orientation:(ALAssetOrientation)self.imageOrientation
                          completionBlock:block];
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(100, 100), NO, 1.0);
    CGContextRef context= UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor( context, color.CGColor );
	CGContextFillRect( context, CGRectMake(0, 0, 100, 100));
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage ;
}
@end
