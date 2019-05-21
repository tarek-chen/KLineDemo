//
//  DKTextLayer.m
//  KLineDemo
//
//  Created by chen on 2018/6/20.
//  Copyright © 2018年 chen. All rights reserved.
//

#import "ENTextLayer.h"
#import "KLineModel.h"
#import "CAShapeLayer+kLine.h"
#import "NSString+Attributed.h"

@interface DKTextLayer()

@property (nonatomic, strong) CATextLayer *mainTextLayer;
@property (nonatomic, strong) CATextLayer *bottomTextLayer;
@property (nonatomic, assign) NSInteger index;

@end

@implementation DKTextLayer

static CGFloat kLabelHeight = 14;

- (void)draw {
    
    __block CGFloat bottomY = CGFLOAT_MIN;
    __block CGFloat topY = CGFLOAT_MAX;
    __block KLineModel *topModel, *bottomModel;
	NSInteger unit = _models.count/5;
	NSInteger lastIndex = _models.count-1;
    [_models enumerateObjectsUsingBlock:^(KLineModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if (model.lineTop.y <topY) {
            topY = model.lineTop.y;
            topModel = model;
        }
        if (model.lineBottom.y >bottomY) {
            bottomY = model.lineBottom.y;
            bottomModel = model;
        }
		if (idx == 0) {
			[self drawDateWithModel:model isLeft:YES isRight:NO];
		} else if (idx == lastIndex) {
			[self drawDateWithModel:model isLeft:NO isRight:YES];
		} else if (idx % unit == 0) {
			[self drawDateWithModel:model isLeft:NO isRight:NO];
		}
		
    }];
    
    if (topModel && !isLine) {
        
        [self drawLimitTextForModel:topModel isMax:YES];
        [self drawLimitTextForModel:bottomModel isMax:NO];
    }
}

// 时间线
- (void)drawDateWithModel:(KLineModel *)model isLeft:(BOOL)isLeft isRight:(BOOL)isRight {
	CGFloat font = 8;
	NSString *time = [model.ID candleDate];
	CGFloat labelY = CGRectGetHeight(self.frame) *kTopChartScale + 4;
	CGFloat labelX = 0;
	CGFloat width = UIScreen.mainScreen.bounds.size.width;
	CATextLayerAlignmentMode mode = kCAAlignmentCenter;
	if (isLeft) {
		mode = kCAAlignmentLeft;
	}
	else if (isRight) {
		mode = kCAAlignmentRight;
	} else {
		width = [time textWidthWithHeight:10 andFont:font];
		labelX = model.candleX - width/2;
	}
	CGRect frm = CGRectMake(labelX, labelY, width, 10);
	CATextLayer *date = [self getTextLayerWithString:time textColor:UIColor.whiteColor fontSize:font backgroundColor:UIColor.clearColor frame:frm aligmentMode:mode];
	[self addSublayer:date];
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
    CATextLayer *priceLayer = [self getTextLayerWithString:text textColor:[UIColor whiteColor] fontSize:12 backgroundColor:[UIColor clearColor] frame:frame aligmentMode:aligment];
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
        mainTitle = [NSString stringWithFormat:@"MA(7):%.6f, MA(30):%.6f, MA(99):%.6f", model.MA7, model.MA30, model.MA99];
    }
    else if (isEMA) {
        mainTitle = [NSString stringWithFormat:@"EMA(7):%.6f,EMA(30):%.6f,EMA(99):%.6f", model.EMA7, model.EMA30, model.EMA99];
    }
    else if (isBOLL) {
        mainTitle = [NSString stringWithFormat:@"BOLL:%.6f, UB:%.6f, LB:%.6f", model.BOLL, model.UB, model.DB];
    }
    
    self.mainTextLayer.string = mainTitle;
    
    // 副
    NSString *subTitle;
    if (isMACD) {
        subTitle = [NSString stringWithFormat:@"MACD(12,26,9),MACD:%.6f,DIF:%.6f,DEA:%.6f", model.MACD, model.DIF, model.DEA];
    }
    else if (isKDJ) {
        subTitle = [NSString stringWithFormat:@"K:%.2f, D:%.2f, J:%.2f", model.K, model.D, model.J];
    }
    else if (isRSI) {
        subTitle = [NSString stringWithFormat:@"RSI(6, 12, 24):%.6f, %.6f, %.6f", model.rsi6, model.rsi12, model.rsi24];
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
        _mainTextLayer.backgroundColor = UIColor.blackColor.CGColor;
        _mainTextLayer.contentsScale = UIScreen.mainScreen.scale;
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
        _bottomTextLayer.contentsScale = UIScreen.mainScreen.scale;
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
    CATextLayer *publicLayer = [self getTextLayerWithString:nil textColor:KlineStyle.style.textColor fontSize:8 backgroundColor:UIColor.clearColor frame:frame aligmentMode:kCAAlignmentLeft];
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
    if (!str) {
        return;
    }
    NSArray *subStr = [str componentsSeparatedByString:@","];
    
    NSMutableAttributedString *attStr = str.attributed;
	
	if (isMACD && subStr.count ==4) {
		[attStr cat_ColorText:@[subStr.firstObject] color:UIColor.whiteColor];
		[attStr cat_ColorText:@[subStr[0]] color:KlineStyle.style.color_1];
		[attStr cat_ColorText:@[subStr[1]] color:KlineStyle.style.color_2];
		[attStr cat_ColorText:@[subStr[3]] color:KlineStyle.style.color_3];
	}
	else {
		[attStr cat_ColorText:@[subStr.firstObject] color:KlineStyle.style.color_1];
		if (subStr.count >1) {
			[attStr cat_ColorText:@[subStr[1]] color:KlineStyle.style.color_2];
		}
		if (subStr.count >2) {
			[attStr cat_ColorText:@[subStr[2]] color:KlineStyle.style.color_3];
		}
		
		if (isRSI && subStr.count >=6) {
			[attStr cat_ColorText:@[subStr[3]] color:KlineStyle.style.color_1];
			[attStr cat_ColorText:@[subStr[4]] color:KlineStyle.style.color_2];
			[attStr cat_ColorText:@[subStr[5]] color:KlineStyle.style.color_3];
		}
	}
    // 关闭隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
    layer.string = attStr;
    [CATransaction commit];
}


@end
