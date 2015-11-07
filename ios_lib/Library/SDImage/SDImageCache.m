/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDImageCache.h"
#import "SDWebImageDecoder.h"
#import <CommonCrypto/CommonDigest.h>
#import "SDWebImageDecoder.h"
#import <mach/mach.h>
#import <mach/mach_host.h>

static SDImageCache *instance;

static NSInteger cacheMaxCacheAge = 60*60*24*7; // 1 week
//static natural_t minFreeMemLeft = 1024*1024*12; // reserve 12MB RAM

// inspired by http://stackoverflow.com/questions/5012886/knowing-available-ram-on-an-ios-device
static natural_t get_free_memory(void)
{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;

    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);

    vm_statistics_data_t vm_stat;

    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
    {
        NSLog(@"Failed to fetch vm statistics");
        return 0;
    }

    /* Stats in bytes */
    natural_t mem_free = vm_stat.free_count * pagesize;
    return mem_free;
}

@implementation SDImageCache

#pragma mark NSObject

- (id)init
{
    if ((self = [super init]))
    {
        // Init the memory cache
        memCache = [[NSMutableDictionary alloc] init];

        // Init the disk cache
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        diskCachePath = SDWIReturnRetained([[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"]);

        if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }

        // Init the operation queue
        cacheInQueue = [[NSOperationQueue alloc] init];
        cacheInQueue.maxConcurrentOperationCount = 1;
        cacheOutQueue = [[NSOperationQueue alloc] init];
        cacheOutQueue.maxConcurrentOperationCount = 1;

//#if TARGET_OS_IPHONE
        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_0
        UIDevice *device = [UIDevice currentDevice];
        if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported)
        {
            // When in background, clean memory in order to have less chance to be killed
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(clearMemory)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];
        }
#endif
//#endif
    }

    return self;
}

- (void)dealloc
{
    SDWISafeRelease(memCache);
    SDWISafeRelease(diskCachePath);
    SDWISafeRelease(cacheInQueue);

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    SDWISuperDealoc;
}

#pragma mark SDImageCache (class methods)

+ (SDImageCache *)sharedImageCache
{
    if (instance == nil)
    {
        instance = [[SDImageCache alloc] init];
    }

    return instance;
}

+ (void) setMaxCacheAge:(NSInteger)maxCacheAge
{
    cacheMaxCacheAge = maxCacheAge;
}

#pragma mark SDImageCache (private)

- (NSString *)cachePathForKey:(NSString *)key
{
    if ([key rangeOfString:@"http" options:NSCaseInsensitiveSearch].location != 0)
    {
        //this is location file
        return key;
    }
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];

    return [diskCachePath stringByAppendingPathComponent:filename];
}

- (void)storeKeyWithDataToDisk:(NSArray *)keyAndData
{
    // Can't use defaultManager another thread
    NSFileManager *fileManager = [[NSFileManager alloc] init];

    NSString *key = [keyAndData objectAtIndex:0];
    NSData *data = [keyAndData count] > 1 ? [keyAndData objectAtIndex:1] : nil;

    if (data)
    {
        [fileManager createFileAtPath:[self cachePathForKey:key] contents:data attributes:nil];
    }
    else
    {
        // If no data representation given, convert the UIImage in JPEG and store it
        // This trick is more CPU/memory intensive and doesn't preserve alpha channel
        UIImage *image = SDWIReturnRetained([self imageFromKey:key fromDisk:YES]); // be thread safe with no lock
        if (image)
        {
#if TARGET_OS_IPHONE
            [fileManager createFileAtPath:[self cachePathForKey:key] contents:UIImageJPEGRepresentation(image, (CGFloat)1.0) attributes:nil];
#else
            NSArray*  representations  = [image representations];
            NSData* jpegData = [NSBitmapImageRep representationOfImageRepsInArray: representations usingType: NSJPEGFileType properties:nil];
            [fileManager createFileAtPath:[self cachePathForKey:key] contents:jpegData attributes:nil];
#endif
            SDWIRelease(image);
        }
    }

    SDWIRelease(fileManager);
}

