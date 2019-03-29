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

@interface DKTextLayer()

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
    
    [self drawTextForModel:topModel isMax:YES];
    [self drawTextForModel:bottomModel isMax:NO];
}

- (void)drawTextForModel:(KLineModel *)model isMax:(BOOL)isMax {
    
    CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width/2;
    CGFloat originX = model.lineTop.x;
    NSString *aligment = kCAAlignmentLeft;
    NSString *priceStr = isMax ?model.high :model.low;
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

@end
