//
//  CaptureImageManager.h
//  ShackBug
//
//  Created by sub on 13-5-30.
//  Copyright (c) 2013年 Sub. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "HaloDebug_ShakeBugInfo.h"

typedef void(^ClearBlock)(void);
typedef void (^FinishBlock)(HaloDebug_ShakeBugInfo *shakeBugInfo,ClearBlock clearBlock);

@interface HaloDebug_ShakeBugManager : NSObject<UIActionSheetDelegate>

@property (nonatomic,assign)Boolean hasCaptureImage;
@property (nonatomic,strong)UIImage *capturedimage;
@property (nonatomic,copy)FinishBlock finishBlock;
@property (nonatomic,copy)NSString *imagePath;
@property (nonatomic,assign)NSInteger projectId;
@property (nonatomic,assign)NSInteger reporterId;

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HaloDebug_ShakeBugManager)

- (void)captureImage;

- (void)resetManager;

- (void)setFinishBlock:(FinishBlock)finishBlock;

-(NSString *)obtainEmailStr;

@end
