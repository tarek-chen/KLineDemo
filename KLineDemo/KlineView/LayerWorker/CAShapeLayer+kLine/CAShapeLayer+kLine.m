//
//  CAShapeLayer+kLine.m
//  KLineDemo
//
//  Created by easy on 2018/6/20.
//  Copyright © 2018年 easy. All rights reserved.
//

#import "CAShapeLayer+kLine.h"

@implementation CAShapeLayer (kLine)

- (instancetype)drawCandleWithFrame:(CGRect)frame color:(UIColor *)color {
    
    CAShapeLayer *candleLayer = [self drawRectWithFrame:frame strokeColor:[UIColor clearColor] fillColor:color];
    return candleLayer;
}

- (instancetype)drawRectWithFrame:(CGRect)frame strokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor {
    
    // 边蜡烛框路径
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:frame];
    CAShapeLayer *rectLayer = [self layerWithPath:path lineWidth:1 strokeColor:strokeColor fillColor:fillColor];
    return rectLayer;
}

- (instancetype)drawLineFromPoint:(CGPoint)beginPoint toPoint:(CGPoint)endPoint lineWidth:(CGFloat)lineWidth color:(UIColor *)color {
    
    CAShapeLayer *lineLayer = [self drawLineWithPoints:@[@(beginPoint), @(endPoint)] lineWidth:lineWidth lineColor:color];
    return lineLayer;
}
- (instancetype)drawLineWithPoints:(NSArray *)pointArray lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)color {
    
    if (pointArray.count<2) {
        return nil;
    }
    UIBezierPath *path = [self pathForPoints:pointArray];
    CAShapeLayer *lineLayer = [self layerWithPath:path lineWidth:lineWidth strokeColor:color fillColor:[UIColor clearColor]];
    return lineLayer;
}

- (UIBezierPath *)pathForPoints:(NSArray *)points {
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    for (NSInteger index = 0; index <points.count; index++) {
        CGPoint point = [points[index] CGPointValue];
        if (0 == index) {
            [linePath moveToPoint:point];
        } else {
            [linePath addLineToPoint:point];
        }
    }
    return linePath;
}

- (instancetype)layerWithPath:(UIBezierPath *)path lineWidth:(CGFloat)width strokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.lineWidth = width;
    layer.strokeColor = strokeColor.CGColor;
    layer.fillColor = fillColor.CGColor;
    return layer;
}

// 虚线风格
- (void)setDashStyle {
    
    [self setLineJoin:kCALineJoinRound];
    [self setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:10], [NSNumber numberWithInt:5], nil]];
}

#pragma mark - 文字
/*
 @param text 字符串
 @param textColor 文字颜色
 @param bgColor 背景颜色
 @param frame 文字frame
 @return 返回textLayer
 */
- (CATextLayer *)getTextLayerWithString:(NSString *)text
                              textColor:(UIColor *)textColor
                               fontSize:(NSInteger)fontSize
                        backgroundColor:(UIColor *)bgColor
                                  frame:(CGRect)frame
                           aligmentMode:(NSString *)aligmentMode {
    //初始化一个CATextLayer
    CATextLayer *textLayer = [CATextLayer layer];
    //设置文字frame
    textLayer.frame = frame;
    //设置文字
    textLayer.string = text;
    //设置文字大小
    textLayer.fontSize = fontSize;
    //设置文字颜色
    textLayer.foregroundColor = textColor.CGColor;
    //设置背景颜色
    textLayer.backgroundColor = bgColor.CGColor;
    //设置对齐方式
    textLayer.alignmentMode = aligmentMode;
    //设置分辨率
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    
    return textLayer;
}
@end
