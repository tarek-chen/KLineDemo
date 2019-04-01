//
//  ENCandleLayer.m
//  KLineDemo
//
//  Created by easy on 2018/6/20.
//  Copyright © 2018年 easy. All rights reserved.
//

#import "ENCandleLayer.h"
#import "CAShapeLayer+kLine.h"

@implementation ENCandleLayer

- (void)layoutSublayers {
    [super layoutSublayers];
    [self draw];
}

- (void)draw {
    
    // 分时
    if (isLine) {
        [self drawLineChart];
    }

    [_models enumerateObjectsUsingBlock:^(KLineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
       if (!isLine) {
            [self drawCandleChart:obj];
        }
        
        // vol
        if (ENChartTypeVOL == KlineStyle.style.bottomChartType) {
            [self drawVolChart:obj];
        }
    }];

}

// 分时
- (void)drawLineChart {
    
    // 顶部折线
    CAShapeLayer *line = [self drawLineWithPoints:_lines lineWidth:1 lineColor:KlineStyle.style.color_Line];
    [self addSublayer:line];
    // 透明层
    NSMutableArray *points = @[].mutableCopy;
    // 起点
    CGFloat maxY = CGRectGetHeight(self.frame) *kTopChartScale;
    CGPoint start = CGPointMake([_lines.firstObject CGPointValue].x, maxY);
    // 终点
    CGPoint end = CGPointMake([_lines.lastObject CGPointValue].x, maxY);
    [points addObject:@(start)];
    [points addObjectsFromArray:_lines];
    [points addObject:@(end)];
    [points addObject:@(start)];
    CAShapeLayer *bg = [self drawRectWithPoints:points strokeColor:UIColor.clearColor fillColor:KlineStyle.style.color_AlphaLine];
    [self addSublayer:bg];
}

// 蜡烛
- (void)drawCandleChart:(KLineModel *)obj {
    
    CGRect frame = CGRectMake(obj.candleX, obj.candleY, obj.candleW, obj.candleH);
    // 涨跌颜色 涨：close >open
    UIColor *candleColor = obj.close.floatValue > obj.open.floatValue ? KlineStyle.style.color_up :KlineStyle.style.color_dn;
    // 蜡烛
    CAShapeLayer *candleLayer = [self drawCandleWithFrame:frame color:candleColor];
    [self addSublayer:candleLayer];
    // 影线
    CAShapeLayer *lineLayer = [self drawLineFromPoint:obj.lineTop toPoint:obj.lineBottom lineWidth:1 color:candleColor];
    [self addSublayer:lineLayer];
}

// 副图vol的柱形图
- (void)drawVolChart:(KLineModel *)obj {
   
    CGFloat maxY = CGRectGetHeight(self.frame) - kSubChartMarginBottom;
    CGFloat candle_w = KlineStyle.style.candle_w *KlineStyle.style.scale;
    //        CGFloat halfCandleW = KlineStyle.style.candle_w/2;
    CGFloat pointX = obj.candleX + candle_w/2;
    CGPoint minY = CGPointMake(pointX, maxY - obj.volHeight);
    //            CGFloat minHeight = fabs(barPoint.y - pointX) > 1 : barPoint.y : 1;
    CGPoint pointMaxY = CGPointMake(pointX, maxY);
    UIColor *color = obj.close.floatValue > obj.open.floatValue ? KlineStyle.style.color_up : KlineStyle.style.color_dn;
    CAShapeLayer *barLine = [self drawLineFromPoint:minY toPoint:pointMaxY lineWidth:candle_w color:color];
    [self addSublayer:barLine];
}

@end
