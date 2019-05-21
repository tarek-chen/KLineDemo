//
//  KLineDataManager.m
//  KLineDemo
//
//  Created by chen on 2018/6/21.
//  Copyright © 2018年 chen. All rights reserved.
//

#import "KLineDataManager.h"

@implementation KLineDataManager

static KLineDataManager *_manager = nil;
+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [KLineDataManager new];
        
        // 默认蜡烛个数
        _manager.showCount = 40;
        _manager.showIndex = 0;
    });
    return _manager;
}

// 滑动
- (void)setShowIndex:(NSInteger)showIndex {
    
    // 滑动范围
    BOOL minIndex = showIndex >=0;
    BOOL canDraw = showIndex + _showCount <= _data.count;
    
    if (_showIndex != showIndex && _data.count > 0 && minIndex && canDraw) {
        
        _showIndex = showIndex;

        // 控制滑动范围
        if (_showIndex <0) {
            _showIndex = 0;
        } else if (_showIndex + _showCount > _data.count) {
            
            _showIndex = _data.count - _showCount;
        }
        // 刷新
        [self refreshData];
    }
}

// 数据源
- (void)setData:(NSMutableArray *)data {
    
    if (!_data || _data.count <0) {
        _data = data;
        // 相对总数据源的起始下标
        _showIndex = _data.count - _showCount;
    }
    // 指标计算
    [_data enumerateObjectsUsingBlock:^(KLineModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [self makeData:model index:idx];
    }];
    
    [self refreshData];
}

// 指标计算
- (void)makeData:(KLineModel *)model index:(NSInteger)idx {
    
    [model setMA:7 index:idx models:_data];
    [model setMA:20 index:idx models:_data];
    [model setMA:30 index:idx models:_data];
    [model setMA:25 index:idx models:_data];
    [model setMA:99 index:idx models:_data];
    [model setEMA:7 index:idx models:_data];
    [model setEMA:30 index:idx models:_data];
    [model setEMA:12 index:idx models:_data];
	[model setEMA:26 index:idx models:_data];
	[model setEMA:99 index:idx models:_data];
    [model setBOLL:20 k:2 index:idx models:_data];
    [model setKDJ:9 p2:3 p3:3 index:idx models:_data];
//    [model setKDJ:14 p2:1 p3:3 index:idx models:self.data];
    [model setMACD:12 p2:26 p3:9 idx:idx models:_data];
	[model setRSI:6 idx:idx models:_data];
	[model setRSI:12 idx:idx models:_data];
	[model setRSI:24 idx:idx models:_data];
}

- (void)addNewData:(KLineModel *)model {
    
    // 指标计算
    [self makeData:model index:_data.count -1];

    BOOL isNew = ![_data.lastObject.ID isEqualToString: model.ID];
    if (isNew) {
        
        [_data addObject:model];
        _showIndex++;
    } else {
        [_data replaceObjectAtIndex:_data.count -1 withObject:model];
        [self refreshData];
    }
}

// 刷新计算
- (void)refreshData {
    [KlineStyle getCandleWidthForCount:_showCount canvasWidth:_canvasWidth];
    // 蜡烛数据
    [self getCandleData];
    
    [self getLimitPrice];
    
    [self getPathPoints];
}

// 取展示数据
- (void)getCandleData {

    // 少量蜡烛时待处理
    // 兼容滑动范围
    if (_data.count < _showCount) {
        return;
    }
    _needDraw = @[].mutableCopy;

    // 添加MA30参考数据
    NSInteger fromIndex = _showIndex;

    NSRange showRange = NSMakeRange(fromIndex, _showCount);
    [_needDraw addObjectsFromArray:[_data subarrayWithRange:showRange]];

}

