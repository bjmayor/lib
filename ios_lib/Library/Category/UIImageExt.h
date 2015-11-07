//
//  MNUIImage.h
//  juwu
//
//  Created by  on 11-7-15.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface UIImage (UIImageExt)

- (UIImage*)scaleToSize:(CGSize)size;

- (UIImage*)scaleToFixSize:(CGSize)size;

- (UIImage*)scaleToFixSizeIgnoreScale:(CGSize)aSize;

- (UIImage*)fixedImageSizeToFit:(CGFloat)maxEdgeLength;

- (UIImage*)clipImageToSize:(CGSize)size;

- (UIImage *)convertToGrayscale;

- (UIImage*)imageUseMask:(UIImage*)mask ;

- (UIImage*)mirrorImage;

- (UIImage*)clipImageFrom:(CGFloat)left width:(CGFloat)width;

- (UIImage*)imageWithColor:(UIColor*)color;

- (UIImage*)imageMerged:(UIImage*)image;

+ (UIImage*)imageMerged:(UIImage*)image withTopImage:(UIImage*)topImage insetSize:(CGSize)insetSize size:(CGSize)size;

+ (UIImage*)imageMerged:(UIImage*)image withTopImage:(UIImage*)topImage;

+ (UIImage*)imageMerged:(UIImage*)image withTopImage:(UIImage*)topImage offset:(CGPoint)offset;

- (UIImage*)imageMergedWithBg:(UIImage*)image expandSize:(CGSize)expandSize offset:(CGPoint)offset;

//size is bgImgSize
+ (UIImage *)image:(UIImage *)image mergedWithBgImage:(UIImage *)bgImage forSize:(CGSize)size;

+ (UIImage *)image:(UIImage *)image mergedWithBgImage:(UIImage *)bgImage topSize:(CGSize)topSize bgSize:(CGSize)bgSize;

- (UIImage *)roundCorner;

- (UIImage*)scaleAndRotateImage:(CGSize)targetSize;

- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;

- (UIImage *)clipImageToSquare;

//stretch at center
- (UIImage *)stretchableMiddleImage;

//

+ (UIImage *)imageWithBezierPath:(UIBezierPath *)path color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

- (void)saveToCameralRoll:(ALAssetsLibraryWriteImageCompletionBlock)block;

+ (UIImage *)imageWithColor:(UIColor *)color;
@end
