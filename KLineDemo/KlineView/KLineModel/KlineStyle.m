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
        // 默认样式
        _style.topChartType = ENChartTypeMA;
        _style.bottomChartType = ENChartTypeVOL;
        // 默认颜色
        
    });
    return _style;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _scale = 1;
        _minScale = 0.5;
        _maxScale = 3.0;
        _color_Line =
        
        _textColor = UIColor.whiteColor;
        _color_up = [UIColor colorWithHex:0x56BD8C];
        _color_dn = [UIColor colorWithHex:0xC15465];
        _color_Line = [UIColor colorWithHex:0x6DB2EC];
        _color_AlphaLine = [UIColor colorWithRed:109/255.0 green:178/255.0 blue:238/255.0 alpha:0.1];
        _color_1 = [UIColor colorWithHex:0xE4D295];
        _color_2 = [UIColor colorWithHex:0x73BBB0];
        _color_3 = [UIColor colorWithHex:0xB58BE8];
        _color_text1 = [UIColor colorWithHex:0x6226ED];
    }
    return self;
}

+ (CGFloat)getCandleWidthForCount:(NSInteger)showCount canvasWidth:(CGFloat)width {
    CGFloat candle_w = (width - kChartBorderWidth *2) / showCount - kCandleSpacing;
    KlineStyle.style.candle_w = candle_w;
    return candle_w;
}

@end
