//
//  BugDetailViewController.m
//  ShackBug
//
//  Created by sub on 13-5-31.
//  Copyright (c) 2013年 Sub. All rights reserved.
//

#import "HaloDebug_ShakeBugViewController.h"
#import "HaloDebug_ShakeBugManager.h"
#import <QuartzCore/QuartzCore.h>
#import "HaloDebug_ShakeBugInfo.h"
//#import "HaloPhotoScrollViewController.h"
#import "UIDeviceExt.h"


#define     KHeaderHeight           30.0f
#define     KTextHeight             44.0f
#define     KTextViewHeight         71.0f
#define     KSummaryTextViewTag     20001
#define     KEmailTextViewTag       20002
#define     KEmailTextFieldTag      20003
#define     KImageViewTag           20004
#define     KImageSwitchViewTag     20005
#define     KMaxSummryLength        150
#define     KMaxDescriptionLength   150

typedef enum {
    ESectionSummary,
    ESectionDesc,
    ESectionEmail,
    ESectionImage,
    ESectionCount
}SectionType;

@interface HaloDebug_ShakeBugViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,copy)NSString *summary;
@property (nonatomic,copy)NSString *desc;
@property (nonatomic,copy)NSString *email;
@property (nonatomic,assign)bool isSendImage;
@property (nonatomic,assign)CGFloat keyboardHeight;
@property (nonatomic,strong)UIView *firstTextView;
@property (nonatomic,copy)ClearBlock clearBlock;
@end

@implementation HaloDebug_ShakeBugViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self createGroupedTableView:self];
    self.title = NSLocalizedStringFromTable(@"shake_bug_title", @"Other", @"shake bug 界面的title");
    
    UIButton *doneBtn = self.rightNaviButton ? self.rightNaviButton :[UIButton button:NSLocalizedStringFromTable(@"shake_bug_send", @"Other", @"shake bug 界面的title") font:[UIFont systemFontOfSize:16] image:nil highLightImage:nil];
    [doneBtn addTarget:self action:@selector(tapSaveMessage) forControlEvents:UIControlEventTouchUpInside];
    doneBtn.enabled = NO;
    [self setRightNaviButton:doneBtn];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)back
{
    [[HaloDebug_ShakeBugManager sharedInstance] resetManager];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)tapSaveMessage
{
    [self.firstTextView resignFirstResponder];
    if (self.summary.length > 0 && self.desc.length > 0)
    {
        
        HaloDebug_ShakeBugInfo *shakeBugInfo = [[HaloDebug_ShakeBugInfo alloc]init];
        
        shakeBugInfo.summary = self.summary.length > KMaxSummryLength ? [self.summary substringToIndex:KMaxSummryLength] : self.summary;
        shakeBugInfo.desc = self.desc.length > KMaxDescriptionLength ? [self.desc substringToIndex:KMaxSummryLength] : self.desc;
        if (self.email.length >0)
        {
            shakeBugInfo.email= self.email;
        }
        
        shakeBugInfo.projectId= [HaloDebug_ShakeBugManager sharedInstance].projectId;
        shakeBugInfo.reporterId= [HaloDebug_ShakeBugManager sharedInstance].reporterId;
        
        if (self.isSendImage)
        {
            shakeBugInfo.attachmentPath = [HaloDebug_ShakeBugManager sharedInstance].imagePath;
        }
        else
        {
            shakeBugInfo.attachmentPath = nil;
        }
//        [[HaloDebug_ShakeBugManager sharedInstance]StoreMessage:shakeBugInfo];
        self.finishBLock(shakeBugInfo , ^{
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if (shakeBugInfo.email >0)
            {
                [userDefaults setObject:shakeBugInfo.email forKey:@"reporter_email"];
                [userDefaults synchronize];
            }
            [self showInfoView:NSLocalizedStringFromTable(@"thank_report", @"Other", @"shake bug的谢谢反馈")];
            
            [self delayBack:1];
        });
    }
}

- (void)switchAction:(id) sender
{
    UISwitch *switchTemp = (UISwitch *)sender;
    self.isSendImage = switchTemp.on;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.keyboardHeight =keyboardSize.height;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.30f animations:^{
        [self.firstTextView resignFirstResponder];
    }];
}
- (void)handleKeyboardUserInfo
{
    CGRect textFieldframe = [self.firstTextView.superview convertRect:self.firstTextView.frame toView:self.view];
    CGRect aRect = self.view.frame;
    aRect.size.height -= self.keyboardHeight;
    if (!CGRectContainsRect(aRect, textFieldframe))
    {
        [UIView animateWithDuration:0.3f animations:^{
            CGFloat y = self.tableView.contentOffset.y + textFieldframe.origin.y+textFieldframe.size.height+self.keyboardHeight - self.view.frame.size.height+KGap *4;
            if (y < 0)
            {
                y = 0;
            }
            CGPoint scrollPoint = CGPointMake(0.0, y);
            [self.tableView setContentOffset:scrollPoint animated:NO];
        }];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (UITextView *)createTextView
{
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width- KGap*2, KTextViewHeight)];
    textView.font = [UIFont systemFontOfSize:16];
    textView.backgroundColor = [UIColor clearColor];
    textView.delegate = self;
    return textView;
}


