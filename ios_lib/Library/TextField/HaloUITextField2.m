    //
//  YLTextFieldView.m
//  
//
//  Created by  on 10-11-28.
//  Copyright 2010  . All rights reserved.
//

#import "HaloUITextField2.h"


@implementation HaloUITextField2

- (id)initWithFrame:(CGRect)frame placeHolder:(NSString*)placeHolder keyboardType:(UIKeyboardType)keyboardType
{
	if ((self = [super initWithFrame:frame]))
	{
        self.placeholder = placeHolder;
        self.keyboardType = keyboardType;
	}
	return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds,KGap,0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds,KGap,0);
}
@end
