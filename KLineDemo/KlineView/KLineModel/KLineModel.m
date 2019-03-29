//
//  KLineModel.m
//  KLineDemo
//
//  Created by easy on 2018/6/12.
//  Copyright © 2018年 easy. All rights reserved.
//

#import "KLineModel.h"

@implementation KLineModel

+ (NSDictionary *)replacedKeyFromPropertyName {
    
    return @{@"ID" : @"id"};
}

+ (instancetype)modelWithDict:(NSDictionary *)dict {
    KLineModel *model = [KLineModel new];
    if (dict) {
        model.amount = dict[@"amount"];
        model.ID = [NSString stringWithFormat:@"%@", dict[@"id"]];
        model.open = dict[@"open"];
        model.high = dict[@"high"];
        model.low = dict[@"low"];
        model.close = dict[@"close"];
        model.vol = dict[@"vol"];
    }
    return model;
}

// SETTER
#define MAKey(string, num) NSString *key_ma = [NSString stringWithFormat:@"%@%ld", string, (long)num];

- (void)setMA:(NSInteger)num value:(CGFloat)value {

    MAKey(@"MA", num)
    [self setValue:@(value) forKey:key_ma];
}

- (void)setMAVol:(NSInteger)num value:(CGFloat)value {
    MAKey(@"MAV", num)
    [self setValue:@(value) forKey:key_ma];
}

// GETTER
- (CGFloat)getMA:(NSInteger)num {
    MAKey(@"MA", num)
    CGFloat ma = [[self valueForKey:key_ma] floatValue];
    return ma;
}

- (CGFloat)getMAVol:(NSInteger)num {
    MAKey(@"MAV", num)
    CGFloat ma = [[self valueForKey:key_ma] floatValue];
    return ma;
}

// 量
- (NSString *)volText {
    
    CGFloat k = _vol.floatValue / 1000;
    CGFloat m = _vol.floatValue / 1000000;

    NSString *volText = _vol;
    if (m >= 0.1) {
        volText = [NSString stringWithFormat:@"%.1fM", m];
    }
    else if (k > 0) {
        volText = [NSString stringWithFormat:@"%.1fK", k];
    }
    return volText;
}

#pragma MARK -

- (void)setCandleOriginWithHigh:(CGFloat)high width:(CGFloat)width low:(CGFloat)low unitValue:(CGFloat)unitValue idx:(NSUInteger)idx maxY:(CGFloat)maxY {

    // 蜡烛
    {
        self.candleW = width *KlineStyle.style.scale;
        CGFloat candleH = ABS(self.open.floatValue - self.close.floatValue) /unitValue;
        // 最短蜡烛
        if (candleH < kMinCandleHeight) {
            candleH = kMinCandleHeight;
        }
        CGFloat openY = ABS(self.open.floatValue - high) /unitValue;
        CGFloat closeY = ABS(self.close.floatValue - high) /unitValue;
        // 涨：按收盘价计算y
        CGFloat candleY = closeY;
        // 跌：收<开盘价
        if (self.close.floatValue < self.open.floatValue) {
            candleY = openY;
        }
        self.candleH = candleH;
        // x
        self.candleX = idx * (width + kCandleSpacing) + kChartBorderWidth;
        // y换算笛卡尔坐标
        self.candleY = candleY + kMainChartMarginTop;
    }
    
    // 影线
    {
        CGFloat linCenterX = _candleX + _candleW /2; // 这里没计算影线宽度/2
        CGFloat lineHigh = ABS(self.high.floatValue - high) /unitValue;
        CGFloat lineLow = ABS(self.low.floatValue - high) /unitValue;
        _lineTop = CGPointMake(linCenterX, lineHigh + kMainChartMarginTop);
        _lineBottom = CGPointMake(linCenterX, lineLow +kMainChartMarginTop);
    }
}

// MA算法
- (void)setMA:(NSInteger)num index:(NSInteger)index models:(NSArray <KLineModel *>*)models {
    
    CGFloat MA, MAVol;
    CGFloat sumClose = 0;
    CGFloat sumVol = 0;
    if (index +1 >= num) {
        //index + 1 >= N，累计N天内的
        for (NSInteger i = 0; i < num; i++) {
            sumVol += models[index - i].vol.floatValue;
            sumClose += models[index - i].close.floatValue;
        }
        MA = sumClose / num;
        MAVol = sumVol / num;
    } else {
        
        for (NSInteger i = index; i >=0; i--) {
            sumVol += models[i].vol.floatValue;
            sumClose += models[i].close.floatValue;
        }
        MA = sumClose / (index + 1);
        MAVol = sumVol / (index + 1);
    }
    
    [self setMA:num value:MA];
    [self setMAVol:num value:MA];
}

