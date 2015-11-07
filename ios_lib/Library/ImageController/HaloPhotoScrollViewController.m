//
//  HaloPhotoScrollViewController.m
//  YContact
//
//  Created by peiqiang li on 12-3-7.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "HaloPhotoScrollViewController.h"
#import "HaloImageView.h"
#import "ImageInfo.h"
#import "SDImageCache.h"
#import "HaloUIActionSheet.h"
#import "HaloUIAlertView.h"
#import "UIImageView+WebCache.h"
@interface HaloPhotoScrollViewController ()
{
    HaloImageView*          _currentImageView;
    UIStatusBarStyle        _originStatusBarStyle;
    HaloPageScrollView*     _pageScrollView;
    NSInteger               _currentPageIndex;
    UIToolbar*              _toolbar;
    UIBarButtonItem*        _naviRightButton;
    BOOL                    _toolbarVisible;
}
@property(nonatomic,strong)HaloImageView*  currentImageView;
- (void)toggleToolbar;
- (void)setToolbarVisibility:(BOOL)isVisible animated:(BOOL)animated;
- (void)setNaviRightButtonEnable:(BOOL)enable;
@end

@implementation HaloPhotoScrollViewController
@synthesize currentPageIndex = _currentPageIndex;
@synthesize hiddenToolbarWhenScroll = _hiddenToolbarWhenScroll;
@synthesize currentImageView = _currentImageView;
@synthesize delegate = _delegate;
@synthesize naviRightButtonType = _naviRightButtonType;
@synthesize naviRightButton = _naviRightButton;
@synthesize pageHorizontalMargin = _pageHorizontalMargin;
- (id)init
{
    self = [super init];
    if (self)
    {
        self.hiddenToolbarWhenScroll = YES;
        _toolbarVisible = YES;
        self.naviRightButtonType = ENaviRightSave;
        self.pageHorizontalMargin = KGap;
    }
    return self;
}

- (id)initWithUrl:(NSString*)imageUrl
{
    self = [self init];
    if (self)
    {
        ImageInfo* imgInfo = [[ImageInfo alloc] init];
        imgInfo.imageUrl = [NSURL URLWithString:imageUrl];
        self.dataSource = [NSMutableArray arrayWithObject:imgInfo];
    }
    return self;
}
- (id)initWithImage:(UIImage*)image
{
    self = [self init];
    if (self)
    {
        ImageInfo* imgInfo = [[ImageInfo alloc] init];
        imgInfo.image = image;
        self.dataSource = [NSMutableArray arrayWithObject:imgInfo];
    }
    return self;
}

- (id)initWithUrl:(NSString *)imageUrl placeHolderImage:(UIImage *)image;
{
    self = [self init];
    if (self)
    {
        ImageInfo* imgInfo = [[ImageInfo alloc] init];
        imgInfo.image = image;
        imgInfo.imageUrl = [NSURL URLWithString:imageUrl];
        self.dataSource = [NSMutableArray arrayWithObject:imgInfo];
    }
    return self;
}
- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    self.navigationController.navigationBarHidden = YES;
    self.wantsFullScreenLayout = YES;
    
    
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 20, self.view.width, 44)];
    _toolbar.barStyle = UIBarStyleBlack;
    _toolbar.translucent = YES;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(back)];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSMutableArray *items = nil;
    
    _naviRightButton = [self getRightNaviBtnFromDelegate];
    
    if (_naviRightButton == nil)
    {        
        switch (self.naviRightButtonType)
        {
            case ENaviRightSave:
                _naviRightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"save",@"Global", [Halo bundle] ,nil) style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
                [self setNaviRightButtonEnable:NO];
                items = [NSMutableArray arrayWithObjects:cancelButton, fixed,_naviRightButton,nil];
                break;
            case ENaviRightDelete:
                _naviRightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"delete", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(delete)];
                items = [NSMutableArray arrayWithObjects:cancelButton,fixed,_naviRightButton,nil];
                break;
            default:
                items = [NSMutableArray arrayWithObjects:cancelButton, fixed,nil];
                break;
        }
    }
    else
    {
        items = [NSMutableArray arrayWithObjects:cancelButton,fixed,_naviRightButton,nil];
    }
    
    
    
    if (self.pageCounterLabel)
    {
        self.pageCounterLabel.text = [NSString stringWithFormat:@"%d/%d",self.currentPageIndex + 1,self.dataSource.count];
        [self.pageCounterLabel sizeToFit];

        UIBarButtonItem *labelBtn = [[UIBarButtonItem alloc] initWithCustomView:self.pageCounterLabel];
        [items insertObjects:[NSArray arrayWithObjects:fixed,labelBtn, nil] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)]];
    }
    
    _toolbar.items = items;
    
        
    CGRect rect = [UIScreen mainScreen].bounds;
    _pageScrollView = [[HaloPageScrollView alloc] initWithFrame:rect];
    _pageScrollView.pageHorizontalMargin = self.pageHorizontalMargin;
    _pageScrollView.delegate = self;
    _pageScrollView.dataSource = self;
    [self.view addSubview:_pageScrollView];
    [_pageScrollView setCurrentPageIndex:self.currentPageIndex animated:NO];
    [_pageScrollView reloadData];

    
    
    [self.view addSubview:_toolbar];
}

