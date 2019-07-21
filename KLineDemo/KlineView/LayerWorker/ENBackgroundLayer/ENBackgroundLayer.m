//
//  ENBackgroundLayer.m
//  KLineDemo
//
//  Created by chen on 2018/6/20.
//  Copyright © 2018年 chen. All rights reserved.
//

#import "ENBackgroundLayer.h"
#import "UIColor+KLineTheme.h"
#import "CAShapeLayer+kLine.h"
#import "KlineStyle.h"

@interface ENBackgroundLayer()

@property (nonatomic, strong) UIBezierPath *topChartPath;
@property (nonatomic, strong) CAShapeLayer *topChartBG;
@property (nonatomic, strong) CAShapeLayer *dashCenterLine;
@property (nonatomic, strong) UIBezierPath *bottomChartPath;
@property (nonatomic, strong) CAShapeLayer *bottomChartBG;

@end

@implementation ENBackgroundLayer

- (void)layoutSublayers {
    [super layoutSublayers];
    
    [self drawBackgroundLayer];
}

- (UIBezierPath *)topChartPath {
    
    if (!_topChartPath && !CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
        CGFloat _W = CGRectGetWidth(self.frame);
        CGFloat _H = CGRectGetHeight(self.frame);
        CGRect frame = CGRectMake(kChartBorderWidth, 0, _W - kChartBorderWidth*2,  _H *kTopChartScale);
        _topChartPath = [UIBezierPath bezierPathWithRect:frame];
        
        // 中分线
        CGFloat lineY = _H *kTopChartScale /2;
        self.dashCenterLine = [self drawLineFromPoint:CGPointMake(kChartBorderWidth, lineY) toPoint:CGPointMake(_W, lineY) lineWidth:kChartBorderWidth color:[UIColor colorWithHex:0x343B44]];
        [self.dashCenterLine setDashStyle];
        [self addSublayer:self.dashCenterLine];
    }
    return _topChartPath;
}

- (UIBezierPath *)bottomChartPath {
    
    if (!_bottomChartPath && !CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
        CGFloat _W = CGRectGetWidth(self.frame);
        CGFloat _H = CGRectGetHeight(self.frame);
        CGFloat chartY = _H *kTopChartScale + kChartSpacing;
        CGRect frame = CGRectMake(kChartBorderWidth, chartY, _W - kChartBorderWidth*2,  _H - chartY);
        _bottomChartPath = [UIBezierPath bezierPathWithRect:frame];
    }
    return _bottomChartPath;
}


- (void)drawBackgroundLayer {
    if (self.topChartBG && self.topChartPath) {
        self.topChartBG.path = self.topChartPath.CGPath;
    } else if (self.topChartPath) {
        _topChartBG = [self layerWithPath:self.topChartPath lineWidth:kChartBorderWidth strokeColor:[UIColor colorWithHex:0x343B44] fillColor:[UIColor clearColor]];
        [self addSublayer:_topChartBG];
    }
    
    if (self.bottomChartBG && self.bottomChartPath) {
        self.bottomChartBG.path = self.bottomChartPath.CGPath;
    } else if (self.bottomChartPath) {
        _bottomChartBG = [self layerWithPath:self.bottomChartPath lineWidth:kChartBorderWidth strokeColor:[UIColor colorWithHex:0x343B44] fillColor:[UIColor clearColor]];
        [self addSublayer:_bottomChartBG];
    }
}

@end
