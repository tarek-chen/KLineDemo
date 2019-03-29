//
//  KlineStyle.h
//  KLineDemo
//
//  Created by E on 2019/3/18.
//  Copyright © 2019 easy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
// 类型

#define isMA ENChartTypeMA == KlineStyle.style.topChartType
#define isEMA ENChartTypeEMA == KlineStyle.style.topChartType
#define isMACD ENChartTypeMACD == KlineStyle.style.bottomChartType
#define isBOLL ENChartTypeBOLL == KlineStyle.style.topChartType
#define isRSI ENChartTypeRSI == KlineStyle.style.bottomChartType
#define isKDJ ENChartTypeKDJ == KlineStyle.style.bottomChartType
// 颜色
#define kLineColor1 KlineStyle.style.color_1
#define kLineColor2 KlineStyle.style.color_2
#define kLineColor3 KlineStyle.style.color_3
#define kCandleUpColor KlineStyle.style.color_up
#define kCandleDownColor KlineStyle.style.color_dn

// 蜡烛图高度占比
static CGFloat kTopChartScale = 0.7;
// 蜡烛图起始y
static CGFloat kMainChartMarginTop = 40;
static CGFloat kMainChartMarginBottom = 15;
static CGFloat kSubChartMarginTop = 16;
static CGFloat kSubChartMarginBottom = 10;
/// 蜡烛最低高度
static CGFloat kMinCandleHeight = 1;
static CGFloat kCandleSpacing = 2;
// 主副图间距(时间线高度)
static CGFloat kChartSpacing = 16;
/// 边框宽度
static CGFloat kChartBorderWidth = 1;
/// 线条宽度
static CGFloat kChartLineWidth = 1;

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
+ (instancetype)style;
+ (CGFloat)getCandleWidthForCount:(NSInteger)showCount canvasWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
