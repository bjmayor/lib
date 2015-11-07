#import "HaloUIBadgeView.h"
@implementation HaloUIBadgeView
@synthesize bgImage;
@synthesize bgImagePressed;
@synthesize badgeText;
@synthesize badgeColor;
@synthesize badgeColorPressed;
@synthesize font;
//@synthesize highlighted;
@synthesize badge;
@synthesize insets = _insets;
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.badgeColor = [UIColor whiteColor];
        self.badgeColorPressed = [UIColor grayColor];       
        self.backgroundColor = [UIColor clearColor];
//        UIImage *badgeBgImage = [HaloTheme imageNamed:@"Halo/badge_bg"];
//        badgeBgImage = [badgeBgImage stretchableImageWithLeftCapWidth:badgeBgImage.size.width/2 topCapHeight:badgeBgImage.size.height];
//        self.bgImage = badgeBgImage;
        self.font = [UIFont systemFontOfSize:12];
        self.userInteractionEnabled = NO;
        self.insets = UIEdgeInsetsMake(2, 2, 2, 2);
        self.badgeColor = [UIColor whiteColor];
    }
    return  self;
}

-(void)drawRect:(CGRect)rect
{
    if ([self.badgeText length]>0) 
    {
        CGSize textSize = [self.badgeText sizeWithFont:font];
        [self.bgImage drawInRect:rect];
        [self.badgeColor set];
        CGRect textRect = CGRectMake(self.insets.left, self.insets.top, rect.size.width - self.insets.left - self.insets.right, rect.size.height - self.insets.top - self.insets.bottom);
        textRect.origin.y = textRect.origin.y + ceil(textRect.size.height - textSize.height)/2;
        [self.badgeText drawInRect:textRect withFont:self.font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }
}


-(void)setBadgeText:(NSString *)text
{
    badgeText = text;
    
    CGSize textSize = [text sizeWithFont:self.font];
    CGRect rect = CGRectZero;
    rect.size.width = textSize.width + self.insets.left + self.insets.right;
    if (rect.size.width < self.bgImage.size.width)
    {
        rect.size.width = self.bgImage.size.width;
    }
    rect.size.height = textSize.height + self.insets.top + self.insets.bottom;
    if (rect.size.height < self.bgImage.size.height)
    {
        rect.size.height = self.bgImage.size.height;
    }
    rect.size.width = (rect.size.width < rect.size.height) ? rect.size.height : rect.size.width;
    self.frame = CGRectMake(self.left, self.top, rect.size.width, rect.size.height);
    [self setNeedsDisplay];
}

- (void)setBadge:(NSInteger)b
{
    badge = b;
    NSString *text = @"";
    if (badge > 99)
    {
        text = [NSString stringWithFormat:@"%d+", 99];
    }
    else if(badge > 0)
    {
        text = [NSString stringWithFormat:@"%d", badge];
    }
    self.badgeText = text;
}
@end