// EMA
- (void)setEMA:(NSInteger)num index:(NSInteger)index models:(NSArray <KLineModel *>*)models {
    // EM价、量的key
    NSString *key_ema = [NSString stringWithFormat:@"EMA%ld", (long)num];
    NSString *key_emv = [NSString stringWithFormat:@"EMV%ld", (long)num];
    
    CGFloat ema_price = 0;
    CGFloat ema_vol = 0;
    CGFloat c = _close.floatValue;
    CGFloat v = _vol.floatValue;
        
    CGFloat prev_ema_price = 0;
    CGFloat prev_ema_vol = 0;
    if (index >0) {
        prev_ema_price = [[models[index -1] valueForKey:key_ema] floatValue];
        prev_ema_vol = [[models[index -1] valueForKey:key_emv] floatValue];
    }
    
    //EMA（N）=2/（N+1）*（C-昨日EMA）+昨日EMA；
    if (index > 0) {
        //EMA（N）=2/（N+1）*（C-昨日EMA）+昨日EMA；
        ema_price = prev_ema_price + (c - prev_ema_price) * 2 / (num + 1);
        ema_vol = prev_ema_vol + (v - prev_ema_vol) * 2 / (num + 1);
    } else {
        ema_price = c;
        ema_vol = v;
    }
    
    [self setValue:@(ema_price) forKey:key_ema];
    [self setValue:@(ema_vol) forKey:key_emv];

}

// MACD
- (void)setMACD:(NSInteger)p1 p2:(NSInteger)p2 p3:(NSInteger)p3 idx:(NSInteger)idx models:(NSArray <KLineModel *>*)models {
    
    //  要求先计算好p1&p2的EMA
    NSString *key_p1 = [NSString stringWithFormat:@"EMA%ld", (long)p1];
    NSString *key_p2 = [NSString stringWithFormat:@"EMA%ld", (long)p2];

    //    //EMA（p1）=2/（p1+1）*（C-昨日EMA）+昨日EMA；
    CGFloat ema1 = [[self valueForKey:key_p1] floatValue];
    //    //EMA（p2）=2/（p2+1）*（C-昨日EMA）+昨日EMA；
    CGFloat ema2 = [[self valueForKey:key_p2] floatValue];
    CGFloat pre_dea = 0;
    if (idx > 0) {
        pre_dea = models[idx -1].DEA;
    }
    //DIF=今日EMA（p1）- 今日EMA（p2）
    _DIF = ema1 - ema2;
    //dea（p3）=2/（p3+1）*（dif-昨日dea）+昨日dea；
    _DEA = pre_dea + (_DIF - pre_dea) * 2 / (p3 + 1);
    //BAR=2×(DIF－DEA)
    _BAR = 2 * (_DIF - _DEA);
    _MACD = _DIF - _DEA;

}

// KDJ
- (void)setKDJ:(NSInteger)p1 p2:(NSInteger)p2 p3:(NSInteger)p3 index:(NSInteger)index models:(NSArray <KLineModel *>*)models {

    CGFloat pre_k = 50,pre_d = 50;
    if (index >0) {
        KLineModel *pre = models[index -1];
        pre_k = pre.K;
        pre_d = pre.D;
    }
    //计算RSV值
    [self setRSV:p1 index:index models:models];
    //计算K,D,J值
    _K = (2 * pre_k + _RSV) / 3;
    _D = (2 * pre_d + _K) / 3;
    _J = 3 * _K - 2 * _D;
}

