
#import "HaloUITabBar.h"
#import "HaloUITabBarItem.h"
#define KTabBagTag 0x110

@interface HaloUITabBar ()
@property (nonatomic,strong) UIImageView *bgView;
@property (nonatomic,strong) UIImageView *highlightView;
- (void)addShadowToBottomView;
- (void)createTabItems;
- (NSInteger)visibleTabCount;
@end

@implementation HaloUITabBar
- (id)initWithFrame:(CGRect)frame
{
    
	if ((self = [super initWithFrame:frame]))
	{
        self.contentInset = UIEdgeInsetsZero;
        _selectedTabIndex = -1;
	}
	return self;
}

- (void)setBgImage:(UIImage *)bgImage
{
    _bgImage = bgImage;
    if (!self.bgView)
    {
        self.bgView = [[UIImageView alloc] initWithImage:bgImage];
        [self addSubview:self.bgView];
    }
    else
    {
        self.bgView.image = bgImage;
    }
}

- (void)setHighlightImage:(UIImage *)highlightImage
{
    _highlightImage = highlightImage;
    if (!self.highlightView)
    {
        self.highlightView = [[UIImageView alloc] initWithImage:highlightImage];
        [self addSubview:self.highlightView];
    }
    else
    {
        self.highlightView.image = highlightImage;
    }
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    
    self.highlightView.left = [self bottomHighlightImageXAtIndex:self.selectedTabIndex];
    
	NSInteger button_x = 0;
    NSInteger buttonWidth = self.width/[self visibleTabCount];
	for (NSInteger i = 0; i<self.tabItemsArray.count; i++)
	{
        HaloTabBarItem* item = [self.tabItemsArray objectAtIndex:i];
		item.frame = CGRectMake(button_x, self.contentInset.top, buttonWidth, item.height);
		//[self addSubview:item];
		button_x += buttonWidth;
	}
    [self sendSubviewToBack:[self viewWithTag:KTabBagTag]];
}

- (void)setTabItemsArray:(NSMutableArray *)array
{
	if (_tabItemsArray != array)
	{
		_tabItemsArray = array;
		[self createTabItems];
	}
}

- (void)drawRect:(CGRect)rect
{
    [self.bgImage drawInRect:rect];	
}

- (void)addShadowToBottomView
{
	UIImage* image = [HaloTheme imageNamed:@"shadow_bottom"];
	if (image)
	{
		UIImageView* shadowView = [[UIImageView alloc] initWithImage:image];
		CGRect rect = CGRectMake(0, 0 - image.size.height, self.width, image.size.height);
		shadowView.frame = rect;
		[self addSubview:shadowView];
	}
}

- (void)createTabItems
{
	NSInteger itemCount = self.tabItemsArray.count;
    NSInteger width = self.width/itemCount;
    NSInteger height = self.height - self.contentInset.top - self.contentInset.bottom;
	for (HaloTabBarItem* item in self.tabItemsArray)
	{
        item.frame = CGRectMake(0.0, 0.0, width, height);
		
		[item addTarget:self action:@selector(touchDownAction:)forControlEvents:UIControlEventTouchDown];
		[item addTarget:self action:@selector(touchUpInsideAction:)forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:item];
	}
}

- (void)resetItem:(HaloTabBarItem *)item atIndex:(NSUInteger)index
{
    if (self.tabItemsArray.count > index)
    {
        HaloTabBarItem *old = [self.tabItemsArray objectAtIndex:index];
        CGSize size = old.size;
        [old removeFromSuperview];
        [self.tabItemsArray removeObjectAtIndex:index];
        [self.tabItemsArray insertObject:item atIndex:index];
        
        item.frame = CGRectMake(0.0, 0.0, size.width, size.height);
        [item addTarget:self action:@selector(touchDownAction:)forControlEvents:UIControlEventTouchDown];
        [item addTarget:self action:@selector(touchUpInsideAction:)forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:item];
        [self layoutSubviews];
    }
}

- (NSInteger)visibleTabCount
{
    return self.tabItemsArray.count ;
}

- (void)slideHighlightViewToIndex:(NSInteger)selectedIndex
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    self.highlightView.left = [self bottomHighlightImageXAtIndex:selectedIndex];
    [UIView commitAnimations];
}

- (void)dimAllButtonsExcept:(UIButton*)selectedButton
{
    HaloTabBarItem* item = (HaloTabBarItem*)selectedButton;
    item.selected = YES;
    item.highlighted = item.selected ? NO : YES;
    
    NSUInteger selectedIndex = [self.tabItemsArray indexOfObjectIdenticalTo:item];
    [self slideHighlightViewToIndex:selectedIndex];
    
    if(self.selectedTabIndex >= 0)
    {
        HaloTabBarItem* lastItem = [self.tabItemsArray objectAtIndex:self.selectedTabIndex];
        lastItem.selected = NO;
        lastItem.highlighted = item.selected ? NO : YES;
        [lastItem setNeedsDisplay];
    }    
    self.selectedTabIndex = selectedIndex;
    
    [item setNeedsDisplay];
}