- (void)notifyDelegate:(NSDictionary *)arguments
{
    NSString *key = [arguments objectForKey:@"key"];
    id <SDImageCacheDelegate> delegate = [arguments objectForKey:@"delegate"];
    NSDictionary *info = [arguments objectForKey:@"userInfo"];
    UIImage *image = [arguments objectForKey:@"image"];

    if (image)
    {
//        if (get_free_memory() < minFreeMemLeft)
//        {
//            [memCache removeAllObjects];
//        }    
        [memCache setObject:image forKey:key];

        if ([delegate respondsToSelector:@selector(imageCache:didFindImage:forKey:userInfo:)])
        {
            [delegate imageCache:self didFindImage:image forKey:key userInfo:info];
        }
    }
    else
    {
        if ([delegate respondsToSelector:@selector(imageCache:didNotFindImageForKey:userInfo:)])
        {
            [delegate imageCache:self didNotFindImageForKey:key userInfo:info];
        }
    }
}

- (void)queryDiskCacheOperation:(NSDictionary *)arguments
{
    NSString *key = [arguments objectForKey:@"key"];
    NSMutableDictionary *mutableArguments = SDWIReturnAutoreleased([arguments mutableCopy]);
    NSURL *url = arguments[@"userInfo"][@"url"];
    UIImage *imageTemp;
    if ([url isFileURL])
    {
        imageTemp = [self getImmediateLoadWithContentsOfFile:url.path];
    }
    else
    {
        imageTemp = [self getImmediateLoadWithContentsOfFile:[self cachePathForKey:key]];
    }
    
    
    UIImage *image = SDScaledImageForPath(key, imageTemp);

    if (image)
    {
        
        if ([[[NSURL URLWithString:key] pathExtension] compare:@"png" options:NSCaseInsensitiveSearch] != NSOrderedSame)
        {
            UIImage *decodedImage = [UIImage decodedImageWithImage:image];
            if (decodedImage)
            {
                image = decodedImage;
            }            
        }

        [mutableArguments setObject:image forKey:@"image"];
    }

    [self performSelectorOnMainThread:@selector(notifyDelegate:) withObject:mutableArguments waitUntilDone:NO];
}

#pragma mark ImageCache

- (NSData *)imageDataForKey:(NSString *)key
{
    NSString *path = [self cachePathForKey:key];
    return [NSData dataWithContentsOfFile:path];
}


- (void)storeImage:(UIImage *)image imageData:(NSData *)data forKey:(NSString *)key toDisk:(BOOL)toDisk
{
    [self storeImage:image imageData:data forKey:key toDisk:toDisk cache:YES];
}

- (void)storeImage:(UIImage *)image imageData:(NSData *)data forKey:(NSString *)key toDisk:(BOOL)toDisk cache:(BOOL)cache

{
    if (!image || !key)
    {
        return;
    }
    
//    if (get_free_memory() < minFreeMemLeft)
//    {
//        [memCache removeAllObjects];
//    }
    if ( cache )
    {
        [memCache setObject:image forKey:key];
    }
    if (toDisk)
    {
        NSArray *keyWithData;
        if (data)
        {
            keyWithData = [NSArray arrayWithObjects:key, data, nil];
        }
        else
        {
            keyWithData = [NSArray arrayWithObjects:key, nil];
        }

        NSInvocationOperation *operation = SDWIReturnAutoreleased([[NSInvocationOperation alloc] initWithTarget:self
                                                                                                       selector:@selector(storeKeyWithDataToDisk:)
                                                                                                         object:keyWithData]);
        [cacheInQueue addOperation:operation];
    }
}

- (void)storeImageData:(NSData *)data forKey:(NSString *)key
{
    NSArray *keyWithData = [NSArray arrayWithObjects:key, data, nil];
    NSInvocationOperation *operation = SDWIReturnAutoreleased([[NSInvocationOperation alloc] initWithTarget:self
                                                                                                   selector:@selector(storeKeyWithDataToDisk:)
                                                                                                     object:keyWithData]);
    [cacheInQueue addOperation:operation];

}

