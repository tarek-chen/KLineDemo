//
//  DKTextLayer.h
//  KLineDemo
//
//  Created by easy on 2018/6/20.
//  Copyright © 2018年 easy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface DKTextLayer : CAShapeLayer

@property (nonatomic, strong) NSArray *models;

- (void)draw;

- (void)showTitleInfoAtIndex:(NSInteger)index;
- (void)infoDismiss;


@end
