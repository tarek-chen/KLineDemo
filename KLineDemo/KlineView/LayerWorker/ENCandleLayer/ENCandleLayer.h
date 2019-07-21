//
//  ENCandleLayer.h
//  KLineDemo
//
//  Created by chen on 2018/6/20.
//  Copyright © 2018年 chen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "KLineModel.h"

@interface ENCandleLayer : CAShapeLayer

@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *lines;

- (void)draw;

@end
