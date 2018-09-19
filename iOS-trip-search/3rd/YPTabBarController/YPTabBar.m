//
//  YPTabBar.m
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import "YPTabBar.h"
#define BADGE_BG_COLOR_DEFAULT [UIColor colorWithRed:252 / 255.0f green:15 / 255.0f blue:29 / 255.0f alpha:1.0f]
@interface YPTabBar ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *itemSelectedBgImageView;

@property (nonatomic, assign) BOOL itemSelectedBgSwitchAnimated;  // TabItem选中切换时，是否显示动画
@property (nonatomic, assign) UIEdgeInsets itemSelectedBgInsets;
@property (nonatomic, assign) BOOL itemFitTextWidth;
//@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, assign) CGFloat itemFitTextWidthSpacing;
@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) CGFloat itemContentHorizontalCenterVerticalOffset;
@property (nonatomic, assign) CGFloat itemContentHorizontalCenterSpacing;

@property (nonatomic, strong) NSMutableArray *separatorLayers;

@property (nonatomic, assign) CGFloat numberBadgeMarginTop;
@property (nonatomic, assign) CGFloat numberBadgeCenterMarginRight;
@property (nonatomic, assign) CGFloat numberBadgeTitleHorizonalSpace;
@property (nonatomic, assign) CGFloat numberBadgeTitleVerticalSpace;

@property (nonatomic, assign) CGFloat dotBadgeMarginTop;
@property (nonatomic, assign) CGFloat dotBadgeCenterMarginRight;
@property (nonatomic, assign) CGFloat dotBadgeSideLength;

@property (nonatomic, strong) UIColor *itemSeparatorColor;
@property (nonatomic, assign) CGFloat itemSeparatorWidth;
@property (nonatomic, assign) CGFloat itemSeparatorMarginTop;
@property (nonatomic, assign) CGFloat itemSeparatorMarginBottom;
@end

@implementation YPTabBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    
    self.backgroundColor = [UIColor whiteColor];
    _selectedItemIndex = -1;
    _itemTitleColor = [UIColor whiteColor];
    _itemTitleSelectedColor = [UIColor blackColor];
    _itemTitleFont = [UIFont systemFontOfSize:10];
    _itemSelectedBgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _itemContentHorizontalCenter = YES;
    _itemFontChangeFollowContentScroll = NO;
    _itemColorChangeFollowContentScroll = YES;
    _itemSelectedBgScrollFollowContent = NO;
    
    _badgeTitleColor = [UIColor whiteColor];
    _badgeTitleFont = [UIFont systemFontOfSize:13];
    _badgeBackgroundColor = BADGE_BG_COLOR_DEFAULT;
    
//    _numberBadgeFrame = YPTabItemBadgeFrameMake(2, 30, 16);
//    _dotBadgeFrame = YPTabItemBadgeFrameMake(5, 25, 10);
    
    _numberBadgeMarginTop = 2;
    _numberBadgeCenterMarginRight = 30;
    _numberBadgeTitleHorizonalSpace = 8;
    _numberBadgeTitleVerticalSpace = 2;
    
    _dotBadgeMarginTop = 5;
    _dotBadgeCenterMarginRight = 25;
    _dotBadgeSideLength = 10;
[super awakeFromNib];
    self.clipsToBounds = YES;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateItemsFrame];
    [self updateFrameOfSelectedBgWithIndex:self.selectedItemIndex];
    [self updateSeperators];
    if (self.scrollView) {
        self.scrollView.frame = self.bounds;
    }
}

