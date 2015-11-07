//
//  NSDictionary+SubscriptingSupport.h
//  YConference
//
//  Created by Zchin Hsu on 12-9-11.
//  Copyright (c) 2012年  Ltd., Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SubscriptingSupport)
- (id)objectForKeyedSubscript:(id)key;
@end
