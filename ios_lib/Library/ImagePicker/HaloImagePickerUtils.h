//
//  YLCameraUtils.h
//  
//
//  Created by lipq on 11-3-2.
//  Copyright 2011  . All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *HaloImagePickerDidBecomeActiveNotification;
extern NSString *HaloImagePickerWillResignActiveNotification;

typedef enum
{
    EYLImage,
    EYLCamera,
    EYLCameraAndImage,
    EYLImageFromCamera
}EYLImagePickerType;

@protocol HaloImagePickerUtilsDelegate<NSObject>

-(void)photoTaked:(UIImage*)image;
-(void)videoTaked:(NSString*)path;
@optional
-(void)previewImage:(NSDictionary*)dictionary;
- (void)imagePickerDidCancel;

@end
@interface HaloImagePickerUtils : NSObject<UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    EYLImagePickerType                  _pickerType;
    UIViewController                    *_currentViewController;
}
@property(nonatomic,assign)id<HaloImagePickerUtilsDelegate>   delegate;
@property(nonatomic,weak)UINavigationController *currentImageViewController;
@property(nonatomic,assign)BOOL autoBack;

-(void)showCamera:(UIViewController*)controller;
-(void)showCamera:(UIViewController*)controller allowEditing:(BOOL)editing;
-(void)showPhotoLibrary:(UIViewController*)controller animated:(BOOL) animated;
-(void)showPhotoLibrary:(UIViewController*)controller allowEditing:(BOOL)editing animated:(BOOL) animated;
+(void)savePhotoToCameraRoll:(UIImage*)photo;

-(UIView *)findView:(UIView *)aView withName:(NSString *)name;
@end

