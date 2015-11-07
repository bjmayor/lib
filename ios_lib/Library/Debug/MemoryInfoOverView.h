//
//  MemoryInfoOverView.h
//  YContact
//
//  Created by li peiqiang on 12-8-23.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemoryInfoOverView : UIWindow
{
}
@property(nonatomic,retain)UILabel*  label;
+ (MemoryInfoOverView*)overView;
+ (unsigned int)get_free_memory;
@end