- (void)setItems:(NSArray *)items {
    // 将老的item从superview上删除
    [_items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _items = [items copy];
    
    // 初始化每一个item
    for (YPTabItem *item in self.items) {
        item.titleColor = self.itemTitleColor;
        item.titleSelectedColor = self.itemTitleSelectedColor;
        item.titleFont = self.itemTitleFont;
        
        [item setContentHorizontalCenterWithVerticalOffset:5 spacing:5];

        item.badgeTitleFont = self.badgeTitleFont;
        item.badgeTitleColor = self.badgeTitleColor;
        item.badgeBackgroundColor = self.badgeBackgroundColor;
        item.badgeBackgroundImage = self.badgeBackgroundImage;
        
        [item setNumberBadgeMarginTop:self.numberBadgeMarginTop
                    centerMarginRight:self.numberBadgeCenterMarginRight
                  titleHorizonalSpace:self.numberBadgeTitleHorizonalSpace
                   titleVerticalSpace:self.numberBadgeTitleVerticalSpace];
        [item setDotBadgeMarginTop:self.dotBadgeMarginTop
                 centerMarginRight:self.dotBadgeCenterMarginRight
                        sideLength:self.dotBadgeSideLength];
        
        [item addTarget:self action:@selector(tabItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    // 更新每个item的位置
    [self updateItemsFrame];
    
    // 更新item的大小缩放
    [self updateItemsScaleIfNeeded];
}

- (void)setTitles:(NSArray *)titles {
    NSMutableArray *items = [NSMutableArray array];
    for (NSString *title in titles) {
        YPTabItem *item = [[YPTabItem alloc] init];
        item.title = title;
        [items addObject:item];
    }
    self.items = items;
}

- (void)setleftAndRightSpacing:(CGFloat)leftAndRightSpacing {
    _leftAndRightSpacing = leftAndRightSpacing;
    [self updateItemsFrame];
}

- (void)updateItemsFrame {
    if (self.items.count == 0) {
        return;
    }
    // 将item从superview上删除
    [self.items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 将item的选中背景从superview上删除
    [self.itemSelectedBgImageView removeFromSuperview];
    if (self.scrollView) {
        // 支持滚动
        
        [self.scrollView addSubview:self.itemSelectedBgImageView];
        CGFloat x = self.leftAndRightSpacing;
        for (int i = 0; i < self.items.count; i++) {
            YPTabItem *item = self.items[i];
            CGFloat width = 0;
            // item的宽度为一个固定值
            if (self.itemWidth > 0) {
                width = self.itemWidth;
            }
            // item的宽度为根据字体大小和spacing进行适配
            if (self.itemFitTextWidth) {
                CGSize size = [item.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                    attributes:@{NSFontAttributeName : self.itemTitleFont}
                                                       context:nil].size;
                width = ceilf(size.width) + self.itemFitTextWidthSpacing;
            }
            
            item.frame = CGRectMake(x, 0, width, self.frame.size.height);
            item.index = i;
            x += width;
            [self.scrollView addSubview:item];
        }
        self.scrollView.contentSize = CGSizeMake(x + self.leftAndRightSpacing, self.scrollView.frame.size.height);
    } else {
        // 不支持滚动
        
        [self addSubview:self.itemSelectedBgImageView];
        CGFloat x = self.leftAndRightSpacing;
        CGFloat itemWidth = (self.frame.size.width - self.leftAndRightSpacing * 2) / self.items.count;
        for (int i = 0; i < self.items.count; i++) {
            YPTabItem *item = self.items[i];
            item.frame = CGRectMake(x, 0, itemWidth, self.frame.size.height);
            item.index = i;
            
            x += itemWidth;
            [self addSubview:item];
        }
    }
}

- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex {
    if (self.items.count == 0 || selectedItemIndex < 0 || selectedItemIndex >= self.items.count) {
        return;
    }
    
    if (_selectedItemIndex >= 0) {
        YPTabItem *oldSelectedItem = self.items[_selectedItemIndex];
        oldSelectedItem.selected = NO;
        if (self.itemFontChangeFollowContentScroll) {
            // 如果支持字体平滑渐变切换，则设置item的scale
            oldSelectedItem.transform = CGAffineTransformMakeScale(self.itemTitleUnselectedFontScale,
                                                                   self.itemTitleUnselectedFontScale);
        } else {
            // 如果支持字体平滑渐变切换，则直接设置字体
            oldSelectedItem.titleFont = self.itemTitleFont;
        }
    }
    
    YPTabItem *newSelectedItem = self.items[selectedItemIndex];
    newSelectedItem.selected = YES;
    if (self.itemFontChangeFollowContentScroll) {
        // 如果支持字体平滑渐变切换，则设置item的scale
        newSelectedItem.transform = CGAffineTransformMakeScale(1, 1);
    } else {
        // 如果支持字体平滑渐变切换，则直接设置字体
        if (self.itemTitleSelectedFont) {
            newSelectedItem.titleFont = self.itemTitleSelectedFont;
        }
    }
    
    NSLog(@"itemSelectedBgScrollFollowContent-->%d", self.itemSelectedBgScrollFollowContent);
    if (self.itemSelectedBgScrollFollowContent) {
        // item的选中背景位置会跟随contentView的拖动进行变化
        if (_selectedItemIndex < 0) {
            // 仅在首次显示的时候更新它的位置，之后会根据contentView的拖动进行移动
            [self updateFrameOfSelectedBgWithIndex:selectedItemIndex];
        }
    } else {
        // item的选中背景位置不会跟随contentView的拖动进行变化
        
        if (self.itemSelectedBgSwitchAnimated && _selectedItemIndex >= 0) {
            [UIView animateWithDuration:0.25f animations:^{
                [self updateFrameOfSelectedBgWithIndex:selectedItemIndex];
            }];
        } else {
            [self updateFrameOfSelectedBgWithIndex:selectedItemIndex];
        }
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(yp_tabBar:didSelectedItemAtIndex:)]) {
        [self.delegate yp_tabBar:self didSelectedItemAtIndex:selectedItemIndex];
    }
    _selectedItemIndex = selectedItemIndex;
    // 如果tabbar支持滚动，将选中的item放到tabbar的中央
    [self setSelectedItemCenter];
}

- (void)updateFrameOfSelectedBgWithIndex:(NSInteger)index {
    if (index < 0) {
        return;
    }
    YPTabItem *item = self.items[index];
    CGFloat width = item.frameWithOutTransform.size.width - self.itemSelectedBgInsets.left - self.itemSelectedBgInsets.right;
    CGFloat height = item.frameWithOutTransform.size.height - self.itemSelectedBgInsets.top - self.itemSelectedBgInsets.bottom;
    self.itemSelectedBgImageView.frame = CGRectMake(item.frameWithOutTransform.origin.x + self.itemSelectedBgInsets.left,
                                                    item.frameWithOutTransform.origin.y + self.itemSelectedBgInsets.top,
                                                    width,
                                                    height);
}

- (void)setScrollEnabledAndItemWidth:(CGFloat)width {
    if (!self.scrollView) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.scrollView];
    }
    self.itemWidth = width;
    self.itemFitTextWidth = NO;
    self.itemFitTextWidthSpacing = 0;
    [self updateItemsFrame];
}

- (void)setScrollEnabledAndItemFitTextWidthWithSpacing:(CGFloat)spacing {
    if (!self.scrollView) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.scrollView];
    }
    self.itemFitTextWidth = YES;
    self.itemFitTextWidthSpacing = spacing;
    self.itemWidth = 0;
    [self updateItemsFrame];
}

