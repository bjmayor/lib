//
//  HaloTheme.m
//  
//
//  Created by lipq on 11-2-18.
//  Copyright 2011  . All rights reserved.
//

#import "HaloTheme.h"
#import "UIColorExt.h"
#import "UIImageExt.h"
#import "HaloFileUtil.h"

#define KTextStyleFile @"Style/style.csv"

#define KMaxImageCacheCount 100
@implementation TextStyle
+ (TextStyle *)textStyleByString:(NSString *)styleString
{
    TextStyle *style = [[TextStyle alloc] init];
    NSScanner *scanner = [NSScanner scannerWithString:styleString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"\r;"]];
    
    NSString *color = nil, *shadowX = nil, *shadowY = nil, *shadowColor = nil;
    while ([scanner scanUpToString:@";" intoString:&color] && [scanner scanUpToString:@";" intoString:&shadowX] && [scanner scanUpToString:@";" intoString:&shadowY] && [scanner scanUpToString:@"\r" intoString:&shadowColor])
    {
        style.shadowOffset = CGSizeMake([shadowX intValue], [shadowY intValue]);
        if (shadowColor.length>0)
        {
            NSInteger c = 0;
            sscanf([shadowColor UTF8String], "%x", &c);
            style.shadowColor = [UIColor colorWithRGBA:c];
        }
        NSInteger c = 0;
        sscanf([color UTF8String], "%x", &c);
        style.color = [UIColor colorWithRGBA:c];
    }
    return style;
}

+ (TextStyle *)textStyleByColor:(UIColor *)color shadowOffset:(CGSize)shadowOffset shadowColor:(UIColor *)shadowColor
{
    TextStyle *style = [[TextStyle alloc] init];
    style.color = color;
    style.shadowOffset = shadowOffset;
    style.shadowColor = shadowColor;
    return style;
}
@end

@interface HaloTheme ()
{
	NSInteger  imageCount;
    NSMutableArray *imageWeightArray;
}
@property(nonatomic)NSInteger imageCount;
@end

@interface HaloTheme(inner)
+ (UIImage*)didImageNamed:(NSString*)name;
+ (UIImage*)imageNamed:(NSString*)name  theme:(NSString*)theme;
+ (UIImage*)imageNamed:(NSString*)name  theme:(NSString*)theme isPad:(BOOL)isPad;
- (void)refreshTextStyle;
- (NSString*)imageDirection;
- (NSString*)imageDirection:(BOOL)isPad;
@end

@implementation HaloTheme(inner)

- (NSString*)imageDirection
{
    return [self imageDirection:[UIDevice isPad]];
}

- (NSString*)imageDirection:(BOOL)isPad
{
    if (isPad)
    {
        return [NSString stringWithFormat:@"/IPad/%@/%@",@"Themes",self.currentThemeFolder];
    }
    else
    {
        return [NSString stringWithFormat:@"/IPhone/%@/%@",@"Themes",self.currentThemeFolder];
    }
}


+ (NSString*)defalutImageName
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return @"Defalut";
    }
    else
    {
        return @"Defalut_pad";
    }
}

+ (UIImage*)didImageNamed:(NSString*)name
{
    //    if ( [@"Default" isEqualToString:name])
    //    {
    //        return [UIImage imageNamed:[self defalutImageName]];
    //    }
    //    else
    {
        NSString *fullName = name;
        if ( [name pathExtension].length == 0 )
        {
            fullName = [NSString stringWithFormat:@"%@.png",name];
        }
        NSString *themeDirection = [[HaloTheme sharedInstance]  currentThemeFolder];
        UIImage *image = [HaloTheme imageNamed:fullName theme:themeDirection];
        if (!image)
        {
            image = [UIImage imageNamed:fullName];
        }
        
        if (!image)
        {
            image = [HaloTheme imageNamed:fullName theme:@"Default"];
        }
        return image;
    }
}

+ (UIImage *)didImageFromPath:(NSString *)fullPath
{
    @autoreleasepool {
        UIImage *image  = nil;
        NSString *path2x = [[fullPath stringByDeletingLastPathComponent]
                            stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x.%@",
                                                            [[fullPath lastPathComponent] stringByDeletingPathExtension],
                                                            [fullPath pathExtension]]];
        //support retina display
        CGFloat scale = 1.0;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        {
            scale = [UIScreen mainScreen].scale;
        }
        if (scale > 1.0 )
        {
            if ( [[NSFileManager defaultManager] fileExistsAtPath:path2x] )
            {
                fullPath = path2x;
            }
            NSData *imagedata = [[NSData alloc]initWithContentsOfFile:fullPath];
            UIImage *temp = [[UIImage alloc] initWithData:imagedata];
            if (temp)
            {
                image = [UIImage imageWithCGImage:temp.CGImage scale:scale orientation:temp.imageOrientation];
            }
        }
        else
        {
            NSData *imagedata = [[NSData alloc]initWithContentsOfFile:fullPath];
            if (imagedata)
            {
                image = [UIImage imageWithData:imagedata];
            }
            else
            {
                imagedata = [[NSData alloc]initWithContentsOfFile:path2x];
                image = [UIImage imageWithData:imagedata];
                if (image)
                {
                    if (scale > 1.0)
                    {
                        image = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:image.imageOrientation];
                    }
                    else
                    {
                        image = [image scaleToFixSize:CGSizeMake(ceil(image.size.width/2), ceil(image.size.height/2))];
                    }
                }
                
            }
        }
        
        return image;
    }
}

