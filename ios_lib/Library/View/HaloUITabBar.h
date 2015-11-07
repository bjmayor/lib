

#import "HaloTheme.h"
#import "HaloUITabBarItem.h"

@class HaloUITabBar;

@protocol HaloUITabBarDelegate<NSObject>
@optional
- (void)touchUpInsideItemAtIndex:(NSUInteger)itemIndex;
- (void)touchDownAtItemAtIndex:(NSUInteger)itemIndex;
- (BOOL)willTouchDownAtItemAtIndex:(NSUInteger)itemIndex;
@end


@interface HaloUITabBar : UIView
@property (nonatomic, strong)NSMutableArray*				tabItemsArray;
@property (nonatomic, weak)id<HaloUITabBarDelegate>	delegate;
@property (nonatomic, assign)NSInteger                     selectedTabIndex;
@property (nonatomic, assign)UIEdgeInsets                  contentInset;

@property (nonatomic, strong)UIImage*						bgImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong)UIImage*						highlightImage UI_APPEARANCE_SELECTOR;

- (id)initWithFrame:(CGRect)frame;
- (CGFloat)bottomHighlightImageXAtIndex:(NSUInteger)tabIndex;
- (void)setBadgeNumber:(NSInteger)number atIndex:(NSInteger)index;
- (void)setBadgeText:(NSString*)bageText atIndex:(NSInteger)index;
- (void)setBadgeImage:(UIImage *)image atIndex:(NSInteger)index;
- (NSInteger)getBadgeNumberByIndex:(NSInteger)index;
- (void)resetItem:(HaloTabBarItem *)item atIndex:(NSUInteger)index;
- (void)setTabBackImage:(UIImage *)tabBg;
- (void)setTabItemHighlightImage:(UIImage *)itemHighlighBg;
- (HaloTabBarItem *)itemAtIndex:(NSInteger)index;
@end
