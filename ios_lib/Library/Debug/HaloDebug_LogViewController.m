//
//  HaloDebug_LogViewController.m
//  YConference
//
//  Created by  on 13-5-17.
//  Copyright (c) 2013年  Ltd., Co. All rights reserved.
//

#import "HaloDebug_LogViewController.h"

@interface HaloDebug_LogViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (nonatomic, strong)UILabel            *tempLabel;
@property (nonatomic, strong)UISearchBar        *searchBar;
@property(nonatomic, strong)NSTimer             *timer;
@property(nonatomic, assign)dispatch_queue_t    filterQueue;
@end

@implementation HaloDebug_LogViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        _logTextArray = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)loadView
{
    
    [super loadView];
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self createTableView:self];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self createSearchBar];
    
    self.tableView.top = self.searchBar.bottom;
    self.tableView.height -= self.searchBar.height;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.logTextArray.count > 6000)
    {
        [self.logTextArray removeObjectsInRange:NSMakeRange(0, self.logTextArray.count - 6000)];
    }
    
    self.dataSource = self.logTextArray;
    
    [self.tableView reloadData];
    
    if (self.logTextArray.count > 0)
    {
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.logTextArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    }
}

- (void)appendingLogText:(NSString *)newLogText;
{
    [self.logTextArray addObject:newLogText];
    if (self.logTextArray.count > 6000)
    {
        [self.logTextArray removeObjectsInRange:NSMakeRange(0, self.logTextArray.count - 6000)];
    }
    
    if (self.searchBar.text.length > 0)
    {
        NSPredicate *p = [self getPredictWithSearchText:self.searchBar.text];
        if ([p evaluateWithObject:newLogText])
        {
            [self.dataSource addObject:newLogText];
        }
    }
    
    if ([self isTopViewController])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
        
    }
    
}

- (void)createSearchBar
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 4*KGap)];
    searchBar.delegate = self;
    searchBar.backgroundColor = [UIColor clearColor];
    [[[searchBar subviews] objectAtIndex:0] removeFromSuperview];
    searchBar.placeholder = @"Filter";
    [self.view addSubview:searchBar];
    
    self.searchBar = searchBar;
    
}

#pragma mark- UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *logText = self.dataSource[indexPath.row];
    self.tempLabel.text = logText;
    CGSize size = [self.tempLabel sizeThatFits:CGSizeMake(tableView.width - 3*KGap, CGFLOAT_MAX)];
    self.tempLabel.text = nil;
    return size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"infoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.textLabel.backgroundColor = self.tableView.backgroundColor;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = NSLineBreakByWordWrapping;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //        cell.textLabel.layer.borderWidth = 1.f;
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (UILabel *)tempLabel
{
    if (!_tempLabel)
    {
        _tempLabel = [[UILabel alloc] init];
        _tempLabel.numberOfLines = 0;
        _tempLabel.font = [UIFont systemFontOfSize:12];
        _tempLabel.textAlignment = NSLineBreakByWordWrapping;
    }
    
    return _tempLabel;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText hasEmoji])
    {
        return;
    }
    NSString *searchStr = searchText;
    if (searchStr.length > 30)
    {
        searchStr = [searchStr substringToIndex:30];
    }
    [self doSearch:searchStr];
}

- (void)doSearch:(NSString *)searchText
{
    NSString *text = searchText;
    if (text.length == 0)
    {
        
        [self.timer invalidate];
        self.timer = nil;
        self.dataSource = self.logTextArray;
        
        [self.tableView reloadData];
        return;
    }
    
    //使用NSTimer
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(filterLog:) userInfo:text repeats:NO];
    
}

- (void)filterLog:(NSTimer *)timer
{
    NSString *text = timer.userInfo;
    if (!self.filterQueue)
    {
        dispatch_queue_t groupQueue = dispatch_queue_create("groupQueue", nil);
        self.filterQueue = groupQueue;
    }
    dispatch_async(self.filterQueue, ^{
        NSMutableArray *copyLogArray = [NSMutableArray arrayWithArray:self.logTextArray];
        
        NSPredicate *p = [self getPredictWithSearchText:text];;
        
        [copyLogArray filterUsingPredicate:p];
        
        self.dataSource = [NSMutableArray arrayWithArray:copyLogArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.searchBar.text.length == 0)
            {
                self.dataSource = self.logTextArray;
            }
            [self.tableView reloadData];
        });
    });
}

- (NSPredicate *)getPredictWithSearchText:(NSString *)text
{
    NSString *escapeKey = [text stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    escapeKey = [escapeKey stringByReplacingOccurrencesOfString:@"（" withString:@"("];
    escapeKey = [escapeKey stringByReplacingOccurrencesOfString:@"）" withString:@")"];
    
    NSString *str = [NSString stringWithFormat:@"*%@*",escapeKey];
    NSString *s = [NSString stringWithFormat:@"SELF like[cd] \"%@\"",str];
    NSPredicate *p = [NSPredicate predicateWithFormat:s];
    return p;
}

@end
