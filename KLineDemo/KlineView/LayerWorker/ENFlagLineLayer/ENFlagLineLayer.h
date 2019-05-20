//
//  ENFlagLineLayer.h
//  KLineDemo
//
//  Created by chen on 2018/6/20.
//  Copyright © 2018年 chen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KlineStyle.h"

@interface ENFlagLineLayer : CAShapeLayer

@property (nonatomic, strong) NSArray *models;

// 长按辅助线
- (void)showFlagLineAtIndex:(NSInteger)index;

- (void)didmiss;

@end
