//
//  ENLineLayer.m
//  KLineDemo
//
//  Created by easy on 2018/6/20.
//  Copyright © 2018年 easy. All rights reserved.
//

#import "ENLineLayer.h"
#import "CAShapeLayer+kLine.h"
#import "KLineDataManager.h"
#import "KlineStyle.h"

@implementation ENLineLayer

- (void)drawLines {
    ENChartType top = KlineStyle.style.topChartType;
    switch (top) {
        case ENChartTypeMA:
            [self MA];
            break;
        case ENChartTypeEMA:
            [self EMA];
            break;
        case ENChartTypeBOLL:
            [self BOLL];
            break;
      
        default:
            break;
    }
    
    ENChartType bottom = KlineStyle.style.bottomChartType;
    switch (bottom) {
        case ENChartTypeMACD:
            [self MACD];
            break;
        case ENChartTypeKDJ:
            [self KDJ];
            break;
        case ENChartTypeRSI:
            [self RSI];
            break;
        default:
            break;
    }
 
}

- (void)MA {
    
    CAShapeLayer *MA7Line = [self drawLineWithPoints:_ma7Points lineWidth:1 lineColor:kLineColor1];
    [self addSublayer:MA7Line];
    CAShapeLayer *MA30Line = [self drawLineWithPoints:_ma30Points lineWidth:1 lineColor:kLineColor2];
    [self addSublayer:MA30Line];
    
}
- (void)EMA {
    CAShapeLayer *ema7 = [self drawLineWithPoints:_ema7Points lineWidth:1 lineColor:kLineColor1];
    [self addSublayer:ema7];
    CAShapeLayer *ema30 = [self drawLineWithPoints:_ema30Points lineWidth:1 lineColor:kLineColor2];
    [self addSublayer:ema30];

}
- (void)BOLL {
    CAShapeLayer *BollLine = [self drawLineWithPoints:_BOLLPoints lineWidth:1 lineColor:kLineColor1];
    [self addSublayer:BollLine];
    CAShapeLayer *UBLine = [self drawLineWithPoints:_UBPoints lineWidth:1 lineColor:kLineColor2];
    [self addSublayer:UBLine];
    CAShapeLayer *DBLine = [self drawLineWithPoints:_DBPoints lineWidth:1 lineColor:kLineColor3];
    [self addSublayer:DBLine];

}
- (void)MACD {
    CGFloat candle_w = KlineStyle.style.candle_w *KlineStyle.style.scale;
    for (NSInteger i = 0; i < _BARPoints.count; i++) {
        KLineModel *model = KLineDataManager.manager.needDraw[i];
        //        CGFloat halfCandleW = KlineStyle.style.candle_w/2;
        CGFloat pointX = model.candleX + candle_w/2;
        CGPoint barPoint = [_BARPoints[i] CGPointValue];
        CGPoint minY = CGPointMake(pointX, barPoint.x);
        //            CGFloat minHeight = fabs(barPoint.y - pointX) > 1 : barPoint.y : 1;
        CGPoint maxY = CGPointMake(pointX, barPoint.y);
        UIColor *color = model.BAR >0 ? kCandleUpColor: kCandleDownColor;
        
        CAShapeLayer *barLine = [self drawLineFromPoint:minY toPoint:maxY lineWidth:candle_w color:color];
        [self addSublayer:barLine];
    }
    
    CAShapeLayer *line_DIF = [self drawLineWithPoints:_DIFPoints lineWidth:1 lineColor:kLineColor1];
    [self addSublayer:line_DIF];
    CAShapeLayer *line_DEA = [self drawLineWithPoints:_DEAPoints lineWidth:1 lineColor:kLineColor2];
    [self addSublayer:line_DEA];

}

- (void)KDJ {
    CAShapeLayer *line_k = [self drawLineWithPoints:_KPoints lineWidth:1 lineColor:kLineColor1];
    [self addSublayer:line_k];
    CAShapeLayer *line_d = [self drawLineWithPoints:_DPoints lineWidth:1 lineColor:kLineColor2];
    [self addSublayer:line_d];
    CAShapeLayer *line_j = [self drawLineWithPoints:_JPoints lineWidth:1 lineColor:kLineColor3];
    [self addSublayer:line_j];

}

- (void)RSI {
    CAShapeLayer *rsi = [self drawLineWithPoints:_RSIPoints lineWidth:1 lineColor:KlineStyle.style.color_1];
    [self addSublayer:rsi];
}

@end
