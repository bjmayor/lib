//
//  HaloTheme.h
//  
//
//  Created by lipq on 11-2-18.
//  Copyright 2011  . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextStyle : NSObject
@property(nonatomic,retain)UIColor*		color;
@property(nonatomic,retain)UIColor*		shadowColor;
@property(nonatomic)	   CGSize		shadowOffset;
//styleString
//color;shadowOffsetX;shadowOffsetY;shadowColor
+ (TextStyle *)textStyleByString:(NSString *)styleString;
+ (TextStyle *)textStyleByColor:(UIColor *)color shadowOffset:(CGSize)shadowOffset shadowColor:(UIColor *)shadowColor;

@end

@interface HaloTheme: NSObject
{
	NSCache                 *imageCache;
	NSDictionary            *themeDiction;
    NSMutableDictionary     *textStyleDiction;
	NSString                *currentThemeFolder;
    NSInteger                maxImageCacheCount;
}
@property(nonatomic,readonly)NSString          *currentThemeFolder;
@property(nonatomic,retain)NSCache *imageCache;
@property(nonatomic,retain)NSMutableDictionary *textStyleDiction;
@property(nonatomic,retain)NSDictionary        *themeDiction;
@property(nonatomic,assign)NSInteger maxImageCacheCount;
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HaloTheme)

+ (UIImage *)imageNamed:(NSString *)name;
+ (UIImage *)imageNamed:(NSString *)name white:(BOOL)white;
+ (UIImage *)imagePathed:(NSString *)path;
+ (TextStyle *)textStyle:(NSString*)name;
+ (NSDictionary *)textAttributes:(NSString *)name font:(UIFont *)font;
+ (UIImage *)defaultThumbnail;
+ (UIColor *)colorWithColorId:(NSString *)colorId;
- (NSArray *)allThemes;
- (void)clearCache;
+ (UIImage *)appDefaultImage;
@end

