//
//  ENPanGestureRecognizer.m
//  KLineDemo
//
//  Created by E on 2019/4/1.
//  Copyright © 2019 easy. All rights reserved.
//

#import "ENPanGestureRecognizer.h"

@implementation ENPanGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithTarget:target action:action];
//    self.target = target;
//    self.selector = action;
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touches = touches;
    _event = event;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touches = nil;
    _event = nil;
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touches = nil;
    _touches = nil;
    [super touchesCancelled:touches withEvent:event];
}

- (void)cancellTouches {
    
    if (_touches && _event) {
        [self touchesCancelled:_touches withEvent:_event];
    }
}

@end
