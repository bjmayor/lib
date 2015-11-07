//
//  HaloImagePickerEngine.m
//  YContact
//
//  Created by  on 12-5-2.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "HaloImagePickerEngine.h"
#import "HaloImagePickerUtils.h"
#import "HaloPhotoScrollViewController.h"
#import "UIImageExt.h"
#import "HaloFileUtil.h"
@interface HaloImagePickerEngine()<HaloPhotoScrollViewControllerDelegate>

@property (nonatomic,strong)HaloImagePickerUtils        *imageUtils;
@property (nonatomic,weak)HaloUIViewController          *viewController;
@property (nonatomic,strong)UIImage                     *innerSelectedImage;
@property (nonatomic,strong)NSString                    *innerSelectedImagePath;
@property (nonatomic,strong)UIImage                     *innerPreviewImage;
@property (nonatomic,strong)NSString                    *innerImageMD5;
- (void)useImage:(UIImage*)image;
- (void)handleImage;
@end
@implementation HaloImagePickerEngine
- (id)initWithViewController:(HaloUIViewController *)viewController
{
    self = [super init];
    if (self)
    {
        self.viewController = viewController;
        self.maxImageWidth = 512;
    }
    return self;
}

- (void)dealloc
{
    if (self.innerSelectedImagePath.length > 0)
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.innerSelectedImagePath error:nil];
    }
}

- (UIImage *)selectedImage
{
    return self.innerSelectedImage;
}

- (UIImage *)previewImage
{
    return self.innerPreviewImage;
}

- (NSString *)imagePath
{
    return self.innerSelectedImagePath;
}

- (NSString *)imageMD5
{
    return self.innerImageMD5;
}

- (void)reset
{
    self.imageUtils = nil;
    if (self.innerSelectedImagePath.length > 0)
    {
        [[NSFileManager defaultManager] removeItemAtPath:self.innerSelectedImagePath error:nil];
    }
    self.innerSelectedImage = nil;
    self.innerPreviewImage = nil;
    self.innerSelectedImagePath = nil;
    self.innerImageMD5 = nil;
}

- (void)resetImagePath
{
    self.innerSelectedImagePath = nil;
}

- (void)createImageUtil
{
    if (!_imageUtils)
    {
        self.imageUtils = [[HaloImagePickerUtils alloc] init];
        self.imageUtils.delegate = self;
        self.imageUtils.autoBack = NO;
    }    
}

- (void)showCamera
{
    [self reset];
    [self createImageUtil];
    [self.imageUtils showCamera:self.viewController];
}
- (void)showPhoto
{
    [self reset];
    [self createImageUtil];
    [self.imageUtils showPhotoLibrary:self.viewController animated:YES];
}

- (void)showCameraWithEditor
{
    [self reset];
    [self createImageUtil];
    [self.imageUtils showCamera:self.viewController allowEditing:YES];
}

- (void)showPhotoWithEditor
{
    [self reset];
    [self createImageUtil];
    [self.imageUtils showPhotoLibrary:self.viewController allowEditing:YES animated:YES];
}

- (UIBarButtonItem *)setPhotoNaviRightButton
{
    UIBarButtonItem *deleteBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"use", @"使用") style:UIBarButtonItemStyleBordered target:self action:@selector(useImage)];
    return deleteBtn;
}

#pragma mark - HaloImagePickerUtilsDelegate
-(void)photoTaked:(UIImage*)image
{
    self.innerSelectedImage = image;
    [self.imageUtils.currentImageViewController dismissViewControllerAnimated:YES completion:nil];
    [self useImage:self.innerSelectedImage];
//    HaloPhotoScrollViewController *vc = [[HaloPhotoScrollViewController alloc] initWithImage:image];
//    vc.naviRightButtonType = ENaviRightNone;
//    vc.delegate = self;
//    [self.imageUtils.currentImageViewController presentHaloViewController:vc animated:YES];
}

-(void)videoTaked:(NSString*)path
{

}

-(void)previewImage:(NSDictionary*)dictionary
{
    self.innerSelectedImage = [dictionary objectForKey:@"0"];
    
    HaloPhotoScrollViewController *vc = [[HaloPhotoScrollViewController alloc] initWithImage:self.innerSelectedImage];
    vc.naviRightButtonType = ENaviRightNone;
    vc.delegate = self;
    
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.imageUtils.currentImageViewController presentViewController:nv animated:YES completion:nil];
}

- (void)imagePickerDidCancel
{
    [self reset];
}

- (void)useImage
{
    [self.imageUtils.currentImageViewController dismissViewControllerAnimated:NO completion:nil];
    [self.imageUtils.currentImageViewController dismissViewControllerAnimated:YES completion:nil];
    [self useImage:self.innerSelectedImage];
}

- (void)useImage:(UIImage*)image
{
    if (image)
    {
        self.innerSelectedImage = image;        
        MBProgressHUD *wait = [[MBProgressHUD alloc] initWithView:self.viewController.view];
        CGRect rect = wait.frame;
        rect.origin.y += self.viewController.naviHeight;
        rect.size.height -= (rect.origin.y );
        wait.frame = rect;
        [wait showWhileExecuting:@selector(handleImage) onTarget:self withObject:nil animated:YES];
    }
    else
    {
        self.innerPreviewImage = nil;
        self.innerSelectedImage = nil;
        self.innerSelectedImagePath = nil;
        [self.delegate imagePicked:nil engine:self];
    }
    self.imageUtils = nil;
}

- (void)handleImage
{
    @autoreleasepool {
        self.innerSelectedImage = [self.innerSelectedImage fixedImageSizeToFit:self.maxImageWidth];
        DDLogInfo(@"%@",NSStringFromCGSize(self.innerSelectedImage.size));
        CGFloat width = 50;
        CGFloat height = width / self.innerSelectedImage.size.width * self.innerSelectedImage.size.height;
        CGFloat maxHeight = 100;
        UIImage *image = [self.innerSelectedImage scaleToSize:CGSizeMake(width, height)];
        if (image.size.height > maxHeight)
        {
            self.innerPreviewImage = [image clipImageToSize:CGSizeMake(width, maxHeight)];
        }
        else
        {
            self.innerPreviewImage = image;
        }
        
        
        if ([self.delegate respondsToSelector:@selector(imagePreviewCustom:)])
        {
            self.innerPreviewImage = [self.delegate imagePreviewCustom:self.innerSelectedImage];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate imagePicked:self.innerSelectedImage engine:self];
        });        
    }
}

- (void)createUploadFile:(void(^)(NSString *filePath))finishBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.innerSelectedImagePath == nil)
        {
            NSData *data = UIImageJPEGRepresentation(self.innerSelectedImage, 0.5);
            self.innerImageMD5 = [data MD5String];
            self.innerSelectedImagePath = [HaloFileUtil fileWithUploadPath:[NSString stringWithFormat:@"%.f.jpg",[[NSDate date] timeIntervalSince1970]]];
            [data writeToFile:self.innerSelectedImagePath atomically:NO];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            finishBlock(self.innerSelectedImagePath);
        });
    });
}

@end