- (void)setSelectedItemCenter {
    if (!self.scrollView) {
        return;
    }
    // 修改偏移量
    CGFloat offsetX = self.selectedItem.center.x - self.scrollView.frame.size.width * 0.5f;
    
    // 处理最小滚动偏移量
    if (offsetX < 0) {
        offsetX = 0;
    }
    
    // 处理最大滚动偏移量
    CGFloat maxOffsetX = self.scrollView.contentSize.width - self.scrollView.frame.size.width;
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}


/**
 *  获取未选中字体与选中字体大小的比例
 */
- (CGFloat)itemTitleUnselectedFontScale {
    if (_itemTitleSelectedFont) {
        return self.itemTitleFont.pointSize / _itemTitleSelectedFont.pointSize;
    }
    return 1.0f;
}

- (void)tabItemClicked:(YPTabItem *)item {
    if (self.selectedItemIndex == item.index) {
        return;
    }
    BOOL will = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(yp_tabBar:willSelectItemAtIndex:)]) {
        will = [self.delegate yp_tabBar:self willSelectItemAtIndex:item.index];
    }
    if (will) {
        self.selectedItemIndex = item.index;
    }
}

- (YPTabItem *)selectedItem {
    if (self.selectedItemIndex < 0) {
        return nil;
    }
    return self.items[self.selectedItemIndex];
}

#pragma mark - ItemSelectedBg

- (void)setItemSelectedBgColor:(UIColor *)itemSelectedBgColor {
    _itemSelectedBgColor = itemSelectedBgColor;
    self.itemSelectedBgImageView.backgroundColor = itemSelectedBgColor;
}

