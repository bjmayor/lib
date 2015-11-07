//
//  HaloUIStatusBarTip.m
//  HaloSlimFramework
//
//  Created by  on 13-7-6.
//
//

#import "HaloUIStatusBarTip.h"
@interface HaloUIStatusBarTip()
@property (nonatomic,strong) NSTimer *timer;
@end
@implementation HaloUIStatusBarTip
SYNTHESIZE_ARC_SINGLETON_FOR_CLASS(HaloUIStatusBarTip)
- (id)init
{
    CGRect rect = [UIApplication sharedApplication].statusBarFrame;
    self = [super initWithFrame:rect];
    if (self)
    {
        self.windowLevel = UIWindowLevelStatusBar;
        self.backgroundColor = [UIColor blackColor];
        
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.font = [UIFont systemFontOfSize:14];
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.numberOfLines = 1;
        _label.backgroundColor = self.backgroundColor;
        [self addSubview:_label];
    }
    return self;
}

- (void)show:(NSString *)tip
{
    if (self.hidden)
    {
        self.label.text = tip;
        self.hidden = NO;
        self.alpha = 0;
        [UIView animateWithDuration:0.2f animations:^{
            self.alpha = 1;
        }];
    }
    else
    {
        self.label.alpha = 1;
        [UIView animateWithDuration:0.2f animations:^{
            self.label.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2f animations:^{
                self.label.text = tip;
                self.label.alpha = 1;
            }];
        }];
    }
}

- (void)show:(NSString *)tip delayHide:(NSInteger)delaySec
{
    [self show:tip];
    
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:delaySec target:self selector:@selector(hide) userInfo:nil repeats:NO];
}

- (void)hide
{
    self.alpha = 1;
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}
@end
