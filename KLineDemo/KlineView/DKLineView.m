//
//  DKLineView.m
//  KLineDemo
//
//  Created by easy on 2018/6/11.
//  Copyright © 2018年 easy. All rights reserved.
//

#import "DKLineView.h"
#import "UIColor+KLineTheme.h"
#import "DKBackgroundLayer.h"
#import "DKCandleLayer.h"
#import "DKLineLayer.h"
#import "DKTextLayer.h"
#import "DKFlagLineLayer.h"
#import "KLineDataManager.h"
#import "KlineStyle.h"

@interface DKLineView ()

@property (nonatomic, strong) DKBackgroundLayer *bgLayer;
@property (nonatomic, strong) DKCandleLayer *candleLayer;
@property (nonatomic, strong) DKLineLayer *lineLayer;
@property (nonatomic, strong) DKTextLayer *textLayer;
@property (nonatomic, strong) DKFlagLineLayer *flagLineLayer;


@property (nonatomic, assign) NSInteger dragCount;
@property (nonatomic, assign) CGFloat touchPointX;
@property (nonatomic, assign) CGFloat scale;

@end

@implementation DKLineView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addLongPressGesture];
        [self addPinchingGesture];
        [self addDragGesture];
        _scale = 1;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bgLayer.frame = self.bounds;
    self.candleLayer.frame = self.bounds;
    self.lineLayer.frame = self.bounds;
    self.textLayer.frame = self.bounds;
    self.flagLineLayer.frame = self.bounds;
    
}

#pragma mark - Setter & Getter

#pragma mark - Layer组件
- (DKBackgroundLayer *)bgLayer {
    if (!_bgLayer) {
        _bgLayer = [DKBackgroundLayer layer];
        _bgLayer.frame = self.bounds;
        [self.layer addSublayer:_bgLayer];
    }
    return _bgLayer;
}

#pragma mark -- 蜡烛层
// 蜡烛容器layer
- (DKCandleLayer *)candleLayer {
    if (!_candleLayer) {
        _candleLayer = [DKCandleLayer layer];
        _candleLayer.zPosition = 0;
        _candleLayer.frame = self.bounds;
        [self.layer addSublayer:_candleLayer];
    }
    return _candleLayer;
}

#pragma mark -- k线层
- (DKLineLayer *)lineLayer {
    
    if (!_lineLayer) {
        _lineLayer = [DKLineLayer layer];
        _lineLayer.zPosition = 1;
        _lineLayer.frame = self.bounds;
        [self.layer addSublayer:_lineLayer];
    }
    return _lineLayer;
}

#pragma mark -- 文字层
- (DKTextLayer *)textLayer {
    
    if (!_textLayer) {
        _textLayer = [DKTextLayer layer];
        _textLayer.zPosition = 2;
        _textLayer.frame = self.bounds;
        [self.layer addSublayer:_textLayer];
    }
    return _textLayer;
}

#pragma mark -- 辅助线层
- (DKFlagLineLayer *)flagLineLayer {
    if (!_flagLineLayer) {
        _flagLineLayer = [DKFlagLineLayer layer];
        _flagLineLayer.zPosition = 3;
        _flagLineLayer.frame = self.bounds;
        [self.layer addSublayer:_flagLineLayer];
    }
    return _flagLineLayer;
}

#pragma mark - 手势

// 长按辅助线
- (void)addLongPressGesture {
    
    // 长按
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.3;
    longPress.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:longPress];
}

- (void)longPress:(UILongPressGestureRecognizer *)ges {
    
    CGPoint point= [ges locationInView:self];
    NSInteger idx = (point.x - kChartBorderWidth) / (KlineStyle.style.candle_w + kCandleSpacing);
    
    if (ges.state == UIGestureRecognizerStateBegan) {
        [_textLayer showTitleInfoAtIndex:idx];
        [_flagLineLayer showFlagLineAtIndex:idx];
    } else if (ges.state == UIGestureRecognizerStateChanged) {
        [_textLayer showTitleInfoAtIndex:idx];
        [_flagLineLayer showFlagLineAtIndex:idx];
    } else if (UIGestureRecognizerStateEnded == ges.state || ges.state == UIGestureRecognizerStateCancelled || ges.state == UIGestureRecognizerStateFailed) {
        [_flagLineLayer didmiss];
        [_textLayer infoDismiss];
    }
}