+ (UIImage*)imageNamed:(NSString*)name  theme:(NSString*)theme isPad:(BOOL)isPad
{
    NSString *direction = [[HaloTheme sharedInstance] imageDirection:isPad];
	NSString *boudlePath = [[NSBundle mainBundle]  bundlePath];
	NSString *fullPath = [NSString stringWithFormat:@"%@%@/%@",boudlePath,direction,name];
	return [HaloTheme didImageFromPath:fullPath];
}

+ (UIImage*)imageNamed:(NSString*)name  theme:(NSString*)theme
{
    BOOL ispad = [UIDevice isPad];
    if ([name rangeOfString:@"/"].location == NSNotFound)
    {
        NSString *newName = [NSString stringWithFormat:@"Global/%@",name];
        UIImage *image = [self imageNamed:newName theme:theme isPad:ispad];
        if ( image == nil && ispad )
        {
            image = [self imageNamed:newName theme:theme isPad:NO];
        }
        if (image)
        {
            return image;
        }
    }
    UIImage *image = [self imageNamed:name theme:theme isPad:ispad];
    if ( image == nil && ispad )
    {
        image = [self imageNamed:name theme:theme isPad:NO];
    }
    return image;
}

- (void)refreshTextStyle
{
    @autoreleasepool {
        BOOL ispad = [UIDevice isPad];
        NSString *direction = [self imageDirection:ispad];
        NSString *boudlePath = [[NSBundle mainBundle]  bundlePath];
        NSString *fullPath = [NSString stringWithFormat:@"%@%@/%@",boudlePath,direction,KTextStyleFile];
        if ( ![HaloFileUtil fileExist:fullPath] && ispad )
        {
            direction = [self imageDirection:NO];
            fullPath = [NSString stringWithFormat:@"%@%@/%@",boudlePath,direction,KTextStyleFile];
        }
        
        NSString *fileString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
        if (!fileString){
            DDLogError( @"Error reading style file.");
        }
        NSScanner *scanner = [NSScanner scannerWithString:fileString];
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"\r;"]];
        
        NSString *name = nil, *color = nil, *shadowX = nil, *shadowY = nil, *shadowColor = nil;
        NSInteger line = 0;
        while ([scanner scanUpToString:@";" intoString:&name] && [scanner scanUpToString:@";" intoString:&color] && [scanner scanUpToString:@";" intoString:&shadowX] && [scanner scanUpToString:@";" intoString:&shadowY] && [scanner scanUpToString:@"\r" intoString:&shadowColor])
        {
            if (line == 0)
            {
                line++;
                continue;
            }
            if ( [name hasPrefix:@"#"] )
            {
                continue;
            }
            //        LOG_DEBUG(@"name:%@, color:%d, shadowX:%@, shadowY:%@:, shadowColor:%@", name, [color intValue], shadowX, shadowY, shadowColor);
            TextStyle *style = [[TextStyle alloc] init];
            style.shadowOffset = CGSizeMake([shadowX intValue], [shadowY intValue]);
            if (shadowColor.length>0)
            {
                NSInteger c = 0;
                sscanf([shadowColor UTF8String], "%x", &c);
                style.shadowColor = [UIColor colorWithRGBA:c];
            }
            NSInteger c = 0;
            sscanf([color UTF8String], "%x", &c);
            style.color = [UIColor colorWithRGBA:c];
            [self.textStyleDiction setObject:style forKey:name];
        }
    }
}
@end


@implementation HaloTheme
@synthesize currentThemeFolder;
@synthesize imageCache;
@synthesize themeDiction;
@synthesize imageCount;
@synthesize textStyleDiction;
@synthesize maxImageCacheCount;

SYNTHESIZE_ARC_SINGLETON_FOR_CLASS(HaloTheme)

#pragma mark -

- (id)init
{
	if ((self = [super init]))
	{
        self.imageCache = [[NSCache alloc] init];
		NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"themes.plist" ofType:nil inDirectory:nil];
		self.themeDiction = [NSDictionary dictionaryWithContentsOfFile:fullPath];
        self.textStyleDiction = [NSMutableDictionary dictionaryWithCapacity:10];
		imageCount = 0;
        [self refreshTextStyle];
        maxImageCacheCount = KMaxImageCacheCount;
        imageWeightArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)removeImageWeightByName:(NSString*)name
{
    @synchronized(self)
    {
        for (NSString *n in imageWeightArray )
        {
            if ( [n isEqualToString:name] )
            {
                [imageWeightArray removeObject:n];
                break;
            }
        }
    }
}

