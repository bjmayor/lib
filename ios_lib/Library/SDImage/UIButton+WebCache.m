/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIButton+WebCache.h"
#import "SDWebImageManager.h"
#import <objc/runtime.h>
#import "UIImage+WebCache.h"

@implementation UIButton (WebCache)

static char userInfoKey;

- (NSMutableDictionary *)webCacheUserInfo
{
    id ret = objc_getAssociatedObject(self, &userInfoKey);
    if ( ret == nil )
    {
        ret = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &userInfoKey,ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ret;
}

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self setImageWithURL:url placeholderImage:placeholder size:[self requestSize] options:options];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder size:(CGSize)size options:(SDWebImageOptions)options
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    [self setImage:placeholder forState:UIControlStateNormal];
    [self setImage:placeholder forState:UIControlStateSelected];
    [self setImage:placeholder forState:UIControlStateHighlighted];
    
    __block UIImage *image = nil;
    //__block typeof (self) itSelf = self;
    dispatch_block_t __block__ = ^{
        if ( image )
        {
            [self webImageManager:manager didFinishWithImage:image forURL:url userInfo:nil];
        }
        else
        {
            [self.webCacheUserInfo  setValue:[NSNumber numberWithInt:options] forKey:SDWebImageOptionsKey];
            [self.webCacheUserInfo  setValue:url forKey:SDWebImageReqUrlKey];
            [self.webCacheUserInfo  setValue:[NSValue valueWithCGSize:size] forKey:SDWebImageSizeKey];
            
            if (url)
            {
                [manager downloadWithURL:url delegate:self options:options];
            }
        }
    };
    if ( (SDWebImageAsyncLoad & options) != 0 )
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            image = [UIImage loadImageFromCacheWithUrl:url optionsKey:options size:size];
            dispatch_sync(dispatch_get_main_queue(), ^{
                __block__();
            });
        });
    }
    else
    {
        image = [UIImage loadImageFromCacheWithUrl:url optionsKey:options size:size];
        __block__();
    }
}

#if NS_BLOCKS_AVAILABLE
- (void)setImageWithURL:(NSURL *)url success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure;
{
    [self setImageWithURL:url placeholderImage:nil success:success failure:failure];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure;
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 success:success failure:failure];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure;
{
    [self setImageWithURL:url placeholderImage:placeholder options:options size:[self requestSize] success:success failure:failure];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options size:(CGSize)size success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    [self setImage:placeholder forState:UIControlStateNormal];
    [self setImage:placeholder forState:UIControlStateSelected];
    [self setImage:placeholder forState:UIControlStateHighlighted];
    
    __block UIImage *image = nil;
    //__block typeof (self) itSelf = self;
    dispatch_block_t __block__ = ^{
        if ( image )
        {
            [self webImageManager:manager didFinishWithImage:image forURL:url userInfo:nil];
            success(image, YES);
        }
        else
        {
            [self.webCacheUserInfo  setValue:[NSNumber numberWithInt:options] forKey:SDWebImageOptionsKey];
            [self.webCacheUserInfo  setValue:url forKey:SDWebImageReqUrlKey];
            [self.webCacheUserInfo  setValue:[NSValue valueWithCGSize:size] forKey:SDWebImageSizeKey];
            
            if (url)
            {
                [manager downloadWithURL:url delegate:self options:options success:success failure:failure];
            }
        }
    };
    if ( (SDWebImageAsyncLoad & options) != 0 )
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            image = [UIImage loadImageFromCacheWithUrl:url optionsKey:options size:size];
            dispatch_sync(dispatch_get_main_queue(), ^{
                __block__();
            });
        });
    }
    else
    {
        image = [UIImage loadImageFromCacheWithUrl:url optionsKey:options size:size];
        __block__();
    }
}

#endif

- (void)setBackgroundImageWithURL:(NSURL *)url
{
    [self setBackgroundImageWithURL:url placeholderImage:nil];
}

- (void)setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setBackgroundImageWithURL:url placeholderImage:placeholder options:0];
}

- (void)setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self setBackgroundImageWithURL:url placeholderImage:placeholder size:[self requestSize] options:options];
}

- (void)setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder size:(CGSize)size options:(SDWebImageOptions)options
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    [self setBackgroundImage:placeholder forState:UIControlStateNormal];
    [self setBackgroundImage:placeholder forState:UIControlStateSelected];
    [self setBackgroundImage:placeholder forState:UIControlStateHighlighted];
    NSDictionary *info = [NSDictionary dictionaryWithObject:@"background" forKey:@"type"];
    
    __block UIImage *image = nil;
    //__block typeof (self) itSelf = self;
    dispatch_block_t __block__ = ^{
        if ( image )
        {
            [self webImageManager:manager didFinishWithImage:image forURL:url userInfo:info];
        }
        else
        {
            [self.webCacheUserInfo  setValue:[NSNumber numberWithInt:options] forKey:SDWebImageOptionsKey];
            [self.webCacheUserInfo  setValue:url forKey:SDWebImageReqUrlKey];
            [self.webCacheUserInfo  setValue:[NSValue valueWithCGSize:size] forKey:SDWebImageSizeKey];
            
            if (url)
            {
                
                 [manager downloadWithURL:url delegate:self options:options userInfo:info];
            }
        }
    };
    
    if ( (SDWebImageSyncLoadCache & options) == 0 )
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            image = [UIImage loadImageFromCacheWithUrl:url optionsKey:options size:size];
            dispatch_sync(dispatch_get_main_queue(), ^{
                __block__();
            });
        });
    }
    else
    {
        image = [UIImage loadImageFromCacheWithUrl:url optionsKey:options size:size];
        __block__();
    }
}

