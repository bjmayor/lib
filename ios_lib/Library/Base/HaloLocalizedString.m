//
//  HaloLocalizedString.m
//
//  Created by  on 13-2-25.
//  Copyright (c) 2013年  Ltd., Co. All rights reserved.
//

#import "HaloLocalizedString.h"
NSString *HaloLocalizedLanguageChanged = @"HaloLocalizedLanguageChanged";

@interface NSBundle(Halo)
- (NSString *)override_localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName;
@end

@implementation NSBundle(Halo)

- (NSString *)override_localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
    return  [[HaloLocalizedString sharedInstance] localizedStringForKeyInBundle:self key:key value:value table:tableName];
}

@end

@interface HaloLocalizedString()
@property (nonatomic,strong) NSMutableDictionary *innerSupportedLanguages;
@end

@implementation HaloLocalizedString
@synthesize currentLanguage = _currentLanguage;
SYNTHESIZE_ARC_SINGLETON_FOR_CLASS(HaloLocalizedString)

- (id)init
{
    self = [super init];
    if (self)
    {
        self.innerSupportedLanguages = [NSMutableDictionary dictionary];
        
        Method origMethod = class_getInstanceMethod([NSBundle class], @selector(localizedStringForKey:value:table:));
        Method overrideMethod= class_getInstanceMethod([NSBundle class ], @selector(override_localizedStringForKey:value:table:));
        method_exchangeImplementations(origMethod,overrideMethod);
        
        
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *url = [[NSBundle mainBundle] resourceURL];
        NSError *error = nil;
        NSString *dir = [url path];
        NSArray *fileList = [fileManager contentsOfDirectoryAtPath:dir error:&error];
        BOOL isDir = NO;
        
        NSLocale *local = [[NSLocale alloc]initWithLocaleIdentifier:[Halo currentLanguage]];
        
        for (NSString *file in fileList)
        {
            NSString *path = [dir stringByAppendingPathComponent:file];
            [fileManager fileExistsAtPath:path isDirectory:(&isDir)];
            if (isDir && [[file pathExtension] isEqualToString:@"lproj"])
            {
                NSString *name = [file stringByDeletingPathExtension];
                NSString *lang = [local displayNameForKey: NSLocaleLanguageCode value:name];
                self.innerSupportedLanguages[name] = lang;
            }
            isDir = NO;
        }
    }
    return self;
}

- (void)setCurrentLanguage:(NSString *)currentLanguage
{
    if (![self.currentLanguage isEqualToString:currentLanguage])
    {
        BOOL isFirstSet = self.currentLanguage == nil;
        _currentLanguage = currentLanguage;
        
        if (![[NSBundle mainBundle] pathForResource:_currentLanguage ofType:@"lproj"])
        {
            DDLogWarn(@"Can not set current language to: %@",currentLanguage);
            //get app default language
            NSString *defaultStr = [[NSBundle mainBundle] developmentLocalization];
            NSString *languageStr = [NSLocale canonicalLanguageIdentifierFromString:defaultStr];
            
            if (languageStr)
            {
                _currentLanguage = languageStr;
            }
            else
            {
                NSAssert(false, @"Language can not be set.");
            }
        }

        DDLogInfo(@"Set current language to: %@",_currentLanguage);
        if (!isFirstSet)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:HaloLocalizedLanguageChanged object:nil];
        }
    }
}

- (NSString *)localizedStringForKeyInBundle:(NSBundle *)bundle key:(NSString *)key value:(NSString *)value table:(NSString *)table
{
    NSString *tempTable = @"Localizable";
    if (table)
    {
        tempTable = table;
    }
    
   
    NSString *path = [bundle pathForResource:self.currentLanguage ofType:@"lproj"];
    if (!path )
    {
        return  [bundle override_localizedStringForKey:key value:value table:table];
    }
    
    NSBundle *tempBundle = [NSBundle bundleWithPath:path];
    
    return [tempBundle override_localizedStringForKey:key value:value table:table];
    
}

- (NSDictionary *)supportedLanguages
{
    return self.innerSupportedLanguages;
}
@end
