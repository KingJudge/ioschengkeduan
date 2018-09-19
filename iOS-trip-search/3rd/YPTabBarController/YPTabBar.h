//
//  YPTabBar.h
//  YPTabBarController
//
//  Created by 喻平 on 15/8/11.
//  Copyright (c) 2015年 YPTabBarController. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPTabItem.h"
@class YPTabBar;
@protocol YPTabBarDelegate <NSObject>

@optional
- (BOOL)yp_tabBar:(YPTabBar *)tabBar willSelectItemAtIndex:(NSInteger)index;
- (void)yp_tabBar:(YPTabBar *)tabBar didSelectedItemAtIndex:(NSInteger)index;

@end

@interface YPTabBar : UIView <UIScrollViewDelegate>

@property (nonatomic, copy) NSArray<YPTabItem *> *items; // TabItems

// 设置item选中背景
@property (nonatomic, strong) UIColor *itemSelectedBgColor;
@property (nonatomic, strong) UIImage *itemSelectedBgImage;
@property (nonatomic, assign) CGFloat itemSelectedBgCornerRadius;

@property (nonatomic, assign) CGFloat leftAndRightSpacing; // TabBar边缘与第一个和最后一个item的距离

@property (nonatomic, strong) UIColor *itemTitleColor; // 标题颜色
@property (nonatomic, strong) UIColor *itemTitleSelectedColor; // 选中时标题的颜色
@property (nonatomic, strong) UIFont *itemTitleFont; // 标题字体
@property (nonatomic, strong) UIFont *itemTitleSelectedFont; // 选中时标题的字体

@property (nonatomic, strong) UIColor *badgeBackgroundColor; // Badge背景颜色
@property (nonatomic, strong) UIImage *badgeBackgroundImage; // Badge背景图像
@property (nonatomic, strong) UIColor *badgeTitleColor; // Badge标题颜色
@property (nonatomic, strong) UIFont *badgeTitleFont; // Badge标题字体

@property (nonatomic, assign) NSInteger selectedItemIndex; // 选中某一个item


/**
 *  拖动内容视图时，item的颜色是否根据拖动位置显示渐变效果，默认为YES
 */
@property (nonatomic, assign, getter = isItemColorChangeFollowContentScroll) BOOL itemColorChangeFollowContentScroll;

/**
 *  拖动内容视图时，item的字体是否根据拖动位置显示渐变效果，默认为NO
 */
@property (nonatomic, assign, getter = isItemFontChangeFollowContentScroll) BOOL itemFontChangeFollowContentScroll;

/**
 *  TabItem的选中背景是否随contentView滑动而移动
 */
@property (nonatomic, assign, getter = isItemSelectedBgScrollFollowContent) BOOL itemSelectedBgScrollFollowContent;

/**
 *  将Image和Title设置为水平居中，默认为YES
 */
@property (nonatomic, assign, getter = isItemContentHorizontalCenter) BOOL itemContentHorizontalCenter;

@property (nonatomic, weak) id<YPTabBarDelegate> delegate;

/**
 *  返回已选中的item
 */
- (YPTabItem *)selectedItem;

/**
 *  根据titles创建item
 */
- (void)setTitles:(NSArray <NSString *> *)titles;

/**
 *  设置tabItem的选中背景，这个背景可以是一个横条
 *
 *  @param insets       选中背景的insets
 *  @param animated     点击item进行背景切换的时候，是否支持动画
 */
- (void)setItemSelectedBgInsets:(UIEdgeInsets)insets tapSwitchAnimated:(BOOL)animated;

/**
 *  设置tabBar可以左右滑动
 *  此方法与setScrollEnabledAndItemFitTextWidthWithSpacing这个方法是两种模式，哪个后调用哪个生效
 *
 *  @param width 每个tabItem的宽度
 */
- (void)setScrollEnabledAndItemWidth:(CGFloat)width;

/**
 *  设置tabBar可以左右滑动，并且item的宽度根据标题的宽度来匹配
 *  此方法与setScrollEnabledAndItemWidth这个方法是两种模式，哪个后调用哪个生效
 *
 *  @param spacing  item的宽度 = 文字宽度 + spacing 
 */
- (void)setScrollEnabledAndItemFitTextWidthWithSpacing:(CGFloat)spacing;

/**
 *  将tabItem的image和title设置为居中，并且调整其在竖直方向的位置
 *
 *  @param verticalOffset  竖直方向的偏移量
 *  @param spacing         image和title的距离
 */
- (void)setItemContentHorizontalCenterWithVerticalOffset:(CGFloat)verticalOffset
                                                 spacing:(CGFloat)spacing;

/**
 *  设置数字Badge的位置与大小
 *
 *  @param marginTop            与TabItem顶部的距离
 *  @param centerMarginRight    badge的中心与TabItem右侧的距离
 *  @param titleHorizonalSpace  Badge的标题水平方向的空间
 *  @param titleVerticalSpace   Badge的标题竖直方向的空间
 */
- (void)setNumberBadgeMarginTop:(CGFloat)marginTop
              centerMarginRight:(CGFloat)centerMarginRight
            titleHorizonalSpace:(CGFloat)titleHorizonalSpace
             titleVerticalSpace:(CGFloat)titleVerticalSpace;
/**
 *  设置小圆点Badge的位置与大小
 *
 *  @param marginTop            与TabItem顶部的距离
 *  @param centerMarginRight    badge的中心与TabItem右侧的距离
 *  @param sideLength           小圆点的边长
 */
- (void)setDotBadgeMarginTop:(CGFloat)marginTop
           centerMarginRight:(CGFloat)centerMarginRight
                  sideLength:(CGFloat)sideLength;

/**
 *  设置分割线
 *
 *  @param itemSeparatorColor 分割线颜色
 *  @param width              宽度
 *  @param marginTop          与tabbar顶部距离
 *  @param marginBottom       与tabbar底部距离
 */
- (void)setItemSeparatorColor:(UIColor *)itemSeparatorColor
                        width:(CGFloat)width
                    marginTop:(CGFloat)marginTop
                 marginBottom:(CGFloat)marginBottom;

- (void)setItemSeparatorColor:(UIColor *)itemSeparatorColor
                    marginTop:(CGFloat)marginTop
                 marginBottom:(CGFloat)marginBottom;
@end
