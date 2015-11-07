//
//  HaloImagePickerEngine.h
//  YContact
//
//  Created by  on 12-5-2.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HaloImagePickerUtils.h"
#import "HaloUIViewController.h"
@class HaloImagePickerEngine;
@protocol HaloImagePickerEngineDelegate<NSObject>
- (void)imagePicked:(UIImage *)image engine:(HaloImagePickerEngine *)engine;
@optional
//this function is not in main thread
- (UIImage *)imagePreviewCustom:(UIImage *)image;
@end

@interface HaloImagePickerEngine : NSObject<HaloImagePickerUtilsDelegate>
@property (nonatomic,assign) NSInteger maxImageWidth;
@property (nonatomic,assign) id<HaloImagePickerEngineDelegate> delegate;
- (id)initWithViewController:(HaloUIViewController *)viewController;
- (UIImage *)selectedImage;
- (UIImage *)previewImage;
- (void)createUploadFile:(void(^)(NSString *filePath))finishBlock;
- (NSString *)imagePath;
- (NSString *)imageMD5;
- (void)useImage:(UIImage*)image;

- (void)showCamera;
- (void)showPhoto;
- (void)showCameraWithEditor;
- (void)showPhotoWithEditor;
//will remove last select image from disk
- (void)reset;
//reset image path can cancel remove last select image from disk before use reset function
- (void)resetImagePath;
@end
