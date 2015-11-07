//
//  YLCameraUtils.m
//  
//
//  Created by lipq on 11-3-2.
//  Copyright 2011  . All rights reserved.
//
#import <MobileCoreServices/UTCoreTypes.h>
#import "HaloImagePickerUtils.h"
#import "HaloUIManager.h"

NSString *HaloImagePickerDidBecomeActiveNotification = @"HaloImagePickerDidBecomeActiveNotification";
NSString *HaloImagePickerWillResignActiveNotification = @"HaloImagePickerWillResignActiveNotification";

@implementation HaloImagePickerUtils
-(id)init
{
    self = [super init];
    if (self)
    {
        self.autoBack = YES;
    }
    return  self;
}

-(void)showCamera:(UIViewController*)controller 
{
	[self showCamera:controller allowEditing:NO];
}
-(void)showCamera:(UIViewController*)controller allowEditing:(BOOL)editing
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) 
    {
        _pickerType = EYLCameraAndImage;
        _currentViewController = controller;
        UIImagePickerController *imagePickerController=[[UIImagePickerController alloc] init];
		imagePickerController.sourceType= UIImagePickerControllerSourceTypeCamera;
		imagePickerController.delegate = self;
        imagePickerController.allowsEditing = editing;
        imagePickerController.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeImage];
        self.currentImageViewController = imagePickerController;
        [controller presentViewController:imagePickerController animated:YES completion:nil];
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:HaloImagePickerWillResignActiveNotification object:nil];
        
	}
}
-(void)showPhotoLibrary:(UIViewController*)controller animated:(BOOL)animated
{
    [self showPhotoLibrary:controller allowEditing:NO animated:animated];
}

-(void)showPhotoLibrary:(UIViewController*)controller allowEditing:(BOOL)editing animated:(BOOL)animated
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
        _pickerType = EYLImage;
        _currentViewController = controller;
        
		UIImagePickerController *imagePickerController=[[UIImagePickerController alloc] init];
		imagePickerController.delegate = self;
		imagePickerController.mediaTypes = [NSArray arrayWithObjects:(NSString*)kUTTypeImage,nil];
		imagePickerController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
		imagePickerController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        imagePickerController.allowsEditing = editing;
        self.currentImageViewController = imagePickerController;
        [controller presentViewController:imagePickerController animated:YES completion:nil];
//        [controller presentHaloViewController:[imagePickerController.viewControllers lastObject] animated:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HaloImagePickerWillResignActiveNotification object:nil];
	}	
}

- (void) didPhotoTaked:(NSDictionary*)dictionary
{
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
//    [UIApplication hideStatusBar:NO];
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(previewImage:)]) 
        {
            [self.delegate performSelector:@selector(previewImage:) withObject:dictionary];
        }
        if (self.autoBack)
        {
            UIImagePickerController *picker = [dictionary objectForKey:@"1"];
            [picker dismissViewControllerAnimated:NO completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:HaloImagePickerDidBecomeActiveNotification object:nil];            
        }
    }
   
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
//    [UIApplication hideStatusBar:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:HaloImagePickerDidBecomeActiveNotification object:nil];
   	NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];    
	if ([mediaType isEqualToString:@"public.image"])
	{
		UIImage *image;
		
		if (picker.title.length > 0)//photo library
		{
            image = [info objectForKey:UIImagePickerControllerEditedImage];
            if (!image)
            {
                image = [info objectForKey:UIImagePickerControllerOriginalImage];
            }
            [self didPhotoTaked:[NSDictionary dictionaryWithObjectsAndKeys:image,@"0",picker,@"1",nil]];
		}
		else //camera
		{
            UIImagePickerController *controller = (UIImagePickerController*)self.currentImageViewController;
            UIImage *image = nil;
            if (controller.allowsEditing)
            {
                image = [info objectForKey:UIImagePickerControllerEditedImage];
            }
            else
            {
                image = [info objectForKey:UIImagePickerControllerOriginalImage];
            }
			if (self.delegate && [self.delegate respondsToSelector:@selector(photoTaked:)]) 
			{
				[self.delegate performSelector:@selector(photoTaked:) withObject:image];
				[HaloImagePickerUtils savePhotoToCameraRoll:image];
			}
		}
	}
	else if([mediaType isEqualToString:@"public.movie"])
	{
		if (self.delegate && [self.delegate respondsToSelector:@selector(videoTaked:)]) 
		{
			[self.delegate performSelector:@selector(videoTaked:) withObject:nil];
		}
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    [UIApplication hideStatusBar:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:HaloImagePickerDidBecomeActiveNotification object:nil];
    if (_pickerType == EYLImageFromCamera) 
    {
        [picker dismissViewControllerAnimated:NO completion:nil];
        [self showCamera:_currentViewController];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerDidCancel)])
        {
            [self.delegate performSelector:@selector(imagePickerDidCancel)];
        }
    }
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{

}

#pragma mark get/show the UIView we want
-(UIView *)findView:(UIView *)aView withName:(NSString *)name{
	Class cl = [aView class];
	NSString *desc = [cl description];
	
	if ([name isEqualToString:desc])
		return aView;
	
	for (NSUInteger i = 0; i < [aView.subviews count]; i++)
	{
		UIView *subView = [aView.subviews objectAtIndex:i];
		subView = [self findView:subView withName:name];
		if (subView)
			return subView;
	}
	return nil;	
}


-(void)showSavedImage
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
	{
        [_currentImageViewController dismissViewControllerAnimated:NO completion:nil];
        _pickerType = EYLImageFromCamera;
		UIImagePickerController *imagePickerController=[[UIImagePickerController alloc] init];
		imagePickerController.delegate = self;
		imagePickerController.mediaTypes = [NSArray arrayWithObjects:(NSString*)kUTTypeImage,nil];
		imagePickerController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
		imagePickerController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        [_currentImageViewController presentViewController:imagePickerController animated:YES completion:nil];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:HaloImagePickerDidBecomeActiveNotification object:nil];
	}	
}

+(void)savePhotoToCameraRoll:(UIImage*)photo
{
	UIImageWriteToSavedPhotosAlbum(photo,nil,nil,nil);
}


@end