- (void)updateImageWeightByName:(NSString*)name
{
    @synchronized(self)
    {
        [self removeImageWeightByName:name];
        [imageWeightArray insertObject:name atIndex:0];
    }
}


- (void)removeImage:(NSString*)name
{
    [imageCache removeObjectForKey:name];
    [self removeImageWeightByName:name];
    imageCount--;
}

- (void)catchImage:(UIImage*)image forKey:(NSString*)name
{
    [imageCache setObject:image forKey:name];
    imageCount++;
}

- (UIImage *)loadImageByName:(NSString*)name
{
    UIImage *image = [imageCache objectForKey:name];
    if (!image)
	{
		image = [HaloTheme didImageNamed:name];
		if (image)
		{
            //[imageCache setObject:image forKey:name];
            [self catchImage:image forKey:name];
		}
	}
    if ( image != nil )
    {
        [self updateImageWeightByName:name];
    }
    else
    {
        DDLogError(@"Can not found image: %@",name);
    }
    return image;
}

- (UIImage*)loadImageByPath:(NSString*)path
{
    NSString *md5 = [path MD5String];
    UIImage *image = [imageCache objectForKey:md5];
    if (!image)
	{
		image = [HaloTheme didImageFromPath:[NSString stringWithFormat:@"%@.png",path]];
		if (image)
		{
			//[imageCache setObject:image forKey:md5];
            [self catchImage:image forKey:md5];
		}
	}
    if ( image != nil )
    {
        [self updateImageWeightByName:md5];
    }
	return image;
}



+ (UIImage*)imageNamed:(NSString*)name
{
    return [[HaloTheme sharedInstance] loadImageByName:name];
}

+ (UIImage*)imageNamed:(NSString*)name white:(BOOL)white
{
    if (white)
    {
        UIImage *mask = [HaloTheme imageNamed:name];
        return [mask imageWithColor:[UIColor whiteColor]];
    }
    else
    {
        return [HaloTheme imageNamed:name];
    }
}

+ (UIImage *)imagePathed:(NSString *)path
{
    return [[HaloTheme sharedInstance] loadImageByPath:path];
}

+ (TextStyle*)textStyle:(NSString*)name
{
    TextStyle *style = [[[HaloTheme sharedInstance] textStyleDiction] objectForKey:name];
    if (!style)
    {
        DDLogError( @"not found style: %@",name);
    }
    return style;
}

+ (NSDictionary *)textAttributes:(NSString *)name font:(UIFont *)font
{
    TextStyle *style = [self textStyle:name];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:4];
    dict[UITextAttributeFont] = font;
    dict[UITextAttributeTextColor] = style.color;
    dict[UITextAttributeTextShadowColor] = style.shadowColor;
    dict[UITextAttributeTextShadowOffset] = [NSValue valueWithCGSize:style.shadowOffset];
    return dict;
}

+ (UIImage*)defaultThumbnail
{
	return [HaloTheme imageNamed:@"default_thumbnail"];
}
+ (UIColor*)colorWithColorId:(NSString*)colorId
{
    TextStyle *style = [HaloTheme textStyle:colorId];
    if (!style)
    {
        DDLogError( @"not found style: %@",colorId);
    }
    return style.color;
}



- (NSArray*)allThemes
{
	
	NSInteger  themeCount = [[themeDiction objectForKey:@"KThemeCount"] intValue];
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:themeCount];
	for (int i = 0 ; i < themeCount; i++)
	{
		NSDictionary *dict = [themeDiction objectForKey:[NSString stringWithFormat:@"theme%d",i]];
		if (dict)
		{
            NSString *themeName = NSLocalizedStringFromTableInBundle([dict objectForKey:@"name"],@"Global",[Halo bundle],nil);
			[array addObject:themeName];
		}
	}
	return array;
	
}

- (NSString*)currentThemeFolder
{
	NSInteger activeThemeId = 0;//[[HaloUserDefault sharedInstance] intForKey:SETTING_KEY_THEME_ACTIVE defaultValue:EThemeIdNormal];
	if (!currentThemeFolder)
	{
		
		NSDictionary *dict = [themeDiction objectForKey:[NSString stringWithFormat:@"theme%d",activeThemeId]];
		if (dict)
		{
			currentThemeFolder = [dict objectForKey:@"path"];
		}
		else
		{
			currentThemeFolder = @"Default";
		}
	}
	return currentThemeFolder;
}

- (void)clearCache
{
	currentThemeFolder = nil;
    [imageCache removeAllObjects];
    imageCount = 0;
}

+ (UIImage *)appDefaultImage
{
    //4'
    if ([UIScreen mainScreen].bounds.size.height == 568)
    {
        return [HaloTheme imageNamed:@"Default-568h"];
    }
    else
    {
        return [HaloTheme imageNamed:@"Default"];
    }
}
@end