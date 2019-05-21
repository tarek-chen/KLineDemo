//
//  ENLineLayer.m
//  KLineDemo
//
//  Created by chen on 2018/6/20.
//  Copyright © 2018年 chen. All rights reserved.
//

#import "ENLineLayer.h"
#import "CAShapeLayer+kLine.h"
#import "KLineDataManager.h"
#import "KlineStyle.h"

@implementation ENLineLayer

#define _data KLineDataManager.manager


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
    CAShapeLayer *MA7Line = [self drawLineWithPoints:_data.MA7Points lineWidth:1 lineColor:kLineColor1];
    [self addSublayer:MA7Line];
    CAShapeLayer *MA30Line = [self drawLineWithPoints:_data.MA30Points lineWidth:1 lineColor:kLineColor2];
    [self addSublayer:MA30Line];
	CAShapeLayer *MA99Line = [self drawLineWithPoints:_data.MA99Points lineWidth:1 lineColor:kLineColor3];
	[self addSublayer:MA99Line];

    
}
- (void)EMA {
    CAShapeLayer *ema7 = [self drawLineWithPoints:_data.EMA7Points lineWidth:1 lineColor:kLineColor1];
    [self addSublayer:ema7];
    CAShapeLayer *ema30 = [self drawLineWithPoints:_data.EMA30Points lineWidth:1 lineColor:kLineColor2];
    [self addSublayer:ema30];
	CAShapeLayer *ema99 = [self drawLineWithPoints:_data.EMA99Points lineWidth:1 lineColor:kLineColor3];
	[self addSublayer:ema99];

}
- (void)BOLL {
    CAShapeLayer *BollLine = [self drawLineWithPoints:_data.BollPoints lineWidth:1 lineColor:kLineColor1];
    [self addSublayer:BollLine];
    CAShapeLayer *UBLine = [self drawLineWithPoints:_data.UBPoints lineWidth:1 lineColor:kLineColor2];
    [self addSublayer:UBLine];
    CAShapeLayer *DBLine = [self drawLineWithPoints:_data.DBPoints lineWidth:1 lineColor:kLineColor3];
    [self addSublayer:DBLine];

}
- (void)MACD {
    CGFloat candle_w = KlineStyle.style.candle_w *KlineStyle.style.scale;
    for (NSInteger i = 0; i < _data.BARPoints.count; i++) {
        KLineModel *model = KLineDataManager.manager.needDraw[i];
        //        CGFloat halfCandleW = KlineStyle.style.candle_w/2;
        CGFloat pointX = model.candleX + candle_w/2;
        CGPoint barPoint = [_data.BARPoints[i] CGPointValue];
        CGPoint minY = CGPointMake(pointX, barPoint.x);
        //            CGFloat minHeight = fabs(barPoint.y - pointX) > 1 : barPoint.y : 1;
        CGPoint maxY = CGPointMake(pointX, barPoint.y);
        UIColor *color = model.BAR >0 ? kCandleUpColor: kCandleDownColor;
        
        CAShapeLayer *barLine = [self drawLineFromPoint:minY toPoint:maxY lineWidth:candle_w color:color];
        [self addSublayer:barLine];
    }
    
    CAShapeLayer *line_DIF = [self drawLineWithPoints:_data.DIFPoints lineWidth:1 lineColor:kLineColor1];
    [self addSublayer:line_DIF];
    CAShapeLayer *line_DEA = [self drawLineWithPoints:_data.DEAPoints lineWidth:1 lineColor:kLineColor2];
    [self addSublayer:line_DEA];

}

- (void)KDJ {
    CAShapeLayer *line_k = [self drawLineWithPoints:_data.KPoints lineWidth:1 lineColor:kLineColor1];
    [self addSublayer:line_k];
    CAShapeLayer *line_d = [self drawLineWithPoints:_data.DPoints lineWidth:1 lineColor:kLineColor2];
    [self addSublayer:line_d];
    CAShapeLayer *line_j = [self drawLineWithPoints:_data.JPoints lineWidth:1 lineColor:kLineColor3];
    [self addSublayer:line_j];

}

- (void)RSI {
	
	CAShapeLayer *rsi = [self drawLineWithPoints:_data.rsi6 lineWidth:1 lineColor:KlineStyle.style.color_1];
	[self addSublayer:rsi];
	CAShapeLayer *rsi12 = [self drawLineWithPoints:_data.rsi12 lineWidth:1 lineColor:KlineStyle.style.color_2];
	[self addSublayer:rsi12];
	CAShapeLayer *rsi24 = [self drawLineWithPoints:_data.rsi24 lineWidth:1 lineColor:KlineStyle.style.color_3];
	[self addSublayer:rsi24];
}

@end