- (void)setItemSelectedBgImage:(UIImage *)itemSelectedBgImage {
    _itemSelectedBgImage = itemSelectedBgImage;
    self.itemSelectedBgImageView.image = itemSelectedBgImage;
}

- (void)setItemSelectedBgCornerRadius:(CGFloat)itemSelectedBgCornerRadius {
    _itemSelectedBgCornerRadius = itemSelectedBgCornerRadius;
    self.itemSelectedBgImageView.clipsToBounds = YES;
    self.itemSelectedBgImageView.layer.cornerRadius = itemSelectedBgCornerRadius;
}

- (void)setItemSelectedBgInsets:(UIEdgeInsets)insets
              tapSwitchAnimated:(BOOL)animated{
    self.itemSelectedBgInsets = insets;
    self.itemSelectedBgSwitchAnimated = animated;
}

- (void)setItemSelectedBgInsets:(UIEdgeInsets)itemSelectedBgInsets {
    _itemSelectedBgInsets = itemSelectedBgInsets;
    if (self.items.count > 0 && self.selectedItemIndex >= 0) {
        [self updateFrameOfSelectedBgWithIndex:self.selectedItemIndex];
    }
}


#pragma mark - ItemTitle

- (void)setItemTitleColor:(UIColor *)itemTitleColor {
    _itemTitleColor = itemTitleColor;
    [self.items makeObjectsPerformSelector:@selector(setTitleColor:) withObject:itemTitleColor];
}

- (void)setItemTitleSelectedColor:(UIColor *)itemTitleSelectedColor {
    _itemTitleSelectedColor = itemTitleSelectedColor;
    [self.items makeObjectsPerformSelector:@selector(setTitleSelectedColor:) withObject:itemTitleSelectedColor];
}

- (void)setItemTitleFont:(UIFont *)itemTitleFont {
    _itemTitleFont = itemTitleFont;
    if (self.itemFontChangeFollowContentScroll) {
        // item字体支持平滑切换，更新每个item的scale
        [self updateItemsScaleIfNeeded];
    } else {
        // item字体不支持平滑切换，更新item的字体
        if (self.itemTitleSelectedFont) {
            // 设置了选中字体，则只更新未选中的item
            for (YPTabItem *item in self.items) {
                if (!item.selected) {
                    [item setTitleFont:itemTitleFont];
                }
            }
        } else {
            // 未设置选中字体，更新所有item
            [self.items makeObjectsPerformSelector:@selector(setTitleFont:) withObject:itemTitleFont];
        }
        
    }
    if (self.itemFitTextWidth) {
        // 如果item的宽度是匹配文字的，更新item的位置
        [self updateItemsFrame];
    }
}

- (void)setItemTitleSelectedFont:(UIFont *)itemTitleSelectedFont {
    _itemTitleSelectedFont = itemTitleSelectedFont;
    self.selectedItem.titleFont = itemTitleSelectedFont;
    [self updateItemsScaleIfNeeded];
}

- (void)setItemFontChangeFollowContentScroll:(BOOL)itemFontChangeFollowContentScroll {
    _itemFontChangeFollowContentScroll = itemFontChangeFollowContentScroll;
    [self updateItemsScaleIfNeeded];
}

- (void)updateItemsScaleIfNeeded {
    if (self.itemTitleSelectedFont &&
        self.itemFontChangeFollowContentScroll &&
        self.itemTitleSelectedFont.pointSize != self.itemTitleFont.pointSize) {
        [self.items makeObjectsPerformSelector:@selector(setTitleFont:) withObject:self.itemTitleSelectedFont];
        for (YPTabItem *item in self.items) {
            if (!item.selected) {
                item.transform = CGAffineTransformMakeScale(self.itemTitleUnselectedFontScale,
                                                            self.itemTitleUnselectedFontScale);
            }
        }
    }
}

#pragma mark - ItemContent