#if NS_BLOCKS_AVAILABLE
- (void)setBackgroundImageWithURL:(NSURL *)url success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure;
{
    [self setBackgroundImageWithURL:url placeholderImage:nil success:success failure:failure];
}

- (void)setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure;
{
    [self setBackgroundImageWithURL:url placeholderImage:placeholder options:0 success:success failure:failure];
}

- (void)setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure;
{
    [self setBackgroundImageWithURL:url placeholderImage:placeholder size:[self requestSize] options:options success:success failure:failure];
}

- (void)setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder size:(CGSize)size  options:(SDWebImageOptions)options success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    [self setBackgroundImage:placeholder forState:UIControlStateNormal];
    [self setBackgroundImage:placeholder forState:UIControlStateSelected];
    [self setBackgroundImage:placeholder forState:UIControlStateHighlighted];
    NSDictionary *info = [NSDictionary dictionaryWithObject:@"background" forKey:@"type"];
    __block UIImage *image = nil;
    //__block typeof (self) itSelf = self;
    dispatch_block_t __block__ = ^{

        [self.webCacheUserInfo  setValue:[NSNumber numberWithInt:options] forKey:SDWebImageOptionsKey];
        [self.webCacheUserInfo  setValue:url forKey:SDWebImageReqUrlKey];
        [self.webCacheUserInfo  setValue:[NSValue valueWithCGSize:size] forKey:SDWebImageSizeKey];

        if ( image )
        {
            [self webImageManager:manager didFinishWithImage:image forURL:url userInfo:info];
            success(image, YES);
        }
        else
        {
            if (url)
            {
                
                [manager downloadWithURL:url delegate:self options:options userInfo:info success:success failure:failure];
            }
        }
    };
    if ( (SDWebImageSyncLoadCache & options) == 0 )
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            image = [UIImage loadImageFromCacheWithUrl:url optionsKey:options size:size];
            dispatch_sync(dispatch_get_main_queue(), ^{
                __block__();
            });
        });
    }
    else
    {
        image = [UIImage loadImageFromCacheWithUrl:url optionsKey:options size:size];
        __block__();
    }
}

- (CGSize)requestSize
{
    CGSize size = self.frame.size;
    NSValue *sizeValue = [self.webCacheUserInfo valueForKey:SDWebImageSizeKey];
    if ( sizeValue )
    {
        size = [sizeValue CGSizeValue];
    }
    return size;
}

#endif


- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didProgressWithPartialImage:(UIImage *)image forURL:(NSURL *)url userInfo:(NSDictionary *)info
{
    __block typeof (self) itSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        typeof (self) iSelf = itSelf;
        NSURL *u = [iSelf.webCacheUserInfo valueForKey:SDWebImageReqUrlKey];
        if ( [u.absoluteString isEqualToString:url.absoluteString] )
        {
            NSNumber *options = [itSelf.webCacheUserInfo valueForKey:SDWebImageOptionsKey];
            if ( ( SDWebImageAutoSetImage & options.intValue ) != 0 )
            {
                UIImage *img = [image imageSizeToFitsWithSize:[self requestSize] optionsKey:options.intValue url:u];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if ([[info valueForKey:@"type"] isEqualToString:@"background"])
                    {
                        [self setBackgroundImage:img forState:UIControlStateNormal];
                        [self setBackgroundImage:img forState:UIControlStateSelected];
                        [self setBackgroundImage:img forState:UIControlStateHighlighted];
                    }
                    else
                    {
                        [self setImage:img forState:UIControlStateNormal];
                        [self setImage:img forState:UIControlStateSelected];
                        [self setImage:img forState:UIControlStateHighlighted];
                    }
                });
            }
        }
    });
}


- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image forURL:(NSURL *)url userInfo:(NSDictionary *)info
{
//    if ([[info valueForKey:@"type"] isEqualToString:@"background"])
//    {
//        [self setBackgroundImage:image forState:UIControlStateNormal];
//        [self setBackgroundImage:image forState:UIControlStateSelected];
//        [self setBackgroundImage:image forState:UIControlStateHighlighted];
//    }
//    else
//    {
//        [self setImage:image forState:UIControlStateNormal];
//        [self setImage:image forState:UIControlStateSelected];
//        [self setImage:image forState:UIControlStateHighlighted];
//    }
    [self webImageManager:imageManager didProgressWithPartialImage:image forURL:url userInfo:info];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error forURL:(NSURL *)url
{
    DDLogError( @"%@", [error localizedDescription]);
}


@end
