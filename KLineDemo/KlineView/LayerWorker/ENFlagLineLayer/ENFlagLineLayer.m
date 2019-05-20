//
//  ENFlagLineLayer.m
//  KLineDemo
//
//  Created by chen on 2018/6/20.
//  Copyright © 2018年 chen. All rights reserved.
//

#import "ENFlagLineLayer.h"
#import <UIKit/UIKit.h>
#import "KLineModel.h"
#import "CAShapeLayer+kLine.h"

@interface ENFlagLineLayer()

// 竖线
@property (nonatomic, strong) CAShapeLayer *lineVertical;
// 横线
@property (nonatomic, strong) CAShapeLayer *lineHorizontal;

@property (nonatomic, assign) NSInteger flagIndex;

@property (nonatomic, strong) CATextLayer *flagCloseLayer;
@end


@implementation ENFlagLineLayer
static CGFloat kFlagLineWidth = .3f;

#pragma mark - 长按辅助线
- (CAShapeLayer *)lineVertical {
    if (!_lineVertical) {
        _lineVertical = [self drawLineFromPoint:CGPointZero toPoint:CGPointMake(0, CGRectGetHeight(self.frame)) lineWidth:kFlagLineWidth color:[UIColor whiteColor]];
        _lineVertical.hidden = YES;
        [self addSublayer:_lineVertical];
    }
    
    return _lineVertical;
}

// 水平线
- (CAShapeLayer *)lineHorizontal {
    if (!_lineHorizontal) {
        _lineHorizontal = [self drawLineFromPoint:CGPointZero toPoint:CGPointMake(CGRectGetWidth(self.frame), 0) lineWidth:kFlagLineWidth color:[UIColor whiteColor]];
        _lineHorizontal.hidden = YES;
        [self addSublayer:_lineHorizontal];
    }
    
    return _lineHorizontal;
}

// 水平辅助线左侧收盘价
- (CATextLayer *)flagCloseLayer {
    if (!_flagCloseLayer) {
        _flagCloseLayer = [self getTextLayerWithString:@"0.00" textColor:[UIColor whiteColor] fontSize:12.0 backgroundColor:[UIColor grayColor] frame:CGRectMake(0, 0, 100, 15) aligmentMode:kCAAlignmentLeft];
        _flagCloseLayer.hidden = YES;
        [self addSublayer:_flagCloseLayer];
    }
    return _flagCloseLayer;
}


- (void)showFlagLineAtIndex:(NSInteger)index {

    if (_flagIndex != index && index < _models.count) {
        KLineModel *model = _models[index];

        // 横线
        CGFloat horPositionY = model.candleY;
        //  红跌蜡烛取maxY
        if (model.open.floatValue > model.close.floatValue && !isLine) {
            horPositionY = model.candleY+model.candleH;
        }
        
        
        // 左侧标记收盘价格
        NSString *closeText = [NSString stringWithFormat:@"%.4f", model.close.floatValue];
        CGFloat textWidth = [self textWidthWithHeight:15 andFont:12 text:closeText];

        // 关闭隐式动画
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.lineHorizontal.frame = CGRectMake(0, horPositionY, kFlagLineWidth, CGRectGetHeight(_lineHorizontal.frame));
        // 竖线
        self.lineVertical.frame = CGRectMake(model.lineTop.x, 0, kFlagLineWidth, CGRectGetHeight(_lineVertical.frame));
        self.flagCloseLayer.frame = CGRectMake(0, horPositionY-7.5, textWidth, 15);
        
        if (_lineHorizontal.hidden) {
            _lineHorizontal.hidden = NO;
            _lineVertical.hidden = NO;
            _flagCloseLayer.hidden = NO;
        }
        [CATransaction commit];
        self.flagCloseLayer.string = closeText;

        _flagIndex = index;

    }
}

- (void)didmiss {
    _lineVertical.hidden = YES;
    _lineHorizontal.hidden = YES;
    _flagCloseLayer.hidden = YES;
}

- (CGFloat)textWidthWithHeight:(CGFloat)height andFont:(CGFloat)font text:(NSString *)text {
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:font]};
    CGSize size = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height)  options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)   attributes:attribute context:nil].size;
    return size.width;
}


@end
