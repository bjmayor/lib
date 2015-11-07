//
//  HaloUIStatusBarTip.h
//  HaloSlimFramework
//
//  Created by  on 13-7-6.
//
//

#import <UIKit/UIKit.h>

@interface HaloUIStatusBarTip : UIWindow
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HaloUIStatusBarTip)
@property (nonatomic,strong, readonly)UILabel *label;
- (void)show:(NSString *)tip;
- (void)show:(NSString *)tip delayHide:(NSInteger)delaySec;
- (void)hide;
@end
