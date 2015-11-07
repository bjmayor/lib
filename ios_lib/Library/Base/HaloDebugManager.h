//
//  HaloDebugManager.h
//  HaloSlimFramework
//
//  Created by  on 13-5-27.
//
//

#import <Foundation/Foundation.h>
@interface HaloDebugManager : NSObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HaloDebugManager)

- (void)enableDebugTouchMap;

- (void)enableLogToFile;

- (void)enableLogDebugWithCustomLogFormat;

//Custom debug format
- (void)appendingLogText:(NSString *)string;
@end
