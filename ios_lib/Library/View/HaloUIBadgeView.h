#import <UIKit/UIKit.h>
@interface HaloUIBadgeView : UIView
{
    UIImage         *bgImage;
    UIImage         *bgImagePressed;
    NSString        *badgeText;
    UIColor         *badgeColor;
    UIColor         *badgeColorPressed;
    UIFont          *font;
    NSInteger       badge;
    UIEdgeInsets    _insets;
}
@property(nonatomic,retain)UIImage *bgImage UI_APPEARANCE_SELECTOR;
@property(nonatomic,retain)UIImage *bgImagePressed;
@property(nonatomic,copy) NSString *badgeText;
@property(nonatomic,retain)UIColor *badgeColor;
@property(nonatomic,retain)UIColor *badgeColorPressed;
@property(nonatomic,retain)UIFont *font;
@property(nonatomic)       NSInteger badge;
@property(nonatomic,assign)UIEdgeInsets insets;
@end
