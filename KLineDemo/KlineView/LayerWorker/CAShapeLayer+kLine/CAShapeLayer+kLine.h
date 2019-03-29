//
//  CAShapeLayer+kLine.h
//  KLineDemo
//
//  Created by easy on 2018/6/20.
//  Copyright © 2018年 easy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CAShapeLayer (kLine)

- (UIBezierPath *)pathForPoints:(NSArray *)points;
- (instancetype)layerWithPath:(UIBezierPath *)path lineWidth:(CGFloat)width strokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor;
/// 矩形
- (instancetype)drawRectWithFrame:(CGRect)frame strokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor;
/// 不规则图形
- (instancetype)drawRectWithPoints:(NSArray *)points strokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor;
///  快速创建蜡烛
- (instancetype)drawCandleWithFrame:(CGRect)frame color:(UIColor *)color;
/// 画线
- (instancetype)drawLineWithPoints:(NSArray *)pointArray lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)color;
- (instancetype)drawLineFromPoint:(CGPoint)beginPoint toPoint:(CGPoint)endPoint lineWidth:(CGFloat)lineWidth color:(UIColor *)color;
/// 虚线样式
- (void)setDashStyle;

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
                           aligmentMode:(NSString *)aligmentMode;


@end
