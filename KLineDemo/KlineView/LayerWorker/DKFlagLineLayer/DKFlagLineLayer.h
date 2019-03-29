//
//  DKFlagLineLayer.h
//  KLineDemo
//
//  Created by easy on 2018/6/20.
//  Copyright © 2018年 easy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "KlineStyle.h"

@interface DKFlagLineLayer : CAShapeLayer

@property (nonatomic, strong) NSArray *models;

// 长按辅助线
- (void)showFlagLineOnPoint:(CGPoint)point;

- (void)flagWorkDidmiss;

@end
