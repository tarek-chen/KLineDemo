//
//  ENPanGestureRecognizer.h
//  KLineDemo
//
//  Created by E on 2019/4/1.
//  Copyright © 2019 chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ENPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

@property (nonatomic, weak) NSSet *touches;
@property (nonatomic, weak) UIEvent *event;

- (void)cancellTouches;

@end

NS_ASSUME_NONNULL_END
