//
//  HaloDebug_LogViewController.h
//  YConference
//
//  Created by  on 13-5-17.
//  Copyright (c) 2013年  Ltd., Co. All rights reserved.
//

#import "HaloUIViewController.h"

@interface HaloDebug_LogViewController : HaloUIViewController
@property(nonatomic, strong)NSMutableArray  *logTextArray;
- (void)appendingLogText:(NSString *)newLogText;
@end
