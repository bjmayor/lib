//
//  OS.h
//  Hello World
//
//  Created by  on 13-5-19.
//  Copyright (c) 2013年 __Company__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OS : NSObject
+ (void)facetime:(NSString* )number;
+ (void)facetime:(NSString*)number confirm:(BOOL)confirm;
+ (void)call:(NSString* )phone confirm:(BOOL)confirm;
+ (void)call:(NSString*)phone;
+ (void)openMap:(NSString*)address;
+ (void)openSafari:(NSString* )url;
+ (BOOL)ipodPlaying;
+ (void)resumeIPod;
+ (void)setSoundToSpeaker:(BOOL)speaker;
+ (void)copyToPasteboard:(NSString *)text;
@end