// 计算最高价和最低价
- (void)getLimitPrice {
    
    __block CGFloat minPrice = CGFLOAT_MAX;
    __block CGFloat maxPrice = CGFLOAT_MIN;
    __block CGFloat minVol = CGFLOAT_MAX;
    __block CGFloat maxVol = CGFLOAT_MIN;

    __block CGFloat boll_min = CGFLOAT_MAX;
    __block CGFloat boll_max = CGFLOAT_MIN;
    
    __block CGFloat macd_min = CGFLOAT_MAX;
    __block CGFloat macd_max = CGFLOAT_MIN;
    
    __block CGFloat kdj_min = CGFLOAT_MAX;
    __block CGFloat kdj_max = CGFLOAT_MIN;

    __block CGFloat rsi_min = CGFLOAT_MAX;
    __block CGFloat rsi_max = CGFLOAT_MIN;
    // 获取数组中高低价极值
    [_needDraw enumerateObjectsUsingBlock:^(KLineModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        // 高低极值

        maxPrice = MAX(maxPrice, model.high.floatValue);
        minPrice = MIN(minPrice, model.low.floatValue);
        if (model.MA7) {
            minPrice = MIN(minPrice, model.MA7);
            maxPrice = MAX(maxPrice, model.MA7);
        }
        if (model.MA30) {
            minPrice = MIN(minPrice, model.MA30);
            maxPrice = MAX(maxPrice, model.MA30);
        }
		if (model.MA99) {
			minPrice = MIN(minPrice, model.MA99);
			maxPrice = MAX(maxPrice, model.MA99);
		}
        
        minVol = MIN(minVol, model.vol.floatValue);
        maxVol = MAX(maxVol, model.vol.floatValue);
        
        // EMA
        if (model.EMA7) {
            minPrice = MIN(minPrice, model.EMA7);
            maxPrice = MAX(maxPrice, model.EMA7);
        }
		if (model.EMA30) {
			minPrice = MIN(minPrice, model.EMA30);
			maxPrice = MAX(maxPrice, model.EMA30);
		}
		if (model.EMA99) {
			minPrice = MIN(minPrice, model.EMA99);
			maxPrice = MAX(maxPrice, model.EMA99);
		}
        // BOLL
        if ([self.data indexOfObject:model] >18) {
            boll_min = MIN(boll_min, model.DB);
            boll_max = MAX(boll_max, model.UB);
//            minPrice = MIN(minPrice, model.DB);
//            maxPrice = MAX(maxPrice, model.UB);
        }

        // MACD
        macd_min = MIN(macd_min, model.DIF);
        macd_min = MIN(macd_min, model.DEA);
        macd_min = MIN(macd_min, model.BAR);
        macd_max = MAX(macd_max, model.DIF);
        macd_max = MAX(macd_max, model.DEA);
        macd_max = MAX(macd_max, model.BAR);

        // KDJ limit
        kdj_min = MIN(kdj_min, model.K);
        kdj_min = MIN(kdj_min, model.D);
        kdj_min = MIN(kdj_min, model.J);
        kdj_max = MAX(kdj_max, model.K);
        kdj_max = MAX(kdj_max, model.D);
        kdj_max = MAX(kdj_max, model.J);
        
        // RSI
		rsi_min = MIN(rsi_min, model.rsi6);
		rsi_max = MAX(rsi_max, model.rsi6);
		rsi_min = MIN(rsi_min, model.rsi12);
		rsi_max = MAX(rsi_max, model.rsi12);
		rsi_min = MIN(rsi_min, model.rsi24);
		rsi_max = MAX(rsi_max, model.rsi24);
    }];
    _maxPrice = maxPrice;
    _minPrice = minPrice;

    _minVol = minVol;
    _maxVol = maxVol;
    
    if (isBOLL) {
        
        _minPrice = MIN(boll_min, minPrice);
        _maxPrice = MAX(boll_max, maxPrice);
    }
    
    
    _macd_min = macd_min;
    _macd_max = macd_max;
    
    _kdj_min = kdj_min;
    _kdj_max = kdj_max;
    
    _rsi_min = rsi_min;
    _rsi_max = rsi_max;
}

