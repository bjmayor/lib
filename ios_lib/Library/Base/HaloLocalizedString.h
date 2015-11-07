//
//  HaloLocalizedString.h
//
//  Created by  on 13-2-25.
//  Copyright (c) 2013年  Ltd., Co. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *HaloLocalizedLanguageChanged;
@interface HaloLocalizedString : NSObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HaloLocalizedString)
@property (nonatomic,strong) NSString *currentLanguage;

- (NSDictionary *)supportedLanguages;
- (NSString *)localizedStringForKeyInBundle:(NSBundle *)bundle key:(NSString *)key value:(NSString *)value table:(NSString *)table;
@end