// 捏合缩放
- (void)addPinchingGesture {
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomAction:)];
    pinch.scale = 1;
    [self addGestureRecognizer:pinch];
}

- (void)zoomAction:(UIPinchGestureRecognizer *)pinch {
    
    switch (pinch.state) {
            case UIGestureRecognizerStateBegan:
            pinch.scale = _scale;
            break;
        case UIGestureRecognizerStateChanged:{
            
            if (pinch.scale < KlineStyle.style.minScale) {
                pinch.scale = KlineStyle.style.minScale;
                break;
            }
            else if (pinch.scale > KlineStyle.style.maxScale) {
               pinch.scale = KlineStyle.style.maxScale;
                break;
            }
            NSLog(@"%.2F", _scale);


//             最少20个，默认40，最大80个
            
            NSInteger count = 40;
            if (_scale > 1) {
                count = count - 10*(_scale-1);
            } else if (_scale < 1) {
                count = count + 80*(1 - _scale);
            }

            if (count %2 == 0 && count > 0) {
                // 3.刷新显示位置
                KLineDataManager *manager = KLineDataManager.manager;
                NSInteger idx = manager.showIndex + manager.showCount - count;
                if (idx <0) {
                    idx = 0;
                }
                // 2.刷新个数
                manager.showCount = count;
                manager.showIndex = idx;
                [self draw];
            }

        }
            break;
        case UIGestureRecognizerStateEnded:
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        default:
            break;
    }
    _scale = pinch.scale;
}

// 拖动
- (void)addDragGesture {
    UIPanGestureRecognizer *panGest = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(chartDidScroll:)];
    [self addGestureRecognizer:panGest];
}

-(void)chartDidScroll:(UIPanGestureRecognizer *)panGest{

    NSInteger count = 0;
    BOOL isEnd = NO;
    
    CGPoint touch = [panGest locationInView:self];

    if (UIGestureRecognizerStateBegan == panGest.state) {
        _touchPointX = touch.x;
    }
    else if (UIGestureRecognizerStateChanged == panGest.state) {
        count = (touch.x - _touchPointX)/(KlineStyle.style.candle_w + kCandleSpacing);
        
        if (_dragCount != count) {
            
            // -1 向右
            if (count <0) {
                [KLineDataManager manager].showIndex ++;
            } else {
                [KLineDataManager manager].showIndex --;
            }
            
            [self draw];
            _dragCount = count;
        }
    } else if (UIGestureRecognizerStateEnded == panGest.state || UIGestureRecognizerStateCancelled == panGest.state) {
        
        isEnd = YES;
    }

    
}

#pragma mark - 统一绘制
- (void)draw {
    

    [self resetLayers];
    
    KLineDataManager *data = [KLineDataManager manager];
    
    // 蜡烛
    self.candleLayer.models = data.needDraw;
    _candleLayer.lines = data.linePoints;

    [_candleLayer draw];
    
    // 指标画线
    self.lineLayer.ma7Points = data.MA7Points;
    _lineLayer.ma30Points = data.MA30Points;
    // EMA
    _lineLayer.ema7Points = data.EMA7Points;
    _lineLayer.ema30Points = data.EMA30Points;
    // BOLL
    _lineLayer.BOLLPoints = data.BollPoints;
    _lineLayer.UBPoints = data.UBPoints;
    _lineLayer.DBPoints = data.DBPoints;
    // MACD
    _lineLayer.DIFPoints = data.DIFPoints;
    _lineLayer.DEAPoints = data.DEAPoints;
    _lineLayer.BARPoints = data.BARPoints;
    // KDJ
    _lineLayer.KPoints = data.KPoints;
    _lineLayer.DPoints = data.DPoints;
    _lineLayer.JPoints = data.JPoints;
    
    _lineLayer.RSIPoints = data.RSIPoints;
    [self.lineLayer drawLines];
    
    // 高低价文字
    BOOL isLine = ENChartTypeLine == KlineStyle.style.topChartType;
    if (!isLine) {
        self.textLayer.models = data.needDraw;
        [_textLayer draw];        
    }
    
    // 长按辅助线的数据
    self.flagLineLayer.models = data.needDraw;
    
}

- (void)resetLayers {
    [_candleLayer removeFromSuperlayer];
    _candleLayer = nil;
    [_lineLayer removeFromSuperlayer];
    _lineLayer = nil;
    [self.textLayer removeFromSuperlayer];
    self.textLayer = nil;
    
}




@end
