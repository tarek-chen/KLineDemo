//
//  ViewController.m
//  KLineDemo
//
//  Created by chen on 2018/5/23.
//  Copyright © 2018年 chen. All rights reserved.
//

#import "ViewController.h"
#import "NetWorking.h"
#import "ENChartView.h"
#import "UIColor+KLineTheme.h"
#import "SRWebSocket.h"
#import "GZIP.h"
#import "KLineModel.h"
#import "KLineDataManager.h"
#import "NSString+Attributed.h"

@interface ViewController ()<SRWebSocketDelegate, ENChartViewDelegate>
@property (nonatomic, strong) ENChartView *kLineView;
@property (nonatomic, strong) SRWebSocket *skt;
@property (nonatomic, strong) SRWebSocket *skt_now;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet UIView *scrollView;
@property (weak, nonatomic) IBOutlet UIStackView *stack;
@property (weak, nonatomic) IBOutlet UIStackView *volStack;

@end

@implementation ViewController


- (void)dealloc {
    [self close:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    _kLineView = [ENChartView new];
    _kLineView.backgroundColor = UIColor.blackColor;
    _kLineView.frame = CGRectMake(0, 60, [UIScreen mainScreen].bounds.size.width, 300);
    [self.scrollContentView addSubview:_kLineView];
	_kLineView.delegate = self;
	
//	[self getQ];
	[self getRecord];
	
//    NSString *ws = @"wss://ws.dcoin.com/kline-api/ws";
//    _skt = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ws]]];
//    _skt.delegate = self;
//    [_skt open];
//
//    _skt_now = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:ws]]];
//    _skt_now.delegate = self;
	
}


#pragma mark - DcoinAPI
- (void)getRecord {
	NSString *path = @"https://openapi.dcoin.com/open/api/get_records";
	NSDictionary *param = @{@"symbol": @"adausdt", @"period": @"60min", @"size": @"300"};
//	symbol	string	true	市场标记，例：btcusdt
//	period	string	true	k线时间刻度，见下
//	size	int	false  100
	[NetWorking requestWithApi:path param:param.mutableCopy thenSuccess:^(NSDictionary *responseObject) {
		NSArray *dataArray = responseObject[@"data"];
		if (dataArray.count >0) {
			NSMutableArray *tempData = @[].mutableCopy;
			// model转化
			for (NSDictionary *info in dataArray) {
				KLineModel *model = [KLineModel modelWithDict:info];
				[tempData addObject:model];
			}
			[self reDraw:tempData];
		}
	} fail:^{
		NSLog(@"");
	}];
	
}

- (void)chartView:(ENChartView *)chart didSelectedAtIndex:(NSInteger)index {

	KLineModel *model = [KLineDataManager manager].needDraw[index];
	// 开、高、低、收、幅、量、时间
	UILabel *open = _stack.subviews.firstObject;
	open.text = [NSString stringWithFormat:@"O: %@", model.open];
	UILabel *high = _stack.subviews[1];
	high.text = [NSString stringWithFormat:@"H: %@", model.high];
	UILabel *low = _stack.subviews[2];
	low.text = [NSString stringWithFormat:@"L: %@", model.low];
	UILabel *close = _stack.subviews.lastObject;
	close.text = [NSString stringWithFormat:@"C: %@", model.close];
	
	// vol
	UILabel *time = _volStack.subviews.lastObject;
	time.text = [NSString stringWithFormat:@"Date: %@", model.ID.candleDate];
	UILabel *vol = _volStack.subviews.firstObject;
	vol.text = [NSString stringWithFormat:@"Vol: %@", model.vol];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSError *error;
    // kLine @"Klineetcusdt"
    NSString *typeKey = @"Kline";
    NSString *event = @"req";
    if (_skt_now == webSocket) {
        typeKey = @"KlineNow";
        event = @"sub";
    }
    typeKey = [typeKey stringByAppendingString:@"adausdt"];
	
    NSMutableDictionary *param = @{@"channel":@"market_adausdt_kline_1min",@"cb_id":typeKey}.mutableCopy;
    if (_skt == webSocket) {
        param[@"top"] = @(600);
    }
    NSDictionary *reqParam = @{@"event":event,@"params":param};
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"event":@"req",@"params":@{@"channel":@"market_etcusdt_kline_1min",@"cb_id":@"Klineetcusdt"}}
//                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    // 涨跌
//    NSDictionary *paramValue = @{@"channel":@"market_sorted_ticker",
//                                 @"cb_id" : @"HomeRank"};
//    NSDictionary *param = @{@"event": @"sub"
//                            , @"params": paramValue};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:reqParam options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [webSocket send:jsonString];
}


- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    
    NSLog(@"receive pong");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
//    NSAssert(!isnan(DIFY) && !isnan(DEAY), @"出现NAN值");

    // 数据解压
    NSData *data = (NSData *)message;
    data = [data gunzippedData];
    NSString *uncompressStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *uncompressReplacedStr = [uncompressStr stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    
    NSData *strData = [uncompressReplacedStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:strData options:0 error:nil];
    NSArray *dataArray = dic[@"data"];
    if (dataArray.count >0) {
        NSMutableArray *tempData = @[].mutableCopy;
        // model转化
        
        for (NSDictionary *info in dataArray) {
            KLineModel *model = [KLineModel modelWithDict:info];
            [tempData addObject:model];
        }
        [self reDraw:tempData];
        
        // 刷新
        if (_skt == webSocket) {
            [_skt close];
            [_skt_now open];
        }
    }
    // 心跳
    else if ([dic.allKeys containsObject:@"ping"]) {
        
        NSString *ping = dic[@"ping"];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"pong":ping} options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [_skt send:jsonString];

    } else if (_skt_now == webSocket && [dic.allKeys containsObject:@"tick"]) {
        // 新推数据

        KLineModel *model = [KLineModel modelWithDict:dic[@"tick"]];
        [[KLineDataManager manager] addNewData:model];
        [_kLineView draw];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Fails");
}

- (void)reDraw:(NSMutableArray *)data {
    
    KLineDataManager *manager = [KLineDataManager manager];
    // 必须先记录尺寸
    manager.canvasHeight = CGRectGetHeight(_kLineView.frame);
    manager.canvasWidth = CGRectGetWidth(_kLineView.frame);
    [manager setData:data];
    [self.kLineView draw];
}

- (IBAction)mainChart:(UIButton *)sender {
    BOOL BOLLChanged = isBOLL;
    switch (sender.tag) {
        case 0:
            // ma
            KlineStyle.style.topChartType = ENChartTypeMA;
            break;
        case 1:
            // BOLL
            KlineStyle.style.topChartType = ENChartTypeEMA;
            break;
        case 2:
            // BOLL
            KlineStyle.style.topChartType = ENChartTypeBOLL;
            break;
        case 3:
            // line
            KlineStyle.style.topChartType = ENChartTypeLine;
            break;
        default:
            break;
    }
    if (isBOLL || BOLLChanged) {
        [[KLineDataManager manager] refreshData];
    }
    [_kLineView draw];
}

- (IBAction)bottomChart:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            // macd
            KlineStyle.style.bottomChartType = ENChartTypeMACD;
            break;
        case 1:
            // kdj
            KlineStyle.style.bottomChartType = ENChartTypeKDJ;
            break;
        case 2:
            // rsi
            KlineStyle.style.bottomChartType = ENChartTypeRSI;
            break;
        case 3:
            // vol
            KlineStyle.style.bottomChartType = ENChartTypeVOL;
            break;
        default:
            break;
    }
    [[KLineDataManager manager] refreshData];
    [_kLineView draw];
}

- (IBAction)close:(UIButton *)sender {
    
    [_skt close];
    [_skt_now close];
}

#pragma mark - EIREN
- (void)getQ {
	NSString *path = @"https://www.eirenex.net/d_api/quotation/kline";
	NSDictionary *params = @{@"Contract" : @"btcusdt", @"Cycle":@"1H"};
	
	[NetWorking requestWithApi:path param:params.mutableCopy thenSuccess:^(NSDictionary *responseObject) {
		NSMutableArray *temp = @[].mutableCopy;
		if ([responseObject[@"status"] boolValue]) {
			NSArray *datas = responseObject[@"data"];
			datas = [[datas reverseObjectEnumerator] allObjects];
			
			for (NSDictionary *info in datas) {
				KLineModel *model = [KLineModel modelWithDict:info];
				[temp addObject:model];
			}
			[self reDraw:temp];
		}
	} fail:^{
		NSLog(@"W");
	}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
