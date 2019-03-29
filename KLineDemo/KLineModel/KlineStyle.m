//
//  KlineStyle.m
//  KLineDemo
//
//  Created by E on 2019/3/18.
//  Copyright © 2019 easy. All rights reserved.
//

#import "KlineStyle.h"
#import "UIColor+KLineTheme.h"

@implementation KlineStyle

static KlineStyle *_style = nil;
+ (instancetype)style {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _style = [[KlineStyle alloc] init];
    });
    return _style;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _scale = 1;
        _minScale = 0.5;
        _maxScale = 3.0;
        _upColor = [UIColor colorWithHex:0x56BD8C];
        _dnColor = [UIColor colorWithHex:0xD32E70];
    }
    return self;
}

+ (CGFloat)getCandleWidthForCount:(NSInteger)showCount canvasWidth:(CGFloat)width {
    CGFloat candle_w = (width - kChartBorderWidth *2) / showCount - kCandleSpacing;
    KlineStyle.style.candle_w = candle_w;
    return candle_w;
}

@end
