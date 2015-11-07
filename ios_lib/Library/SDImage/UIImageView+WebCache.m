/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import <objc/runtime.h>
#import "UIImage+WebCache.h"

#define KIndicatorViewTag 0xFFF0001

NSString *SDWebImageSizeKey         = @"SDWebImageSizeKey";
NSString *SDWebImageOptionsKey      = @"SDWebImageOptionsKey";
NSString *SDWebImageReqUrlKey       = @"SDWebImageReqUrlKey";
NSString *SDWebImageMaskImageKey    = @"SDWebImageMaskImageKey";
NSString *SDDwnloadIndicatorColorKey = @"SDDwnloadIndicatorColorKey";
NSString *SDWebImageMergeImageKey    = @"SDWebImageMergeImageKey";

NSString *SDWebImageSuccessBlockKey    = @"SDWebImageSuccessBlockKey";

NSString *SDWebImageKey = @"SDWebImageKey";


@implementation UIImageView (WebCache)

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
    
    [self hidDwnloadIndicator];
    
    if ( url == nil )
    {
        //[self.webCacheUserInfo removeAllObjects];
        return;
    }
    
    __block UIImage *image = nil;
    //__block typeof (self) itSelf = self;
    dispatch_block_t __block__ = ^{
        [self.webCacheUserInfo  setValue:[NSNumber numberWithInt:options] forKey:SDWebImageOptionsKey];
        [self.webCacheUserInfo  setValue:url forKey:SDWebImageReqUrlKey];
        [self.webCacheUserInfo  setValue:[NSValue valueWithCGSize:size] forKey:SDWebImageSizeKey];
        if ( image )
        {
            NSString *key = [UIImage keyForImage:url optionsKey:options size:size];
            [self didFinishWithImage:image imageURL:url animated:NO key:key];
        }
        else
        {
            self.image = placeholder;
            [self.webCacheUserInfo removeObjectForKey:SDWebImageKey];
            if (url)
            {
                //[manager downloadWithURL:url delegate:self options:options];
                 [self downloadWithURL:url manager:manager options:options success:nil failure:nil];
            }
        }
    };

    if ( (SDWebImageAsyncLoad & options) != 0 )
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            image = [UIImage loadImageFromCacheWithUrl:url optionsKey:options size:size];
            SDWIRetain(image);
            dispatch_sync(dispatch_get_main_queue(), ^{
                __block__();
            });
            SDWIRelease(image);
        });
    }
    else
    {
        image = [UIImage loadImageFromCacheWithUrl:url optionsKey:options size:size];
        SDWIRetain(image);
        __block__();
        SDWIRelease(image);
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
    [self setImageWithURL:url placeholderImage:placeholder size:[self requestSize] options:options success:success failure:failure];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder placeholderKey:(NSString *)placeholderKey size:(CGSize)size options:(SDWebImageOptions)options success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    [self hidDwnloadIndicator];
    
    if ( url == nil )
    {
        //[self.webCacheUserInfo removeAllObjects];
        return;
    }
    else
    {
        NSURL *preUrl = [self.webCacheUserInfo valueForKey:SDWebImageReqUrlKey];
        if ( preUrl && ![preUrl.absoluteString isEqualToString:url.absoluteString] )
        {
            [[SDImageCache sharedImageCache] removeImageForKey:preUrl.absoluteString fromDisk:NO];
        }
    }
    [self.webCacheUserInfo  setValue:[NSNumber numberWithInt:options] forKey:SDWebImageOptionsKey];
    [self.webCacheUserInfo  setValue:url forKey:SDWebImageReqUrlKey];
    [self.webCacheUserInfo  setValue:[NSValue valueWithCGSize:size] forKey:SDWebImageSizeKey];
    
    BOOL (^loadImageFormDisk)( BOOL fromDisk ) = ^( BOOL fromDisk ){
        NSString *key = [UIImage keyForImage:url optionsKey:options size:size];
        UIImage *image = [[SDImageCache sharedImageCache] imageFromKey:key fromDisk:fromDisk];
        if ( image )
        {
            if ( fromDisk )
            {
                [self didFinishWithImage:image imageURL:url animated:NO key:key];
            }
            else if((options & SDWebImageSetImageOutside) == 0)
            {
                self.image = image;
            }
            
            if ( success )
            {
                success(image, YES);
            }
            return YES;
        }
        return NO;
    };
    
    if ( (options & SDWebImageAutoSetImage ) != 0 && ( options & SDWebImageAsyncLoad ) == 0 && size.width < 50 && size.height < 50 )
    {
        if ( loadImageFormDisk( NO ) )
        {
            return;
        }
    }

    __block UIImage *image = nil;
    __block UIImage *holder = SDWIReturnRetained(placeholder);
    //__block typeof (self) itSelf = self;
    dispatch_block_t __block__ = ^{
        
        if ( loadImageFormDisk(NO) )
        {
            return ;
        }
        else
        {
            self.image = holder;
            [self.webCacheUserInfo removeObjectForKey:SDWebImageKey];
            if (url)
            {
                //[manager downloadWithURL:url delegate:self options:options success:success failure:failure];
                if ( (options & SDWebImageAutoSetImage) == 0 )
                {
                    [self downloadWithURL:url manager:manager options:options success:success failure:failure];
                }
                else
                {
                    if ( success )
                    {
                        SDWebImageSuccessBlock successcopy = [success copy];
                        [self.webCacheUserInfo setObject:successcopy forKey:SDWebImageSuccessBlockKey];
                        SDWIRelease(successcopy);
                    }
                    [self downloadWithURL:url manager:manager options:options success:nil failure:failure];
                }
            }
        }
    };
    
    dispatch_block_t __getplaceholder__ = ^{
        if ( placeholderKey != nil )
        {
            UIImage *h = SDWIReturnRetained([[SDImageCache sharedImageCache] imageFromKey:placeholderKey]);
            if ( h != nil )
            {
                SDWISafeRelease( holder );
                holder = h;
            }
        }
    };
    
    dispatch_block_t __main__ = ^{
        image = SDWIReturnRetained([UIImage loadImageFromCacheWithUrl:url optionsKey:options size:size]);
        if ( image == nil  )
        {
            __getplaceholder__();
        }
        if ( [NSThread isMainThread] )
        {
            __block__();
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                __block__();
            });
        }
        SDWISafeRelease(image);
        SDWISafeRelease(holder);
    };
    
    if ( (SDWebImageAsyncLoad & options) != 0 )
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            __main__();
        });
    }
    else
    {
        __main__();
    }
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder size:(CGSize)size options:(SDWebImageOptions)options success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure
{

    [self setImageWithURL:url placeholderImage:placeholder placeholderKey:nil size:size options:options success:success failure:failure];
}