- (void)setItemContentHorizontalCenter:(BOOL)itemContentHorizontalCenter {
    _itemContentHorizontalCenter = itemContentHorizontalCenter;
    if (itemContentHorizontalCenter) {
        [self setItemContentHorizontalCenterWithVerticalOffset:5 spacing:5];
    } else {
        self.itemContentHorizontalCenterVerticalOffset = 0;
        self.itemContentHorizontalCenterSpacing = 0;
        [self.items makeObjectsPerformSelector:@selector(setContentHorizontalCenter:) withObject:@(NO)];
    }
}

- (void)setItemContentHorizontalCenterWithVerticalOffset:(CGFloat)verticalOffset
                                                 spacing:(CGFloat)spacing {
    _itemContentHorizontalCenter = YES;
    self.itemContentHorizontalCenterVerticalOffset = verticalOffset;
    self.itemContentHorizontalCenterSpacing = spacing;
    for (YPTabItem *item in self.items) {
        [item setContentHorizontalCenterWithVerticalOffset:verticalOffset spacing:spacing];
    }
}

#pragma mark - Badge
- (void)setBadgeBackgroundColor:(UIColor *)badgeBackgroundColor {
    _badgeBackgroundColor = badgeBackgroundColor;
    [self.items makeObjectsPerformSelector:@selector(setBadgeBackgroundColor:) withObject:badgeBackgroundColor];
}

- (void)setBadgeBackgroundImage:(UIImage *)badgeBackgroundImage {
    _badgeBackgroundImage = badgeBackgroundImage;
    [self.items makeObjectsPerformSelector:@selector(setBadgeBackgroundImage:) withObject:badgeBackgroundImage];
}

- (void)setBadgeTitleColor:(UIColor *)badgeTitleColor {
    _badgeTitleColor = badgeTitleColor;
    [self.items makeObjectsPerformSelector:@selector(setBadgeTitleColor:) withObject:badgeTitleColor];
}

- (void)setBadgeTitleFont:(UIFont *)badgeTitleFont {
    _badgeTitleFont = badgeTitleFont;
    [self.items makeObjectsPerformSelector:@selector(setBadgeTitleFont:) withObject:badgeTitleFont];
}

- (void)setNumberBadgeMarginTop:(CGFloat)marginTop
              centerMarginRight:(CGFloat)centerMarginRight
            titleHorizonalSpace:(CGFloat)titleHorizonalSpace
             titleVerticalSpace:(CGFloat)titleVerticalSpace {
    for (YPTabItem *item in self.items) {
        [item setNumberBadgeMarginTop:marginTop
                    centerMarginRight:centerMarginRight
                  titleHorizonalSpace:titleHorizonalSpace
                   titleVerticalSpace:titleVerticalSpace];
    }
}

