//
//  KlineStyle.h
//  KLineDemo
//
//  Created by E on 2019/3/18.
//  Copyright © 2019 easy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 蜡烛图高度占比
static CGFloat kTopChartScale = 0.7;
// 蜡烛图起始y
static CGFloat kCanvasMarginTop = 20;
static CGFloat kMinCandleHeight = 1;
static CGFloat kCandleSpacing = 2;
static CGFloat kCandleWidth = 6;
static CGFloat kCanvasMargin = 20;
static CGFloat kCanvasMarginBottom = 10;

// 主副图间距(时间线高度)
static CGFloat kChartSpacing = 10;
static CGFloat kChartBorderWidth = 1;

typedef NS_ENUM(NSUInteger, ENChartType) {
    ENChartTypeMA,
    ENChartTypeEMA,
    ENChartTypeBOLL,
    ENChartTypeMACD,
    ENChartTypeKDJ,
    ENChartTypeRSI,
};

@interface KlineStyle : NSObject


@property (nonatomic, assign) ENChartType topChartType;
@property (nonatomic, assign) ENChartType bottomChartType;
// 捏合缩放比例
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat minScale;
@property (nonatomic, assign) CGFloat maxScale;
@property (nonatomic, assign) CGFloat candle_w;

// 样式
@property (nonatomic, strong) UIColor *upColor;
@property (nonatomic, strong) UIColor *dnColor;

+ (instancetype)style;
+ (CGFloat)getCandleWidthForCount:(NSInteger)showCount canvasWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