- (void)enableCounterLabel
{
    self.pageCounterLabel = [[UILabel alloc] init];
    self.pageCounterLabel.textColor = [UIColor whiteColor];
    self.pageCounterLabel.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:_originStatusBarStyle];
}
#pragma mark HaloPageScrollDataSource
- (UIView<HaloPageView>*)pageViewAtIndex:(NSInteger)index
{
    ImageInfo*   imgInfo = [self.dataSource objectAtIndex:index];
    static NSString*  reusableIdentifier = @"imageView";
    HaloImageView*  imageView = [_pageScrollView  dequeueReusableViewWithIdentifier:reusableIdentifier];
    if (!imageView)
    {
        imageView = [[HaloImageView alloc] initWithFrame:self.view.bounds];
        imageView.reuseIdentifier = reusableIdentifier;
    }
    imageView.imageDelegate = self;

    if(imgInfo.image)
    {
        [imageView displayImage:imgInfo.image];
        [self setNaviRightButtonEnable:YES];
    }
    else if([imgInfo.imageUrl absoluteString].length > 0)
    {
        UIImage* placeHolder = nil;
        if ([imgInfo.thumbnailUrl absoluteString].length > 0)
        {
            if ([imgInfo.thumbnailUrl isFileURL])
            {
                NSData *data = [NSData dataWithContentsOfFile:[imgInfo.thumbnailUrl path]];
                placeHolder = [UIImage imageWithData:data];
            }
            else
            {
                placeHolder = [[SDImageCache sharedImageCache] imageFromKey:[imgInfo.thumbnailUrl absoluteString]];
            }
            
        }
        
        [imageView displayImage:placeHolder];
        if (![imgInfo.imageUrl isFileURL])
        {
            [imageView.indicatorView startAnimating];
            __weak HaloImageView *weakImgView = imageView;
            [imageView.imageView setImageWithURL:[NSURL URLWithString:[imgInfo.imageUrl absoluteString]] placeholderImage:placeHolder success:^(UIImage *image,BOOL cache) {
                HaloImageView *strongImgView = weakImgView;
                [self setNaviRightButtonEnable:YES];
                [strongImgView.indicatorView stopAnimating];
                [strongImgView displayImage:image];
            } failure:nil];            
        }
        
    }
    return imageView;
}
- (NSInteger)numberOfPages
{
    return self.dataSource.count;
}

#pragma mark rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}


#pragma mark  HaloPageScrollDelegate
- (void)pageScrollView:(HaloPageScrollView*)pageScroll  didScrollToIndex:(NSInteger)index
{
    [self updatePromptText:index];
    self.currentPageIndex = index;
}
- (void)pageScrollViewDidScroll:(HaloPageScrollView *)pageScroll
{
    if(self.hiddenToolbarWhenScroll)
    {
        [self setToolbarVisibility:NO  animated:YES];
    }
}

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
    _currentPageIndex = currentPageIndex;
    if(self.pageCounterLabel)
    {
        self.pageCounterLabel.text = [NSString stringWithFormat:@"%d/%d",self.currentPageIndex + 1,self.dataSource.count];
        [self.pageCounterLabel sizeToFit];
    }
}

#pragma mark 
- (void)setToolbarVisibility:(BOOL)isVisible animated:(BOOL)animated
{
    CGFloat  duration = 0;
    if (animated)
    {
        duration = 0.5;
    }
    [UIView animateWithDuration:duration animations:^{
        if (isVisible)
        {
            _toolbar.alpha = 1.0f;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }
        else 
        {
            _toolbar.alpha = 0.0f;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }
    } completion:^(BOOL finished) {
        _toolbarVisible = isVisible;
    }];
}

- (void)setNaviRightButtonEnable:(BOOL)enable
{
    if (self.naviRightButtonType == ENaviRightSave)
    {
        self.naviRightButton.enabled = enable;
    }
}

- (void)toggleToolbar
{
    [self setToolbarVisibility:!_toolbarVisible animated:YES];
}
- (void)updatePromptText:(NSInteger)page
{
}

- (void)singleTap
{
    [self setToolbarVisibility:!_toolbarVisible animated:YES];
}

- (void)save:(UIBarButtonItem *)btn
{   
    btn.enabled = NO;
    HaloImageView*  imageView = (HaloImageView*)[_pageScrollView currentView];
    if (imageView.imageView.image)
    {
        UIImageWriteToSavedPhotosAlbum(imageView.imageView.image,self,@selector(image:didFinishSavingWithError:contextInfo:),nil ) ; 
    }
}

- (void)delete
{
    __weak HaloPhotoScrollViewController *weakSelf = self;
    if ([self.delegate respondsToSelector:@selector(didDeleteImage:)])
    {
        
        HaloPhotoScrollViewController *strongSelf = weakSelf;

        HaloUIActionSheet *actionSheet = [[HaloUIActionSheet alloc] initWithTitle:nil cancelButtonTitle:NSLocalizedStringFromTableInBundle(@"cancel", @"Global", [Halo bundle], nil)];
        [actionSheet addItemWithTitle:NSLocalizedStringFromTableInBundle(@"delete", @"Global", [Halo bundle],nil) isRed:YES block:^{
            [strongSelf.delegate didDeleteImage:strongSelf];
            [strongSelf back];
        }];
        [actionSheet show];                                              
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self setNaviRightButtonEnable:YES];
    if ( error == nil )
    {
        [HaloUIAlertView showAlertWithMessage: NSLocalizedStringFromTableInBundle(@"save_completion", @"Global", [Halo bundle], nil) ];
    }
    else
    {
        [HaloUIAlertView showAlertWithMessage:[error localizedDescription]];
    }
}

- (UIBarButtonItem *)getRightNaviBtnFromDelegate
{
    if ([self.delegate respondsToSelector:@selector(setPhotoNaviRightButton)])
    {
        return  [self.delegate setPhotoNaviRightButton];
    }
    return nil;
}


@end