- (void)touchDownAction:(UIButton*)button
{
    NSInteger selectedIndex = [self.tabItemsArray indexOfObject:button]; 
    BOOL ret = YES;
    if ( [self.delegate respondsToSelector:@selector(willTouchDownAtItemAtIndex:)] ) 
    {
        ret = [self.delegate willTouchDownAtItemAtIndex:selectedIndex];
    }
    if ( ret )
    {        
        if (selectedIndex != self.self.selectedTabIndex)
        {
            [self dimAllButtonsExcept:button];
        }
    }
    if ([self.delegate respondsToSelector:@selector(touchDownAtItemAtIndex:)])
    {
        [self.delegate touchDownAtItemAtIndex:selectedIndex];
    }
}

- (void)touchUpInsideAction:(UIButton*)button
{
    //[self dimAllButtonsExcept:button];
	
	if ([self.delegate respondsToSelector:@selector(touchUpInsideItemAtIndex:)])
		[self.delegate touchUpInsideItemAtIndex:[self.tabItemsArray indexOfObject:button]];
}

//- (void)otherTouchesAction:(UIButton*)button
//{
//	[self dimAllButtonsExcept:button];
//}

- (void)setSelectedTabIndex:(NSInteger)index
{
    if ( index < 0 || index >= self.tabItemsArray.count )
    {
        return;
    }
	self.highlightView.left = [self bottomHighlightImageXAtIndex:index];
    
    if (_selectedTabIndex == -1)
    {        
        UIButton* button = [self.tabItemsArray objectAtIndex:index];
        button.selected = YES;
        button.highlighted = button.selected ? NO : YES;
        [button setNeedsDisplay];
    }
    
    _selectedTabIndex = index;
}


- (CGFloat)bottomHighlightImageXAtIndex:(NSUInteger)tabIndex
{
	CGFloat tabItemWidth = self.frame.size.width / self.tabItemsArray.count;
	CGFloat halfTabItemWidth = (tabItemWidth / 2.0) - (self.highlightView.width / 2.0);
	return (tabIndex * tabItemWidth) + halfTabItemWidth;
}

- (void)setBadgeNumber:(NSInteger)number atIndex:(NSInteger)index
{
    HaloTabBarItem* item = (HaloTabBarItem*)[self.tabItemsArray objectAtIndex:index];
    item.badge = number;
}

- (void)setBadgeText:(NSString*)badgeText atIndex:(NSInteger)index
{
    HaloTabBarItem* item = (HaloTabBarItem*)[self.tabItemsArray objectAtIndex:index];
    [item setBadgeText:badgeText];
}

- (void)setBadgeImage:(UIImage *)image atIndex:(NSInteger)index
{
    HaloTabBarItem* item = (HaloTabBarItem*)[self.tabItemsArray objectAtIndex:index];
    [item setBadgeImage:image];
}

- (NSInteger)getBadgeNumberByIndex:(NSInteger)index
{
    NSInteger result = 0;
    if (index >= 0 && index < self.tabItemsArray.count)
    {
        HaloTabBarItem* item = [self.tabItemsArray objectAtIndex:index];
        result = item.badge;
    }
    return result;
}
- (void)setTabBackImage:(UIImage *)tabBg
{
    UIImageView *tab = (UIImageView *)[self viewWithTag:KTabBagTag];
    UIImage *tabBackImg = tabBg;
    if ( tabBackImg.size.width < 20 )
    {
        tabBackImg = [tabBackImg stretchableImageWithLeftCapWidth:ceil(tabBackImg.size.width/2) topCapHeight:ceil(tabBackImg.size.height/2)];
    }        
    tab.image = tabBackImg;
    tab.width = self.width;
    tab.height = tabBackImg.size.height;
    tab.top = self.height - tabBackImg.size.height;
}

- (void)setTabItemHighlightImage:(UIImage *)itemHighlighBg
{
    self.highlightView.image = itemHighlighBg;
    self.highlightView.frame =  CGRectMake(0, self.contentInset.top + (self.height - self.contentInset.top - self.contentInset.bottom - itemHighlighBg.size.height)/2, itemHighlighBg.size.width, itemHighlighBg.size.height);
}

- (HaloTabBarItem *)itemAtIndex:(NSInteger)index
{
    return [self.tabItemsArray objectAtIndex:index];
}
@end
