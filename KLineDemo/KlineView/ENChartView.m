//
//  ENChartView.m
//  KLineDemo
//
//  Created by chen on 2018/6/11.
//  Copyright © 2018年 chen. All rights reserved.
//

#import "ENChartView.h"
#import "UIColor+KLineTheme.h"
#import "ENBackgroundLayer.h"
#import "ENCandleLayer.h"
#import "ENLineLayer.h"
#import "ENTextLayer.h"
#import "ENFlagLineLayer.h"
#import "KLineDataManager.h"
#import "KlineStyle.h"
#import "ENPanGestureRecognizer.h"

@interface ENChartView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) ENBackgroundLayer *bgLayer;
@property (nonatomic, strong) ENCandleLayer *candleLayer;
@property (nonatomic, strong) ENLineLayer *lineLayer;
@property (nonatomic, strong) DKTextLayer *textLayer;
@property (nonatomic, strong) ENFlagLineLayer *flagLineLayer;

@property (nonatomic, strong) ENPanGestureRecognizer *dragGest;

@property (nonatomic, assign) NSInteger dragCount;
@property (nonatomic, assign) CGFloat touchPointX;
@property (nonatomic, assign) CGFloat scale;


@property (nonatomic, strong) CADisplayLink *dis; //定时器
@property (nonatomic, assign) NSInteger updateCount;    //需要刷新次数
@property (nonatomic, assign) NSInteger currentCount;   //
@property (nonatomic, assign) CGPoint velocity;   //速度
@property (nonatomic, assign) CGPoint lastLocation;   //速度
@property (nonatomic, assign) CGFloat total;


@end

@implementation ENChartView

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
- (ENBackgroundLayer *)bgLayer {
    if (!_bgLayer) {
        _bgLayer = [ENBackgroundLayer layer];
        _bgLayer.frame = self.bounds;
        [self.layer addSublayer:_bgLayer];
    }
    return _bgLayer;
}

#pragma mark -- 蜡烛层
// 蜡烛容器layer
- (ENCandleLayer *)candleLayer {
    if (!_candleLayer) {
        _candleLayer = [ENCandleLayer layer];
        _candleLayer.zPosition = 0;
        _candleLayer.frame = self.bounds;
        [self.layer addSublayer:_candleLayer];
    }
    return _candleLayer;
}

#pragma mark -- k线层
- (ENLineLayer *)lineLayer {
    
    if (!_lineLayer) {
        _lineLayer = [ENLineLayer layer];
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
- (ENFlagLineLayer *)flagLineLayer {
    if (!_flagLineLayer) {
        _flagLineLayer = [ENFlagLineLayer layer];
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
	
	// 选中
	if ([self.delegate respondsToSelector:@selector(chartView:didSelectedAtIndex:)]) {
		[self.delegate chartView:self didSelectedAtIndex:idx];
	}
    if (ges.state == UIGestureRecognizerStateBegan) {
        [_textLayer showTitleInfoAtIndex:idx];
        [_flagLineLayer showFlagLineAtIndex:idx];
    } else if (ges.state == UIGestureRecognizerStateChanged) {
        [_textLayer showTitleInfoAtIndex:idx];
        [_flagLineLayer showFlagLineAtIndex:idx];
    } else if (UIGestureRecognizerStateEnded == ges.state || ges.state == UIGestureRecognizerStateCancelled || ges.state == UIGestureRecognizerStateFailed) {
		
		[_flagLineLayer didmiss];
        [_textLayer infoDismiss];
		// 反选
		if ([self.delegate respondsToSelector:@selector(chartView:didDeSelectedAtIndex:)]) {
			[self.delegate chartView:self didDeSelectedAtIndex:idx];
		}
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
    _dragGest = [[ENPanGestureRecognizer alloc]initWithTarget:self action:@selector(chartDidScroll:)];
    _dragGest.delegate = self;
    [self addGestureRecognizer:_dragGest];
}

-(void)chartDidScroll:(UIPanGestureRecognizer *)panGest{

    NSInteger count = 0;
    
    CGFloat transPoint = [panGest translationInView:self].x;
    if (UIGestureRecognizerStateChanged == panGest.state) {
        
        
        CGFloat candleW = (KlineStyle.style.candle_w * KlineStyle.style.scale);
        count = transPoint /candleW;
        
        if (_dragCount != count && count != 0) {
            
            // count < 0, 手指向左滑动
            [KLineDataManager manager].showIndex -= count;

            [self draw];
            _dragCount = count;
            [panGest setTranslation:CGPointZero inView:self];
        }
    }
    else if (UIGestureRecognizerStateEnded == panGest.state) {
            if (_dis) {
                [_dis invalidate];
                _dis = nil;
            }
        // 惯性滑动
            _velocity = [panGest velocityInView:self];
            CGFloat magnitude = sqrtf(_velocity.x * _velocity.x);
            CGFloat slideMult = magnitude / 200;
            float slideFactor = 0.1 * slideMult;
            _updateCount = slideFactor * 120 + 1;
            _dis = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateView)];
            [_dis addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
    
}

// 惯性动画
-(void)updateView {
    
    _currentCount++;
    if (_currentCount>_updateCount || _currentCount>60) {
        
        //        dis.paused = YES;
        [_dis removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_dis invalidate];
        _dis = nil;
        _currentCount = 0;
        _updateCount = 0;
    }else{
        CGPoint point = CGPointMake(_velocity.x/20/_currentCount, 0);
        _total += point.x;
        NSInteger count = _total / (KlineStyle.style.candle_w * KlineStyle.style.scale);
        if (count != 0) {
            
            // count < 0, 手指向左滑动
            [KLineDataManager manager].showIndex -= count;
            
            [self draw];
            _dragCount = count;
            _total = 0;
        }
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
	_lineLayer.ma99Points = data.MA99Points;
    // EMA
    _lineLayer.ema7Points = data.EMA7Points;
    _lineLayer.ema30Points = data.EMA30Points;
	_lineLayer.ema99Points = data.EMA99Points;
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
    self.textLayer.models = data.needDraw;
    [_textLayer draw];
    
    // 长按辅助线的数据
    self.flagLineLayer.models = data.needDraw;
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (_dragGest == gestureRecognizer && UIGestureRecognizerStateBegan == _dragGest.state) {
        CGPoint distance = [_dragGest translationInView:self];
        CGPoint velocity = [_dragGest velocityInView:self];
        if (fabs(distance.x) > fabs(distance.y) && fabs(velocity.x) > fabs(velocity.y)) {
            // 横向滑动，禁止父视图滑动手势
            return NO;
        } else {
            // 纵向，禁止k线滑动
            [_dragGest cancellTouches];
            return YES;
        }
    }
    return NO;
}

- (void)resetLayers {
    [_candleLayer removeFromSuperlayer];
    _candleLayer = nil;
    [_lineLayer removeFromSuperlayer];
    _lineLayer = nil;
    [_textLayer setSublayers:nil];
    [_textLayer removeFromSuperlayer];
    _textLayer = nil;
}




@end