- (void)storeImageOnlyToDisk:(UIImage *)image forKey:(NSString *)key;
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSData *data = UIImageJPEGRepresentation(image, (CGFloat)1.0);
        if (![fileManager fileExistsAtPath:diskCachePath])
        {
            [fileManager createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        [fileManager createFileAtPath:[self cachePathForKey:key] contents:data attributes:nil];
        SDWIRelease(fileManager);
    });
}

- (void)storeImageOnlyToDisk:(UIImage *)image forKey:(NSString *)key inQueue:(dispatch_queue_t)queue
{
    dispatch_block_t block = ^(void){
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSData *data = UIImageJPEGRepresentation(image, (CGFloat)1.0);
        if (![fileManager fileExistsAtPath:diskCachePath])
        {
            [fileManager createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        [fileManager createFileAtPath:[self cachePathForKey:key] contents:data attributes:nil];
        SDWIRelease(fileManager);
    };
    if(queue)
    {
        dispatch_async(queue, ^{
            block();
        });
    }
    else
    {
        block();
    }
}


- (void)immediatelyStoreImageData:(NSData *)data image:(UIImage*)image forKey:(NSString *)key
{
    if ( image )
    {
         [memCache setObject:image forKey:key];
    }
    [self storeKeyWithDataToDisk: [NSArray arrayWithObjects:key, data, nil]];
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)key
{
    [self storeImage:image imageData:nil forKey:key toDisk:YES];
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)key toDisk:(BOOL)toDisk
{
    [self storeImage:image imageData:nil forKey:key toDisk:toDisk];
}


- (UIImage *)imageFromKey:(NSString *)key
{
    return [self imageFromKey:key fromDisk:YES];
}


- (UIImage*)getImmediateLoadWithContentsOfFile:(NSString*)path
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage imageWithData:data];
//    if ( image )
//    {
//        image = speedUpImage(image);
//    }
    return image;
//    else
//    {
//        return nil;
//    }
    
//    CGImageRef imageRef = [image CGImage];
//
//    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
//    CGRect rect = CGRectMake(0.f, 0.f, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
//    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
//                                                       rect.size.width,
//                                                       rect.size.height,
//                                                       CGImageGetBitsPerComponent(imageRef),
//                                                       CGImageGetBytesPerRow(imageRef),
//                                                       colorSpace,
//                                                       kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little
//                                                       );
//    //kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little are the bit flags required so that the main thread doesn't have any conversions to do.
//    
//    CGContextDrawImage(bitmapContext, rect, imageRef);
//    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(bitmapContext);
//    UIImage* decompressedImage = [[UIImage alloc] initWithCGImage: decompressedImageRef];
//    CGImageRelease(decompressedImageRef);
//    CGContextRelease(bitmapContext);
//    [image release];
//    
//    return [decompressedImage autorelease];
}

- (UIImage *)imageFromKey:(NSString *)key fromDisk:(BOOL)fromDisk
{
    if (key == nil)
    {
        return nil;
    }

    UIImage *image = [memCache objectForKey:key];

    if (!image && fromDisk)
    {
        NSURL *url = [NSURL URLWithString:key];
        UIImage *imageTemp;
        if ([url isFileURL])
        {
            imageTemp = [self getImmediateLoadWithContentsOfFile:url.path];
        }
        else
        {
             imageTemp= [self getImmediateLoadWithContentsOfFile:[self cachePathForKey:key]];
        }
        image = SDScaledImageForPath(key,imageTemp);
        if (image)
        {
//            if (get_free_memory() < minFreeMemLeft)
//            {
//                [memCache removeAllObjects];
//            }
            [memCache setObject:image forKey:key];
        }
    }

    return image;
}

