//
//  KLineDataManager.h
//  KLineDemo
//
//  Created by easy on 2018/6/21.
//  Copyright © 2018年 easy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLineModel.h"
#import "KlineStyle.h"

@interface KLineDataManager : NSObject

// 总数据
@property (nonatomic, strong) NSMutableArray <KLineModel *>*data;
// 展示数据
@property (nonatomic, strong) NSMutableArray *needDraw;
// 展示个数
@property (nonatomic, assign) NSInteger showCount;
// 相对总体数据的起始下标
@property (nonatomic, assign) NSInteger showIndex;

@property (nonatomic, assign) CGFloat canvasHeight;
@property (nonatomic, assign) CGFloat canvasWidth;
// 收盘价
@property (nonatomic, assign) CGFloat maxPrice;
@property (nonatomic, assign) CGFloat minPrice;

@property (nonatomic, strong) NSMutableArray *MA7Points;
@property (nonatomic, strong) NSMutableArray *MA30Points;

@property (nonatomic, strong) NSMutableArray *EMA7Points;
@property (nonatomic, strong) NSMutableArray *EMA30Points;

// BOLL
@property (nonatomic, strong) NSMutableArray *BollPoints;
@property (nonatomic, strong) NSMutableArray *UBPoints;
@property (nonatomic, strong) NSMutableArray *DBPoints;

// MACD
@property (nonatomic, assign) CGFloat macd_min;
@property (nonatomic, assign) CGFloat macd_max;
@property (nonatomic, strong) NSMutableArray *DIFPoints;
@property (nonatomic, strong) NSMutableArray *DEAPoints;
@property (nonatomic, strong) NSMutableArray *BARPoints;


// KDJ
@property (nonatomic, assign) CGFloat kdj_min;
@property (nonatomic, assign) CGFloat kdj_max;
@property (nonatomic, strong) NSMutableArray *KPoints;
@property (nonatomic, strong) NSMutableArray *DPoints;
@property (nonatomic, strong) NSMutableArray *JPoints;

// RSI
@property (nonatomic, assign) CGFloat rsi_min;
@property (nonatomic, assign) CGFloat rsi_max;
@property (nonatomic, strong) NSMutableArray *RSIPoints;



+ (instancetype)manager;
- (void)addNewData:(KLineModel *)model;
// 取出显示数据
//getCandleData
@end