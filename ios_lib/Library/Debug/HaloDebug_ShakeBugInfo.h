//
//  ShakeBugInfo.h
//  ShackBug
//
//  Created by sub on 13-6-4.
//  Copyright (c) 2013年 Sub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HaloDebug_ShakeBugInfo : NSObject

@property (nonatomic,copy) NSString *summary;
@property (nonatomic,copy) NSString *desc;
@property (nonatomic,copy) NSString *email;
@property (nonatomic,assign) NSInteger projectId;
@property (nonatomic,assign) NSInteger reporterId;
@property (nonatomic,copy) NSString *attachmentPath;
@property (nonatomic,assign) NSInteger severity;


@end