- (void)downloadWithURL:(NSURL *)url manager:(SDWebImageManager *)manager  options:(SDWebImageOptions)options success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure
{
    [manager downloadWithURL:url delegate:self options:options success:success failure:failure];
    if ( (SDWebImageShowIndicator & options)  != 0 )
    {
        [self showDwnloadIndicator];
    }
}

- (void)showDwnloadIndicator
{
    UIActivityIndicatorView *view = (UIActivityIndicatorView *)[self viewWithTag:KIndicatorViewTag];
    if ( view == nil )
    {
        view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        view.tag = KIndicatorViewTag;
        [self addSubview:view];
        view.hidesWhenStopped = YES;
        UIColor *color = [self.webCacheUserInfo valueForKey:SDDwnloadIndicatorColorKey];
        if ( color == nil )
        {
            color = [UIColor whiteColor];
        }
        view.color = color;
    }
    view.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [view startAnimating];
}

- (void)hidDwnloadIndicator
{
    UIActivityIndicatorView *view = (UIActivityIndicatorView *)[self viewWithTag:KIndicatorViewTag];
    if (  view != nil )
    {
        [view stopAnimating];
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

- (void)didFinishWithImage:(UIImage *)image imageURL:(NSURL *)url animated:(BOOL)animated key:(NSString*)key
{
    NSString *ckey = [self.webCacheUserInfo valueForKey:SDWebImageKey];
    if ( ckey != nil && [ckey isEqualToString:key] )
    {
        return;
    }
    if (self.superview && animated )
    {
        [UIView transitionWithView:[self superview]
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                        animations:^{
                            self.image = image;
                        } completion:NULL];
    }
    else
    {
        self.image = image;
        [self setNeedsLayout];
    }
    
    if ( key!= nil )
    {
        [self.webCacheUserInfo setValue:key forKey:SDWebImageKey];
        
        NSURL *u = [self.webCacheUserInfo valueForKey:SDWebImageReqUrlKey];
        if ( u != nil )
        {
            NSString *orikey = u.absoluteString;
            if ( ![orikey isEqualToString:key] )
            {
                [[SDImageCache sharedImageCache] removeImageForKey:orikey fromDisk:NO];
            }
        }
        
    }
    [self hidDwnloadIndicator];
    
    SDWebImageSuccessBlock block = [self.webCacheUserInfo valueForKey:SDWebImageSuccessBlockKey];
    if ( block )
    {
        block ( image, NO );
        [self.webCacheUserInfo removeObjectForKey:SDWebImageSuccessBlockKey];
    }
}

- (void)didFinishWithImage:(UIImage *)image url:(NSURL *)url key:(NSString*)key
{
    [self didFinishWithImage:image imageURL:url animated:YES key:key];
}


//- (void)webImageManager:(SDWebImageManager *)imageManager didProgressWithPartialImage:(UIImage *)image forURL:(NSURL *)url
//{
//}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image forURL:(NSURL *)url
{
    //__block typeof (self) itSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //typeof (self) iSelf = itSelf;
        NSURL *u = [self.webCacheUserInfo valueForKey:SDWebImageReqUrlKey];
        if ( [u.absoluteString isEqualToString:url.absoluteString] )
        {
            NSNumber *options = [self.webCacheUserInfo valueForKey:SDWebImageOptionsKey];
            if ( ( SDWebImageAutoSetImage & options.intValue ) != 0 )
            {
                NSString *key = nil;
                UIImage *maskImage = [self.webCacheUserInfo valueForKey:SDWebImageMaskImageKey];
                UIImage *mergeImage = [self.webCacheUserInfo valueForKey:SDWebImageMergeImageKey];
                UIImage *img = [image imageSizeToFitsWithSize:[self requestSize] optionsKey:options.intValue url:u mask:maskImage mergeImage:mergeImage key:&key];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self didFinishWithImage:img url:url key:key];
                });
            }
        }
    });
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error forURL:(NSURL *)url
{
    [self.webCacheUserInfo removeObjectForKey:SDWebImageKey];
    [self hidDwnloadIndicator];
    DDLogError( @"%@", [error description]);
}

@end
