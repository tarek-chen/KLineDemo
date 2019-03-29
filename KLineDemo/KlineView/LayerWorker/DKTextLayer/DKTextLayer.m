//
//  DKTextLayer.m
//  KLineDemo
//
//  Created by easy on 2018/6/20.
//  Copyright © 2018年 easy. All rights reserved.
//

#import "DKTextLayer.h"
#import "KLineModel.h"
#import "CAShapeLayer+kLine.h"
#import "NSString+Attributed.h"

@interface DKTextLayer()

@property (nonatomic, strong) CATextLayer *mainTextLayer;
@property (nonatomic, strong) CATextLayer *bottomTextLayer;
@property (nonatomic, assign) NSInteger index;

@end

@implementation DKTextLayer

static CGFloat kLabelHeight = 15;

- (void)draw {
    __block CGFloat bottomY = CGFLOAT_MIN;
    __block CGFloat topY = CGFLOAT_MAX;
    __block KLineModel *topModel, *bottomModel;
    [_models enumerateObjectsUsingBlock:^(KLineModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (model.lineTop.y <topY) {
            topY = model.lineTop.y;
            topModel = model;
        }
        if (model.lineBottom.y >bottomY) {
            bottomY = model.lineBottom.y;
            bottomModel = model;
        }
    }];
    
    if (topModel) {
        
        [self drawLimitTextForModel:topModel isMax:YES];
        [self drawLimitTextForModel:bottomModel isMax:NO];
    }
}

// 极值价格
- (void)drawLimitTextForModel:(KLineModel *)model isMax:(BOOL)isMax {
    
    CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width/2;
    CGFloat originX = model.lineTop.x;
    NSString *aligment = kCAAlignmentLeft;
    NSString *priceStr = isMax ?model.high :model.low;
    priceStr = [NSString stringWithFormat:@"%.4f", priceStr.floatValue];
    NSString *text = [NSString stringWithFormat:@"←%@", priceStr];
    if (originX > CGRectGetWidth(self.frame)/2) {
        originX -= labelWidth;
        aligment = kCAAlignmentRight;
        text = [NSString stringWithFormat:@"%@→", priceStr];
    }
    
    CGFloat originY = isMax ? model.lineTop.y : model.lineBottom.y;
    if (isMax) {
        originY -= kLabelHeight;
    }
    CGRect frame = CGRectMake(originX, originY, labelWidth, kLabelHeight);
    CATextLayer *priceLayer = [self getTextLayerWithString:text textColor:[UIColor whiteColor] fontSize:10 backgroundColor:[UIColor clearColor] frame:frame aligmentMode:aligment];
    [self addSublayer:priceLayer];
}

// 长按展示指标
- (void)showTitleInfoAtIndex:(NSInteger)index {
    
    KLineModel *model;
    if (_models.count >index && _index != index) {
        model = _models[index];
    } else {
        return;
    }
    _index = index;
    
    // 主图表
    NSString *mainTitle;
    if (isMA) {
        mainTitle = [NSString stringWithFormat:@"MA(7):%.6f, MA(30):%.6f", model.MA7, model.MA30];
    }
    else if (isEMA) {
        mainTitle = [NSString stringWithFormat:@"EMA(7):%.6f,EMA(30):%.6f", model.EMA7, model.EMA30];
    }
    else if (isBOLL) {
        mainTitle = [NSString stringWithFormat:@"BOLL:%.6f, UB:%.6f, LB:%.6f", model.BOLL, model.UB, model.DB];
    }
    self.mainTextLayer.string = mainTitle;
    
    // 副
    NSString *subTitle;
    if (isMACD) {
        subTitle = [NSString stringWithFormat:@"MACD:%.6f, DIF:%.6f, DEA:%.6f", model.MACD, model.DIF, model.DEA];
    }
    else if (isKDJ) {
        subTitle = [NSString stringWithFormat:@"K:%.2f, D:%.2f, J:%.2f", model.K, model.D, model.J];
    }
    else if (isRSI) {
        subTitle = [NSString stringWithFormat:@"RSI(12):%.6f", model.RSI];
    }
    else if (isVOL) {
        subTitle = [NSString stringWithFormat:@"VOL:%@", model.volText];
    }
    self.bottomTextLayer.string = subTitle;
    
    
    // 染色
    [self autoColor];
}

- (void)infoDismiss {
    
    self.mainTextLayer.hidden = YES;
    self.bottomTextLayer.hidden = YES;
}

// 指标信息
- (CATextLayer *)mainTextLayer {
    if (!_mainTextLayer) {
        _mainTextLayer = [self getPublicTextLayerWithY:2];
        [self addSublayer:_mainTextLayer];
    }
    if (_mainTextLayer.hidden) {
        _mainTextLayer.hidden = NO;
    }
    return _mainTextLayer;
}

- (CATextLayer *)bottomTextLayer {
    if (!_bottomTextLayer) {
        CGFloat y = CGRectGetHeight(self.frame) * kTopChartScale + kChartSpacing + 2;
        _bottomTextLayer = [self getPublicTextLayerWithY:y];
        [self addSublayer:_bottomTextLayer];
    }
    if (_bottomTextLayer.hidden) {
        _bottomTextLayer.hidden = NO;
    }
    return _bottomTextLayer;
}

// 通用绘制左侧文字方法
- (CATextLayer *)getPublicTextLayerWithY:(CGFloat)y {
    CGFloat _x = 10;
    CGRect frame = CGRectMake(_x, y, UIScreen.mainScreen.bounds.size.width, kLabelHeight);
    CATextLayer *publicLayer = [self getTextLayerWithString:nil textColor:KlineStyle.style.textColor fontSize:10 backgroundColor:UIColor.clearColor frame:frame aligmentMode:kCAAlignmentLeft];
    return publicLayer;
}

// 自动染色
- (void)autoColor {
    [self colorTextLayer:self.mainTextLayer];
    [self colorTextLayer:self.bottomTextLayer];
}
// 通用染色方法
- (void)colorTextLayer:(CATextLayer *)layer {
    
    NSString *str = layer.string;
    NSArray *subStr = [str componentsSeparatedByString:@","];
    
    NSMutableAttributedString *attStr = str.attributed;
    [attStr cat_ColorText:@[subStr.firstObject] color:KlineStyle.style.color_1];
    if (subStr.count >1) {
        [attStr cat_ColorText:@[subStr[1]] color:KlineStyle.style.color_2];
    }
    if (subStr.count >2) {
        [attStr cat_ColorText:@[subStr[2]] color:KlineStyle.style.color_3];
    }
    layer.string = attStr;
}


@end