- (UIImage *)imageFromDiskWithKey:(NSString *)key
{
    UIImage *diskImage = [UIImage decodedImageWithImage:SDScaledImageForPath(key, [NSData dataWithContentsOfFile:[self cachePathForKey:key]])];
    
    return diskImage;
}


- (void)queryDiskCacheForKey:(NSString *)key delegate:(id <SDImageCacheDelegate>)delegate userInfo:(NSDictionary *)info
{
    if (!delegate)
    {
        return;
    }

    if (!key)
    {
        if ([delegate respondsToSelector:@selector(imageCache:didNotFindImageForKey:userInfo:)])
        {
            [delegate imageCache:self didNotFindImageForKey:key userInfo:info];
        }
        return;
    }

    // First check the in-memory cache...
    UIImage *image = [memCache objectForKey:key];
    if (image)
    {
        // ...notify delegate immediately, no need to go async
        if ([delegate respondsToSelector:@selector(imageCache:didFindImage:forKey:userInfo:)])
        {
            [delegate imageCache:self didFindImage:image forKey:key userInfo:info];
        }
        return;
    }

    NSMutableDictionary *arguments = [NSMutableDictionary dictionaryWithCapacity:3];
    [arguments setObject:key forKey:@"key"];
    [arguments setObject:delegate forKey:@"delegate"];
    if (info)
    {
        [arguments setObject:info forKey:@"userInfo"];
    }
    NSInvocationOperation *operation = SDWIReturnAutoreleased([[NSInvocationOperation alloc] initWithTarget:self
                                                                                                   selector:@selector(queryDiskCacheOperation:)
                                                                                                     object:arguments]);
    [cacheOutQueue addOperation:operation];
}

- (void)removeImageForKey:(NSString *)key
{
    [self removeImageForKey:key fromDisk:YES];
}

- (void)removeImageForKey:(NSString *)key fromDisk:(BOOL)fromDisk
{
    if (key == nil)
    {
        return;
    }

    [memCache removeObjectForKey:key];

    if (fromDisk)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self cachePathForKey:key] error:nil];
    }
}

- (void)removeImageForKeyArray:(NSArray *)keyArray
{
    [self removeImageForKeyArray:keyArray fromDisk:NO];
}

- (void)removeImageForKeyArray:(NSArray *)keyArray fromDisk:(BOOL)fromDisk
{
    for ( NSString *key in keyArray )
    {
        [memCache removeObjectForKey:key];
        if (fromDisk)
        {
            [[NSFileManager defaultManager] removeItemAtPath:[self cachePathForKey:key] error:nil];
        }
    }
}

- (BOOL)imageExistsWithKey:(NSString *)key
{
    NSString *path = [self cachePathForKey:key];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (void)clearMemory
{
    [cacheInQueue cancelAllOperations]; // won't be able to complete
    [memCache removeAllObjects];
}

- (void)clearDisk
{
    [cacheInQueue cancelAllOperations];
    [[NSFileManager defaultManager] removeItemAtPath:diskCachePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
}

- (void)cleanDisk
{
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-cacheMaxCacheAge];
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:diskCachePath];
    for (NSString *fileName in fileEnumerator)
    {
        NSString *filePath = [diskCachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if ([[[attrs fileModificationDate] laterDate:expirationDate] isEqualToDate:expirationDate])
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}

-(int)getSize
{
    int size = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:diskCachePath];
    for (NSString *fileName in fileEnumerator)
    {
        NSString *filePath = [diskCachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}

- (int)getDiskCount
{
    int count = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:diskCachePath];
    for (NSString *fileName in fileEnumerator)
    {
        count += 1;
    }
    
    return count;
}

- (int)getMemorySize
{
    int size = 0;
    
    for(id key in [memCache allKeys])
    {
        UIImage *img = [memCache valueForKey:key];
        size += [UIImageJPEGRepresentation(img, 0) length];
    };
    
    return size;
}

- (int)getMemoryCount
{
    return [[memCache allKeys] count];
}

@end
