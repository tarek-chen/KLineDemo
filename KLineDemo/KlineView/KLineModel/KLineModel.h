//
//  KLineModel.h
//  KLineDemo
//
//  Created by easy on 2018/6/12.
//  Copyright © 2018年 easy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KlineStyle.h"

@interface KLineModel : NSObject

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, strong) NSString *vol;
@property (nonatomic, strong) NSString *open;
@property (nonatomic, strong) NSString *close;
@property (nonatomic, strong) NSString *high;
@property (nonatomic, strong) NSString *low;
// 蜡烛坐标
@property (nonatomic, assign) CGFloat candleX;
@property (nonatomic, assign) CGFloat candleY;
@property (nonatomic, assign) CGFloat candleH;
@property (nonatomic, assign) CGFloat candleW;
@property (nonatomic, assign) CGFloat volHeight;
// 影线系数
@property (nonatomic, assign) CGPoint lineTop;
@property (nonatomic, assign) CGPoint lineBottom;
/*
 * MACD
 *
 * 移动平均数分为MA（简单移动平均数）和EMA（指数移动平均数），其计算公式如下：［C为收盘价，N为周期数］：
 * MA（N）=（C1+C2+……CN）/N
 * tips: EMA与MA区别在于EMA加权计算使均线展示更平滑
 */

// MA（7）=（C1+C2+……CN）/7

@property (nonatomic, assign) CGFloat MA5;
@property (nonatomic, assign) CGFloat MA7;
@property (nonatomic, assign) CGFloat MA20;
@property (nonatomic, assign) CGFloat MA25;
@property (nonatomic, assign) CGFloat MA30;
@property (nonatomic, assign) CGFloat MA99;
@property (nonatomic, assign) CGFloat MAV5;
@property (nonatomic, assign) CGFloat MAV7;
@property (nonatomic, assign) CGFloat MAV20;
@property (nonatomic, assign) CGFloat MAV25;
@property (nonatomic, assign) CGFloat MAV30;
@property (nonatomic, assign) CGFloat MAV99;
// EMA
@property (nonatomic, assign) CGFloat EMA7;
@property (nonatomic, assign) CGFloat EMA12;
@property (nonatomic, assign) CGFloat EMA26;
@property (nonatomic, assign) CGFloat EMA30;
@property (nonatomic, assign) CGFloat EMV7;
@property (nonatomic, assign) CGFloat EMV12;
@property (nonatomic, assign) CGFloat EMV26;
@property (nonatomic, assign) CGFloat EMV30;
// BOLL
@property (nonatomic, assign) CGFloat BOLL;
@property (nonatomic, assign) CGFloat UB;
@property (nonatomic, assign) CGFloat DB;

// MACD
@property (nonatomic, assign) CGFloat MACD;
@property (nonatomic, assign) CGFloat DIF;
@property (nonatomic, assign) CGFloat DEA;
@property (nonatomic, assign) CGFloat BAR;
@property (nonatomic, assign) CGFloat RSV;
@property (nonatomic, assign) CGFloat K;
@property (nonatomic, assign) CGFloat D;
@property (nonatomic, assign) CGFloat J;
// RSI
@property (nonatomic, assign) CGFloat RSI;

+ (instancetype)modelWithDict:(NSDictionary *)dict;

- (void)setCandleOriginWithHigh:(CGFloat)high width:(CGFloat)width low:(CGFloat)low unitValue:(CGFloat)unitValue idx:(NSUInteger)idx maxY:(CGFloat)maxY;

#pragma mark - 指标计算

- (void)setMA:(NSInteger)num index:(NSInteger)index models:(NSArray <KLineModel *>*)models;

- (void)setBOLL:(NSInteger)num k:(NSInteger)k index:(NSInteger)index models:(NSArray <KLineModel *>*)models;

- (void)setEMA:(NSInteger)num index:(NSInteger)index models:(NSArray <KLineModel *>*)models;

- (void)setMACD:(NSInteger)p1 p2:(NSInteger)p2 p3:(NSInteger)p3 idx:(NSInteger)idx models:(NSArray <KLineModel *>*)models;

- (void)setRSI:(NSInteger)num idx:(NSInteger)idx models:(NSArray <KLineModel *>*)models;

- (void)setKDJ:(NSInteger)p1 p2:(NSInteger)p2 p3:(NSInteger)p3 index:(NSInteger)index models:(NSArray <KLineModel *>*)models;


@end
