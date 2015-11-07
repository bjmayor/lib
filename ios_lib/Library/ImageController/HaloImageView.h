//
//  HaloImageView.h
//  YContact
//
//  Created by peiqiang li on 12-5-9.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HaloPageView.h"
@protocol HaloImageViewDelegate <NSObject>
- (void)singleTap;
@end
@interface HaloImageView : UIScrollView <HaloPageView,UIScrollViewDelegate> {
    UIImageView        *imageView;
    NSUInteger          index;
    
    id<HaloImageViewDelegate>               _imageScrollDelegate;
    UIActivityIndicatorView*                _indicatorView;
}
@property (assign) NSUInteger index;
@property (nonatomic,assign) id<HaloImageViewDelegate> imageDelegate;
@property (nonatomic,retain)UIActivityIndicatorView*   indicatorView;
@property (nonatomic,retain)UIImageView*               imageView;
- (void)displayImage:(UIImage *)image;
- (void)setMaxMinZoomScalesForCurrentBounds;

- (CGPoint)pointToCenterAfterRotation;
- (CGFloat)scaleToRestoreAfterRotation;
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale;

@end