// RSV
// num:   计算天数范围
// index: 当前的索引位
- (void)setRSV:(NSInteger)num index:(NSInteger)index models:(NSArray <KLineModel *>*)models {
    
    CGFloat close = _close.floatValue;
    CGFloat high = _high.floatValue;
    CGFloat low = _low.floatValue;
    CGFloat rsv = 0;
    
    if (index + 1 >= num) {
        //index + 1 >= N，累计N天内的
        //计算num天数内最低价，最高价
        for (NSInteger i = 0; i < num; i++) {
            KLineModel *model = models[index - i];
            high = fmax(high, model.high.floatValue);
            low = fmin(low, model.low.floatValue);
        }
    } else {
        //index + 1 < N，累计index + 1天内的
        //计算index天数内最低价，最高价
        for (NSInteger i = 0; i < num; i++) {
            KLineModel *model = models[i];
            high = fmax(high, model.high.floatValue);
            low = fmin(low, model.low.floatValue);
        }
    }
    
    if (high != low) {
        rsv = (close - low) / (high - low) * 100;
    }
    _RSV = rsv;
}

// RSI
- (void)setRSI:(NSInteger)num idx:(NSInteger)idx models:(NSArray <KLineModel *>*)models {
    
    CGFloat defaultVal = 100;
    CGFloat sum = 0;
    CGFloat dif = 0;
    CGFloat rsi = 0;
    
    if (num > 0) {
        NSInteger k = idx - num + 1;
        NSArray *wrs = [self getAB:k b:idx data:models];
        sum = [wrs[0] floatValue];
        dif = [wrs[1] floatValue];
    }
    if (dif != 0) {
        CGFloat h = sum + dif;
        rsi = sum / h * 100;
    } else {
        rsi = 100;
    }

    if (idx < num -1) {
        rsi = defaultVal;
    }
    _RSI = rsi;
}


- (NSArray *)getAB:(NSInteger)a b:(NSInteger)b  data:(NSArray <KLineModel *>*)models {
    if (a <0) {
        a = 0;
    }
    CGFloat sum = 0, dif = 0, closeT, closeY;
    for (NSInteger index = a; index <= b; index++) {
        if (index > a) {
            closeT = models[index].close.floatValue;
            closeY = models[index -1].close.floatValue;
            CGFloat c = closeT - closeY;
            if (c > 0) {
                sum += c;
            } else {
                dif = sum + c;
            }
            dif = fabs(dif);
        }
    }
    return @[@(sum), @(dif)];
}

#pragma mark - BOLL
/// 布林线处理方法
///
/// 计算公式
/// 中轨线=N日的移动平均线
/// 上轨线=中轨线+两倍的标准差
/// 下轨线=中轨线－两倍的标准差
/// 计算过程
/// （1）计算MA
/// MA=N日内的收盘价之和÷N
/// （2）计算标准差MD
/// MD=平方根（N）日的（C－MA）的两次方之和除以N
/// （3）计算MB、UP、DN线
/// MB=（N）日的MA
/// UP=MB+k×MD
/// DN=MB－k×MD
/// （K为参数，可根据股票的特性来做相应的调整，一般默认为2）
///
/// - Parameters:
///   - num: 天数
///   - k: 参数默认为2
///   - datas: 待处理的数据
/// - Returns: 处理后的数据
- (void)setBOLL:(NSInteger)num k:(NSInteger)k index:(NSInteger)index models:(NSArray <KLineModel *>*)models {
    //    var md: CGFloat = 0, mb: CGFloat = 0, up: CGFloat = 0, dn: CGFloat = 0

    CGFloat md = 0, mb = 0, up = 0, dn = 0;
    //计算标准差
    md = [self getBOLLSTD:num index:index models:models];
    mb = [self getMA:num];
    up = mb + k * md;
    dn = mb - k * md;
    _BOLL = mb;
    _UB = up;
    _DB = dn;
}

/// 计算布林线中的MA平方差
///
/// - Parameters:
///   - num: 累计的天数
///   - index: 当天日期
///   - datas: 数据集合
/// - Returns: 结果
- (CGFloat)getBOLLSTD:(NSInteger)num index:(NSInteger)idx models:(NSArray <KLineModel *>*)models {

    CGFloat dx = 0, md = 0;
    CGFloat ma = [self getMA:num];
    if (idx +1 >= num) {
        for (NSInteger i = idx; i >= idx + 1 - num; i--) {
            dx += pow(models[i].close.floatValue -ma, 2);
        }
        md = dx / num;
    } else {
        for (NSInteger i = idx; i >=0; i--) {
            dx += pow(models[i].close.floatValue -ma, 2);
        }
        md = dx / (idx +1);
    }
    return pow(md, 0.5);
}

@end
