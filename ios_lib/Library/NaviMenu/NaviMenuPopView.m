//
//  NaviMenuPopView.m
//  YContact
//
//  Created by 捷 邹 on 12-5-12.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "NaviMenuPopView.h"
#import "NaviMenuPopMenuCellCell.h"

NSString *NotificationPopMenuWillAppear = @"NotificationPopMenuWillAppear";
NSString *NotificationPopMenuWillDisapper = @"NotificationPopMenuWillDisapper";

@interface NaviMenuPopView ()
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSArray *sectionArray;
@property(nonatomic, strong)UIButton    *topNaviBtn;
@property (nonatomic, strong)NSMutableArray *selectedItems;
@property (nonatomic, assign)CGFloat    topLine;
@property(nonatomic, assign)BOOL mutipleSelect;
@end

@implementation NaviMenuPopView
- (id)initWithTop:(CGFloat)top singleSection:(NSArray*)array
{
    return [self initWithTop:top itemsSectionArray:[NSArray arrayWithObject:array]];
}
- (id)initWithTop:(CGFloat)top itemsSectionArray:(NSArray *)sectionArray
{
    UIScreen *screen = [UIScreen mainScreen];
    self = [super initWithFrame:CGRectMake(0, top, screen.bounds.size.width, screen.bounds.size.height)];
    if (self)
    {
        self.itemHeight = 44;
        self.topLine = top;
        self.backgroundColor = [UIColor clearColor];
        self.sectionArray = sectionArray;
        NSInteger count = 0;
        NSInteger countMax = 9;
        for (NSArray *subArray in sectionArray)
        {
            count += subArray.count;
        }
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0 , 0, self.width, (sectionArray.count-1) * [self getSepratorCellheight] + (count > countMax ? countMax : count)*self.itemHeight)];
        self.tableView.scrollEnabled = count > countMax;
        self.tableView.bounces = NO;
        self.tableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.tableView];
        
        BOOL find = NO;
        for (NSInteger i = 0; i < self.sectionArray.count; i++)
        {
            for (NSInteger j = 0; j < ((NSArray *)self.sectionArray[i]).count; j++)
            {
                NaviMenuPopMenuItem *item = self.sectionArray[i][j];
                if (item.needMark)
                {
                    [self.selectedItems addObject: [NSIndexPath indexPathForRow:j inSection:i]];
                    find = YES;
                    break;
                }
                if (find)
                {
                    break;
                }
            }
        }
    }
    return self;
}

- (void)showInView:(UIView *)view
{
    UIView *naviTitle = nil;
    for (UIView *v in view.subviews) 
    {
        if ([v isKindOfClass:[NaviMenuPopView class]])
        {
            NaviMenuPopView *naviPop = (NaviMenuPopView *)v;
            [naviPop dismissPopView];
            return;
        }
        if ([v isKindOfClass:[UINavigationBar class]])
        {
            naviTitle = v;
        }
    }
    
    self.top = self.topLine;
    self.top -= self.tableView.height;
    self.height += self.tableView.height;
    
    [view insertSubview:self belowSubview:naviTitle];
    
    self.topNaviBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.topNaviBtn.backgroundColor = [UIColor clearColor];
    [self.topNaviBtn addTarget:self action:@selector(dismissPopView) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.topNaviBtn];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationPopMenuWillAppear object:nil];
    [UIView animateWithDuration:0.2f animations:^{
        self.backgroundColor = [UIColor colorWithRGBA:0x000000AA];
        self.top += self.tableView.height;
    } completion:^(BOOL finished) {
        UIScreen *screen = [UIScreen mainScreen];
        self.topNaviBtn.frame = CGRectMake(0, self.top - 100, screen.bounds.size.width, 100);
    }];
}

- (void)dismissPopView
{
    self.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationPopMenuWillDisapper object:nil];
    [UIView animateWithDuration:0.2f animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.bottom = 0;
    } completion:^(BOOL finished) {
        [self.topNaviBtn removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)dismissPopView:(void(^)(void))finishBlock
{
    self.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationPopMenuWillDisapper object:nil];
    [UIView animateWithDuration:0.2f animations:^{
        self.bottom = 0;
    } completion:^(BOOL finished) {
        [self.topNaviBtn removeFromSuperview];
        [self removeFromSuperview];
        if (finishBlock)
        {
            finishBlock();
        }
    }];
}
#pragma mark -
#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *subSection = [self.sectionArray objectAtIndex:section];
    if ([self isLastSection:section])
    {
        return subSection.count;
    }
    else
    {
        return subSection.count + 1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([self isSepratorCell:indexPath])
    {
        return [self getSepratorCellheight];
    }
    else
    {
        return self.itemHeight;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isSepratorCell:indexPath])
    {
        static NSString *identifier2 = @"SepCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2];
            
            UIImageView *bgView = [[UIImageView alloc] initWithImage:[self sectionSepratorImage]];
            bgView.height += KGap/2;
            bgView.width = tableView.width;
            [cell addSubview:bgView];
        }
        return cell;
    }
    else
    {        
        static NSString *identifier = @"BaseCell";
        NaviMenuPopMenuCellCell *cell = (NaviMenuPopMenuCellCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell)
        {
            cell = [[NaviMenuPopMenuCellCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        NSArray *subArray = [self.sectionArray objectAtIndex:indexPath.section];
        NaviMenuPopMenuItem *item = [subArray objectAtIndex:indexPath.row];
        cell.nameLabel.text = item.title;
        if (item.icon || item.iconHighLight)
        {
            if ([self isSelected:indexPath])
            {
                cell.iconImageView.image = item.iconHighLight;
            }
            else
            {
                cell.iconImageView.image = item.icon;
            }
        }
        if (indexPath.row == subArray.count - 1)
        {
            [cell disableSeparator];
        }
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *subArray = [self.sectionArray objectAtIndex:indexPath.section];
    NaviMenuPopMenuItem *item = [subArray objectAtIndex:indexPath.row];
    if (![self isSelected:indexPath] && item.needMark)
    {
        if (!self.mutipleSelect)
        {
            [self.selectedItems removeAllObjects];
        }
        [self.selectedItems addObject:indexPath];
        
    }
    else
    {
        if (self.mutipleSelect)
        {
            [self.selectedItems removeObject:indexPath];
        }
    }
    [self.tableView reloadData];
    
    [self dismissPopView];
    
    item.block();
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissPopView];
}

- (BOOL)isSelected:(NSIndexPath *)indexPath
{
    if ([self.selectedItems containsObject:indexPath])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSMutableArray *)selectedItems
{
    if (!_selectedItems)
    {
        _selectedItems = [NSMutableArray array];
    }
    return _selectedItems;
}

- (BOOL)isLastSection:(NSInteger)section
{
    return section == self.sectionArray.count - 1;
}

- (BOOL)isSepratorCell:(NSIndexPath *)indexPath;
{
    if (![self isLastSection:indexPath.section])
    {        
        NSArray *subSection = [self.sectionArray objectAtIndex:indexPath.section];
        return indexPath.row == subSection.count;
    }
    return NO;
}


- (CGFloat)getSepratorCellheight
{
    return self.sectionSepratorImage.size.height + KGap/2;
}

- (void)dealloc
{
    
}
@end
