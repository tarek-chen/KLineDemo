//
//  KlineStyle.h
//  KLineDemo
//
//  Created by E on 2019/3/18.
//  Copyright © 2019 chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// 类型

#define isMA (ENChartTypeMA == KlineStyle.shared.topChartType)
#define isEMA (ENChartTypeEMA == KlineStyle.shared.topChartType)
#define isBOLL (ENChartTypeBOLL == KlineStyle.shared.topChartType)
#define isLine (ENChartTypeLine == KlineStyle.shared.topChartType)
#define isMACD (ENChartTypeMACD == KlineStyle.shared.bottomChartType)
#define isRSI (ENChartTypeRSI == KlineStyle.shared.bottomChartType)
#define isKDJ (ENChartTypeKDJ == KlineStyle.shared.bottomChartType)
#define isVOL (ENChartTypeVOL == KlineStyle.shared.bottomChartType)
// 颜色
#define kLineColor1 KlineStyle.shared.color_1
#define kLineColor2 KlineStyle.shared.color_2
#define kLineColor3 KlineStyle.shared.color_3
#define kCandleUpColor KlineStyle.shared.color_up
#define kCandleDownColor KlineStyle.shared.color_dn

// 蜡烛图高度占比
static CGFloat kTopChartScale = 0.7;
// 蜡烛图起始y
static CGFloat kMainChartMarginTop = 30;
static CGFloat kMainChartMarginBottom = 20;
static CGFloat kSubChartMarginTop = 16;
static CGFloat kSubChartMarginBottom = 10;
/// 蜡烛最低高度
static CGFloat kMinCandleHeight = 1;
static CGFloat kCandleSpacing = 2;
// 主副图间距(时间线高度)
static CGFloat kChartSpacing = 16;
/// 边框宽度
static CGFloat kChartBorderWidth = 0.8;
/// 线条宽度
static CGFloat kChartLineWidth = 0.5;

typedef NS_ENUM(NSUInteger, ENChartType) {
    ENChartTypeLine,
    ENChartTypeMA,
    ENChartTypeEMA,
    ENChartTypeBOLL,
    ENChartTypeMACD,
    ENChartTypeKDJ,
    ENChartTypeRSI,
    ENChartTypeVOL,
};

@interface KlineStyle : NSObject


@property (nonatomic, assign) ENChartType topChartType;
@property (nonatomic, assign) ENChartType bottomChartType;
// 捏合缩放比例
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat minScale;
@property (nonatomic, assign) CGFloat maxScale;
@property (nonatomic, assign) CGFloat candle_w;

@property (nonatomic, strong) UIColor *textColor;
/// 分时线颜色
@property (nonatomic, strong) UIColor *color_Line;
@property (nonatomic, strong) UIColor *color_AlphaLine;
/// 涨
@property (nonatomic, strong) UIColor *color_up;
/// 跌
@property (nonatomic, strong) UIColor *color_dn;
/// 文字蓝色
@property (nonatomic, strong) UIColor *color_text1;
@property (nonatomic, strong) UIColor *color_1;
@property (nonatomic, strong) UIColor *color_2;
@property (nonatomic, strong) UIColor *color_3;
+ (instancetype)shared;
+ (CGFloat)getCandleWidthForCount:(NSInteger)showCount canvasWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
