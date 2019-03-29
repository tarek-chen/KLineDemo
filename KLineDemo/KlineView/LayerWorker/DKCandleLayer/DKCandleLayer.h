//
//  DKCandleLayer.h
//  KLineDemo
//
//  Created by easy on 2018/6/20.
//  Copyright © 2018年 easy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "KLineModel.h"

@interface DKCandleLayer : CAShapeLayer

@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *lines;

- (void)draw;

@end