- (void)setDotBadgeMarginTop:(CGFloat)marginTop
           centerMarginRight:(CGFloat)centerMarginRight
                  sideLength:(CGFloat)sideLength {
    for (YPTabItem *item in self.items) {
        [item setDotBadgeMarginTop:marginTop
                 centerMarginRight:centerMarginRight
                        sideLength:sideLength];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    NSLog(@"scrollViewDidEndDecelerating");
    self.selectedItemIndex = page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat scrollViewWidth = scrollView.frame.size.width;
    if (offsetX < 0) {
        return;
    }
    if (offsetX > scrollView.contentSize.width - scrollViewWidth) {
        return;
    }
    
    NSInteger leftIndex = offsetX / scrollViewWidth;
    NSInteger rightIndex = leftIndex + 1;
    YPTabItem *leftItem = self.items[leftIndex];
    YPTabItem *rightItem;
    if (rightIndex < self.items.count) {
        rightItem = self.items[rightIndex];
    }
    
    // 计算右边按钮偏移量
    CGFloat rightScale = offsetX / scrollViewWidth;
    // 只想要 0~1
    rightScale = rightScale - leftIndex;
    CGFloat leftScale = 1 - rightScale;
    
    if (scrollView.isDragging || scrollView.isDecelerating) {
        if (self.itemFontChangeFollowContentScroll && self.itemTitleUnselectedFontScale != 1.0f) {
            CGFloat diff = self.itemTitleUnselectedFontScale - 1;
            leftItem.transform = CGAffineTransformMakeScale(rightScale * diff + 1, rightScale * diff + 1);
            rightItem.transform = CGAffineTransformMakeScale(leftScale * diff + 1, leftScale * diff + 1);
        }
        
        if (self.itemColorChangeFollowContentScroll) {
            static CGFloat normalRed, normalGreen, normalBlue;
            static CGFloat selectedRed, selectedGreen, selectedBlue;
            [self.itemTitleColor getRed:&normalRed green:&normalGreen blue:&normalBlue alpha:nil];
            [self.itemTitleSelectedColor getRed:&selectedRed green:&selectedGreen blue:&selectedBlue alpha:nil];
            // 获取选中和未选中状态的颜色差值
            CGFloat redDiff = selectedRed - normalRed;
            CGFloat greenDiff = selectedGreen - normalGreen;
            CGFloat blueDiff = selectedBlue - normalBlue;
            // 根据颜色值的差和偏移量，设置tabItem的标题颜色
            leftItem.titleLabel.textColor = [UIColor colorWithRed:leftScale * redDiff + normalRed
                                                            green:leftScale * greenDiff + normalGreen
                                                             blue:leftScale * blueDiff + normalBlue
                                                            alpha:1];
            rightItem.titleLabel.textColor = [UIColor colorWithRed:rightScale * redDiff + normalRed
                                                             green:rightScale * greenDiff + normalGreen
                                                              blue:rightScale * blueDiff + normalBlue
                                                             alpha:1];
        }
    }
    if (self.itemSelectedBgScrollFollowContent) {
        CGRect frame = self.itemSelectedBgImageView.frame;
        CGFloat xDiff = rightItem.frameWithOutTransform.origin.x - leftItem.frameWithOutTransform.origin.x;
        frame.origin.x = rightScale * xDiff + leftItem.frameWithOutTransform.origin.x + self.itemSelectedBgInsets.left;
        
        CGFloat widthDiff = rightItem.frameWithOutTransform.size.width - leftItem.frameWithOutTransform.size.width;
        if (widthDiff != 0) {
            CGFloat leftSelectedBgWidth = leftItem.frameWithOutTransform.size.width - self.itemSelectedBgInsets.left - self.itemSelectedBgInsets.right;
            frame.size.width = rightScale * widthDiff + leftSelectedBgWidth;
        }
        
        self.itemSelectedBgImageView.frame = frame;
    }
}

#pragma mark - Separator
- (void)setItemSeparatorColor:(UIColor *)itemSeparatorColor
                        width:(CGFloat)width
                    marginTop:(CGFloat)marginTop
                 marginBottom:(CGFloat)marginBottom {
    self.itemSeparatorColor = itemSeparatorColor;
    self.itemSeparatorWidth = width;
    self.itemSeparatorMarginTop = marginTop;
    self.itemSeparatorMarginBottom = marginBottom;
    [self updateSeperators];
}

- (void)setItemSeparatorColor:(UIColor *)itemSeparatorColor
                    marginTop:(CGFloat)marginTop
                 marginBottom:(CGFloat)marginBottom {
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat onePixel;
    if ([mainScreen respondsToSelector:@selector(nativeScale)]) {
        onePixel = 1.0f / mainScreen.nativeScale;
    } else {
        onePixel = 1.0f / mainScreen.scale;
    }
    [self setItemSeparatorColor:itemSeparatorColor
                          width:onePixel
                      marginTop:marginTop
                   marginBottom:marginBottom];
}

- (void)updateSeperators {
    if (self.itemSeparatorColor) {
        if (!self.separatorLayers) {
            self.separatorLayers = [[NSMutableArray alloc] init];
        }
        [self.separatorLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.separatorLayers removeAllObjects];
        [self.items enumerateObjectsUsingBlock:^(YPTabItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx > 0) {
                CALayer *layer = [[CALayer alloc] init];
                layer.backgroundColor = self.itemSeparatorColor.CGColor;
                layer.frame = CGRectMake(item.frame.origin.x - self.itemSeparatorWidth / 2,
                                         self.itemSeparatorMarginTop,
                                         self.itemSeparatorWidth,
                                         self.bounds.size.height - self.itemSeparatorMarginTop - self.itemSeparatorMarginBottom);
                [self.layer addSublayer:layer];
                [self.separatorLayers addObject:layer];
            }
        }];
    } else {
        [self.separatorLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.separatorLayers removeAllObjects];
        self.separatorLayers = nil;
    }
}
@end
