//
//  UIColor+KLineTheme.m
//  KLineDemo
//
//  Created by chen on 2018/5/23.
//  Copyright © 2018年 chen. All rights reserved.
//

#import "UIColor+KLineTheme.h"

@implementation UIColor (KLineTheme)

+ (UIColor *)colorWithHex:(UInt32)hex {
    return [UIColor colorWithHex:hex alpha:1.f];
}

+ (UIColor *)colorWithHex:(UInt32)hex alpha:(CGFloat)alpha {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:alpha];
}

@end
