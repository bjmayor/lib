//
//  SeetingTableCellBackgroudView.m
//  Foodgram
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "HaloUITableGroupCellBackgroundView.h"

@interface HaloUITableGroupCellBackgroundView()
@property (nonatomic,strong)UIColor *innerBackgroundColor;
@property (nonatomic)NSInteger roundSize;
@end

@implementation HaloUITableGroupCellBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [super setBackgroundColor:[UIColor clearColor]];
        self.roundSize = 3;
    }
    return self;
}

- (void)setLoc:(TableViewCellLocation)loc
{
    _loc = loc;
    [self setNeedsDisplay];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.innerBackgroundColor = backgroundColor;
}

- (void)drawRect:(CGRect)rect
{
    NSInteger lineWidth = 2.0f;
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, [self.innerBackgroundColor CGColor]);
    CGContextSetStrokeColorWithColor(c, [self.borderColor CGColor]);
    
    if ( _loc == EFirstCell )
    {
        CGContextFillRect(c, CGRectMake(0.0f, rect.size.height - self.roundSize, rect.size.width, self.roundSize));
        CGContextBeginPath(c);
        CGContextMoveToPoint(c, 0.0f, rect.size.height - self.roundSize);
        CGContextAddLineToPoint(c, 0.0f, rect.size.height);
        CGContextAddLineToPoint(c, rect.size.width, rect.size.height);
        CGContextAddLineToPoint(c, rect.size.width, rect.size.height - self.roundSize);
        CGContextSetLineWidth(c, lineWidth);
        CGContextStrokePath(c);
        CGContextClipToRect(c, CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height - self.roundSize));
    }
    else if ( _loc  == ELastCell)
    {
        CGContextFillRect(c, CGRectMake(0.0f, 0.0f, rect.size.width, self.roundSize));
        CGContextBeginPath(c);
        CGContextSetLineWidth(c, lineWidth);
        CGContextMoveToPoint(c, 0.0f, self.roundSize);
        CGContextAddLineToPoint(c, 0.0f, 0.0f);
        CGContextStrokePath(c);
        CGContextBeginPath(c);
        CGContextMoveToPoint(c, rect.size.width, 0.0f);
        CGContextAddLineToPoint(c, rect.size.width, self.roundSize);
        CGContextStrokePath(c);
        
        CGContextClipToRect(c, CGRectMake(0.0f, self.roundSize, rect.size.width, rect.size.height));
    }
    else if ( _loc == EMiddleCell )
    {
        CGContextFillRect(c, rect);
        CGContextBeginPath(c);
        CGContextSetLineWidth(c, lineWidth);
        CGContextMoveToPoint(c, 0.0f, 0.0f);
        CGContextAddLineToPoint(c, 0.0f, rect.size.height);
        CGContextAddLineToPoint(c, rect.size.width, rect.size.height);
        CGContextAddLineToPoint(c, rect.size.width, 0.0f);
        CGContextStrokePath(c);
         return; 
    }
    else
    {
        ;
    }
    // At this point the clip rect is set to only draw the appropriate
    // corners, so we fill and stroke a rounded rect taking the entire rect

    CGContextSetFillColorWithColor(c, [self.borderColor CGColor]);
    CGContextBeginPath(c);
    addRoundedRectToPath(c, rect, self.roundSize, self.roundSize);
    CGContextFillPath(c);
    
    rect.origin.y+=1;
    rect.origin.x+=1;
    rect.size.height-=2;
    rect.size.width-=2;
    CGContextSetFillColorWithColor(c, [self.innerBackgroundColor CGColor]);
    CGContextBeginPath(c);
    addRoundedRectToPath(c, rect, self.roundSize, self.roundSize);
    CGContextFillPath(c);
    
//    CGContextBeginPath(c);
//    CGContextSetLineWidth(c, lineWidth);
//    addRoundedRectToPath(c, rect, self.roundSize, self.roundSize);
//    CGContextStrokePath(c);

  
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect,
                                 float ovalWidth,float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);// 2
    CGContextTranslateCTM (context, CGRectGetMinX(rect),CGRectGetMinY(rect));// 3
    CGContextScaleCTM (context, ovalWidth, ovalHeight);// 4
    fw = CGRectGetWidth (rect) / ovalWidth;// 5
    fh = CGRectGetHeight (rect) / ovalHeight;// 6
    CGContextMoveToPoint(context, fw, fh/2); // 7
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);// 8
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);// 9
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);// 10
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // 11
    CGContextClosePath(context);// 12
    CGContextRestoreGState(context);// 13
}

@end


@implementation HaloUITableGroupCellBackgroundEmptyView
@end