// MA线路径
- (void)getPathPoints {
    
    // 调整蜡烛可绘制范围
    CGFloat maxY = _canvasHeight *kTopChartScale - kMainChartMarginBottom;
    CGFloat unitDistance = (_maxPrice - _minPrice) / (maxY - kMainChartMarginTop);
    CGFloat candle_half = KlineStyle.style.candle_w/2;
    __block NSMutableArray *MA7Points = @[].mutableCopy;
	__block NSMutableArray *MA30Points = @[].mutableCopy;
	__block NSMutableArray *MA99Points = @[].mutableCopy;

    __block NSMutableArray *EMA7Points = @[].mutableCopy;
	__block NSMutableArray *EMA30Points = @[].mutableCopy;
	__block NSMutableArray *EMA99Points = @[].mutableCopy;
    // BOLL
    __block NSMutableArray *BOLL = @[].mutableCopy;
    __block NSMutableArray *UB = @[].mutableCopy;
    __block NSMutableArray *DB = @[].mutableCopy;
    
    // 副图高度
    CGFloat subChart_h = _canvasHeight * (1 - kTopChartScale) -kChartSpacing - kSubChartMarginTop- kSubChartMarginBottom;
    // Vol
    CGFloat unit_vol = fabs(_maxVol - _minVol) / subChart_h;
    // MACD
    CGFloat unit_macd = fabs(_macd_max - _macd_min) / subChart_h;
    __block NSMutableArray *DIFPoints = @[].mutableCopy;
    __block NSMutableArray *DEAPoints = @[].mutableCopy;
    __block NSMutableArray *BARPoints = @[].mutableCopy;

    // KDJ
    CGFloat unit_kdj = fabs(_kdj_max - _kdj_min) / subChart_h;
    __block NSMutableArray *kPoints = @[].mutableCopy;
    __block NSMutableArray *dPoints = @[].mutableCopy;
    __block NSMutableArray *jPoints = @[].mutableCopy;
    
    // RSI
    CGFloat unit_rsi = fabs(_rsi_max - _rsi_min) / subChart_h;
	__block NSMutableArray *rsi6 = @[].mutableCopy;
	__block NSMutableArray *rsi12 = @[].mutableCopy;
	__block NSMutableArray *rsi24 = @[].mutableCopy;
    // line
    __block NSMutableArray *line = @[].mutableCopy;

    [_needDraw enumerateObjectsUsingBlock:^(KLineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        // 计算蜡烛坐标、高度
        [obj setCandleOriginWithHigh:self.maxPrice width:KlineStyle.style.candle_w low:self.minPrice unitValue:unitDistance idx:idx maxY:maxY];
        
        // Line
        [line addObject:@(CGPointMake(obj.candleX + candle_half, obj.candleY))];
        // MA坐标
        CGFloat pointX = obj.candleX + candle_half;
        if(obj.MA7) {
            CGFloat MA7Y = [self mainChartYWithMaxY:maxY value:obj.MA7 min:self.minPrice unit:unitDistance];
            [MA7Points addObject:@(CGPointMake(pointX, MA7Y))];
        }
        if(obj.MA30) {
            CGFloat MA30Y = [self mainChartYWithMaxY:maxY value:obj.MA30 min:self.minPrice unit:unitDistance];
            [MA30Points addObject:@(CGPointMake(pointX, MA30Y))];
        }
		if (obj.MA99) {
			CGFloat MA99Y = [self mainChartYWithMaxY:maxY value:obj.MA99 min:self.minPrice unit:unitDistance];
			[MA99Points addObject:@(CGPointMake(pointX, MA99Y))];
		}
        
        // vol
        obj.volHeight = obj.vol.floatValue / unit_vol;
        
        if (obj.EMA7) {
            
            CGFloat EMA7Y = [self mainChartYWithMaxY:maxY value:obj.EMA7 min:self.minPrice unit:unitDistance];
            [EMA7Points addObject:@(CGPointMake(pointX, EMA7Y))];
        }
        if (obj.EMA30) {
            CGFloat EMA30Y = [self mainChartYWithMaxY:maxY value:obj.EMA30 min:self.minPrice unit:unitDistance];
            [EMA30Points addObject:@(CGPointMake(pointX, EMA30Y))];
        }
		if (obj.EMA99) {
			CGFloat EMA99Y = [self mainChartYWithMaxY:maxY value:obj.EMA99 min:self.minPrice unit:unitDistance];
			[EMA99Points addObject:@(CGPointMake(pointX, EMA99Y))];
		}
		
        // BOLL
        if ([self.data indexOfObject:obj] >18 && isBOLL) {
            CGFloat boll = [self mainChartYWithMaxY:maxY value:obj.BOLL min:self.minPrice unit:unitDistance];
            CGFloat ub = [self mainChartYWithMaxY:maxY value:obj.UB min:self.minPrice unit:unitDistance];
            CGFloat db = [self mainChartYWithMaxY:maxY value:obj.DB min:self.minPrice unit:unitDistance];
            [BOLL addObject:@(CGPointMake(pointX, boll))];
            [UB addObject:@(CGPointMake(pointX, ub))];
            [DB addObject:@(CGPointMake(pointX, db))];
        }
        // MCAD
        if (obj.DIF) {
            CGFloat pointY_DIF = [self bottomChartY:obj.DIF min:self.macd_min unit:unit_macd];
            [DIFPoints addObject:@(CGPointMake(pointX, pointY_DIF))];
        }
        if (obj.DEA) {
            CGFloat pointY_DEA = [self bottomChartY:obj.DEA min:self.macd_min unit:unit_macd];
            [DEAPoints addObject:@(CGPointMake(pointX, pointY_DEA))];
        }
        if (obj.BAR) {
            CGFloat barMinY = [self bottomChartY:0 min:self.macd_min unit:unit_macd];
            CGFloat barMaxY = [self bottomChartY:obj.BAR min:self.macd_min unit:unit_macd];
            [BARPoints addObject:@(CGPointMake(barMinY, barMaxY))];
        }
        
        // KDJ
        CGFloat pointY_k = [self bottomChartY:obj.K min:self.kdj_min unit:unit_kdj];
        CGFloat pointY_d = [self bottomChartY:obj.D min:self.kdj_min unit:unit_kdj];
        CGFloat pointY_j = [self bottomChartY:obj.J min:self.kdj_min unit:unit_kdj];
        
        [kPoints addObject:@(CGPointMake(pointX, pointY_k))];
        [dPoints addObject:@(CGPointMake(pointX, pointY_d))];
        [jPoints addObject:@(CGPointMake(pointX, pointY_j))];
        
        // RSI
        CGFloat rsi6Y = [self bottomChartY:obj.rsi6 min:self.rsi_min unit:unit_rsi];
        [rsi6 addObject:@(CGPointMake(pointX, rsi6Y))];
		CGFloat rsi12Y = [self bottomChartY:obj.rsi12 min:self.rsi_min unit:unit_rsi];
		[rsi12 addObject:@(CGPointMake(pointX, rsi12Y))];
		CGFloat rsi24Y = [self bottomChartY:obj.rsi24 min:self.rsi_min unit:unit_rsi];
		[rsi24 addObject:@(CGPointMake(pointX, rsi24Y))];
    }];
    
    _linePoints = line;
    
    _MA7Points = MA7Points;
    _MA30Points = MA30Points;
	_MA99Points = MA99Points;
	
    _EMA7Points = EMA7Points;
    _EMA30Points = EMA30Points;
	_EMA99Points = EMA99Points;
	
    // BOLL
    _BollPoints = BOLL;
    _UBPoints = UB;
    _DBPoints = DB;
    
    // MACD
    _DIFPoints = DIFPoints;
    _DEAPoints = DEAPoints;
    _BARPoints = BARPoints;
    
    // KDJ
    _KPoints = kPoints;
    _DPoints = dPoints;
    _JPoints = jPoints;
    
	_rsi6 = rsi6;
	_rsi12 = rsi12;
	_rsi24 = rsi24;
}

- (CGFloat)mainChartYWithMaxY:(CGFloat)maxY value:(CGFloat)value min:(CGFloat)min unit:(CGFloat)unit {
    CGFloat topY = maxY - (value - min) /unit;
    return topY;
}

- (CGFloat)bottomChartY:(CGFloat)value min:(CGFloat)min unit:(CGFloat)unitDistance {
    CGFloat pointY = _canvasHeight - fabs(value - min)/unitDistance - kSubChartMarginBottom;
    return pointY;
}

@end
