//
//  HaloDebug_CustomFormatter.h
//  YConference
//
//  Created by  on 13-5-17.
//  Copyright (c) 2013年  Ltd., Co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"
@interface HaloDebug_CustomFormatter : NSObject<DDLogFormatter>
{
    NSDateFormatter *dateFormatter;
}
@end
