//
//  DKCandleLayer.m
//  KLineDemo
//
//  Created by easy on 2018/6/20.
//  Copyright © 2018年 easy. All rights reserved.
//

#import "DKCandleLayer.h"
#import "CAShapeLayer+kLine.h"

@implementation DKCandleLayer

- (void)layoutSublayers {
    [super layoutSublayers];
    [self draw];
}

- (void)draw {

    [_models enumerateObjectsUsingBlock:^(KLineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGRect frame = CGRectMake(obj.candleX, obj.candleY, obj.candleW, obj.candleH);
        // 涨跌颜色 涨：close >open
        UIColor *candleColor = obj.close.floatValue > obj.open.floatValue ? KlineStyle.style.upColor :KlineStyle.style.dnColor;
        // 蜡烛
        CAShapeLayer *candleLayer = [self drawCandleWithFrame:frame color:candleColor];
        [self addSublayer:candleLayer];
        // 影线
        CAShapeLayer *lineLayer = [self drawLineFromPoint:obj.lineTop toPoint:obj.lineBottom lineWidth:1 color:candleColor];
        [self addSublayer:lineLayer];
    }];

}

@end
