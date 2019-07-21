//
//  ENChartView.h
//  KLineDemo
//
//  Created by chen on 2018/6/11.
//  Copyright © 2018年 chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLineModel.h"


@class ENChartView;
@protocol ENChartViewDelegate <NSObject>

- (void)chartView:(ENChartView *)chart didSelectedAtIndex:(NSInteger)index;
- (void)chartView:(ENChartView *)chart didDeSelectedAtIndex:(NSInteger)index;

@end

@interface ENChartView : UIView

@property (nonatomic, weak) id<ENChartViewDelegate> delegate;
- (void)draw;

@end