#pragma mark  - Table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ESectionCount;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == ESectionImage)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    if (indexPath.section ==ESectionSummary ||indexPath.section == ESectionDesc)
    {
        static NSString *cellIdentifier = @"textViewCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextView *textView = [self createTextView];
            textView.tag = KSummaryTextViewTag;
            
            if (indexPath.section == ESectionDesc)
            {
                self.desc = [NSString stringWithFormat:@"%@%@ (%@, %d) ",NSLocalizedStringFromTable(@"version", @"Other", @"shake bug 版本信息title"),
                                       [[UIDevice currentDevice] platform],[[UIDevice currentDevice] systemVersion],[UIDevice isJailbroken]];
            }
            [cell.contentView addSubview:textView];
        }
        
        if ([cell.contentView viewWithTag:KSummaryTextViewTag]!=nil)
        {
            
            if (indexPath.section == ESectionSummary)
            {
                ((UITextView *)[cell.contentView viewWithTag:KSummaryTextViewTag]).text =self.summary;
            }
            else if (indexPath.section == ESectionDesc)
            {
                ((UITextView *)[cell.contentView viewWithTag:KSummaryTextViewTag]).text =self.desc;
            }
        }
    }
    else if (indexPath.section ==ESectionEmail)
    {
        static NSString *cellIdentifier = @"textFieldCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell ==nil)
        {
            cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *emailTextField =[[UITextField alloc]initWithFrame:CGRectMake(KGap, 0, cell.frame.size.width- KGap*3, KTextHeight)];
            emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
            emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            emailTextField.font = [UIFont systemFontOfSize:16];
            emailTextField.delegate = self;
            emailTextField.tag = KEmailTextFieldTag;
            self.email = [[HaloDebug_ShakeBugManager sharedInstance]obtainEmailStr];
            emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
            [cell.contentView addSubview:emailTextField];
        }
        if ([cell.contentView viewWithTag:KEmailTextFieldTag]!=nil)
        {
            ((UITextField *)[cell.contentView viewWithTag:KEmailTextFieldTag]).text =self.email;
        }
    }
    else if (indexPath.section ==ESectionImage)
    {
        if (indexPath.row == 0)
        {
            static NSString *cellIdentifier = @"switchCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil)
            {
                cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.text = NSLocalizedStringFromTable(@"add_image_switch", @"Other", nil);
                cell.textLabel.font = [UIFont systemFontOfSize:16];
                UISwitch *switchView = [[UISwitch alloc]init];
                switchView.frame = CGRectMake(cell.contentView.frame.size.width - switchView.frame.size.width-KGap*3 , KTextHeight/2-switchView.frame.size.height/2, switchView.frame.size.width, switchView.frame.size.height);
                switchView.tag = KImageSwitchViewTag;
                switchView.on = YES;
                self.isSendImage = switchView.on;
                [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                [cell.contentView addSubview:switchView];
            }
            if ([cell.contentView viewWithTag:KImageSwitchViewTag]!=nil)
            {
                ((UISwitch *)[cell.contentView viewWithTag:KImageSwitchViewTag]).on =self.isSendImage;
            }
        }
        else if (indexPath.row ==1)
        {
            static NSString *cellIdentifier = @"imageViewCell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell ==nil)
            {
                cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake( KGap, KGap,cell.frame.size.width-KGap*4,self.view.frame.size.height-KGap*2)];
                imageView.userInteractionEnabled = YES;
                imageView.tag = KImageViewTag;
                
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigImage)];
                [imageView addGestureRecognizer:tapGesture];
                
                [imageView.layer setCornerRadius:5.0];
                imageView.clipsToBounds = YES;
                [cell.contentView addSubview:imageView];
            }
            if ([cell.contentView viewWithTag:KImageViewTag]!=nil)
            {
                ((UIImageView *)[cell.contentView viewWithTag:KImageViewTag]).image =[HaloDebug_ShakeBugManager sharedInstance].capturedimage;
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == ESectionSummary || indexPath.section == ESectionDesc)
    {
        return KTextViewHeight;
    }
    else if(indexPath.section == ESectionEmail)
    {
        return KTextHeight;
    }
    else if (indexPath.section == ESectionImage)
    {
        if (indexPath.row == 0)
        {
            return KTextHeight;
        }else if(indexPath.row == 1)
        {
            return self.view.frame.size.height;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return KHeaderHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case ESectionSummary:
            return NSLocalizedStringFromTable(@"summary", @"Other", nil);
            break;
        case ESectionDesc:
            return NSLocalizedStringFromTable(@"description", @"Other", nil);
            break;
        case ESectionEmail:
            return NSLocalizedStringFromTable(@"email", @"Other", nil);
            break;
        case ESectionImage:
            return NSLocalizedStringFromTable(@"image", @"Other", nil);
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - UITextview delagate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.firstTextView = textView;
    [self handleKeyboardUserInfo];
}

-(void)textViewDidChange:(UITextView *)textView
{
    if ([self.tableView indexPathForCell: (UITableViewCell *)textView.superview.superview].section ==0)
    {
        self.summary = textView.text;
    }
    else if([self.tableView indexPathForCell: (UITableViewCell *)textView.superview.superview].section ==1)
    {
        self.desc = textView.text;
    }
    if (self.summary.length >0 && self.desc.length >0)
    {
        self.rightNaviButton.enabled = YES;
    }
    else
    {
        self.rightNaviButton.enabled = NO;
    }
}

#pragma mark - UITextField delagate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.firstTextView = textField;
    [self handleKeyboardUserInfo];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.email = textField.text;
}

#pragma mark - ShowBigImage
- (void)showBigImage
{
//    HaloPhotoScrollViewController *vc = [[HaloPhotoScrollViewController alloc] initWithImage:[HaloDebug_ShakeBugManager sharedInstance].capturedimage];
//    [self presentHaloViewController:vc animated:YES];
}
@end
