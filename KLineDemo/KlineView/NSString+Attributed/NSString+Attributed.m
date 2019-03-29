//
//  NSString+Attributed.m
//  KLineDemo
//
//  Created by E on 2019/3/29.
//  Copyright © 2019 easy. All rights reserved.
//

#import "NSString+Attributed.h"

@implementation NSString (Attributed)

- (NSMutableAttributedString *)attributed {
    
    return [[NSMutableAttributedString alloc]initWithString:self];
}

@end

@implementation NSMutableAttributedString (Expand)

- (NSMutableAttributedString *)cat_ColorText:(NSArray *)strings color:(UIColor *)color {
    
    for (NSString *str in strings) {
        NSRange range = [self.string rangeOfString:str];
        if (range.location != NSNotFound) {
            [self addAttribute:NSForegroundColorAttributeName value:color range:range];
        }
    }
    return self;
}

- (NSMutableAttributedString *)cat_makeDifferentFontText:(NSArray *)strings font:(UIFont *)font {
    
    for (NSString *str in strings) {
        NSRange range = [self.string rangeOfString:str];
        if (range.location != NSNotFound) {
            [self addAttribute:NSFontAttributeName value:font  range:range];
        }
    }
    return self;
}

@end
