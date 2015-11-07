//
//  HaloUITableCell.h
//  HaloSlimFramework
//
//  Created by  on 13-5-20.
//
//

#import <UIKit/UIKit.h>
@class HaloUITableCellInnerView;

@interface HaloUITableCell : UITableViewCell
@property (nonatomic,assign) BOOL useGuesture;
@property (nonatomic,assign,readonly) BOOL showingRightButtons;
@property (nonatomic,strong) NSIndexPath *indexPath;
- (void)setSeparatorImage:(UIImage *)image UI_APPEARANCE_SELECTOR;
- (void)disableSeparator;
- (void)drawContentView:(CGRect)rect;
- (void)addRightButton:(UIButton *)button;
- (void)resetRightButtons;
//default width is 60
- (NSInteger)rightButtonWidth;
- (void)showRightButtons;
- (void)endShowRightButtons;
@end

@interface HaloUITableCellInnerView: UIView

@property (nonatomic, weak)HaloUITableCell *cell;
@property (nonatomic, assign) BOOL transiting;
@end