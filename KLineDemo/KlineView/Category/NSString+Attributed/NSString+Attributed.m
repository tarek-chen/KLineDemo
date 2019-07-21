//
//  NSString+Attributed.m
//  KLineDemo
//
//  Created by E on 2019/3/29.
//  Copyright © 2019 chen. All rights reserved.
//

#import "NSString+Attributed.h"

@implementation NSString (Attributed)

- (NSMutableAttributedString *)attributed {
    
    return [[NSMutableAttributedString alloc]initWithString:self];
}

- (NSString *)candleDate {
	return [self cat_timeFromeTimesTamp:@"MM-dd HH:mm"];
}

/// yyyy-MM-dd HH:mm:ss
- (NSString *)cat_timeFromeTimesTamp:(NSString *)format {
	NSTimeInterval time = [self doubleValue];
	NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:time];
	//实例化一个NSDateFormatter对象
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
	//设定时间格式,这里可以设置成自己需要的格式
	[dateFormatter setDateFormat:format];
	NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
	return currentDateStr;
}

- (CGFloat)textWidthWithHeight:(CGFloat)height andFont:(CGFloat)font {
	NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:font]};
	CGSize size = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, height)  options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)   attributes:attribute context:nil].size;
	return size.width;
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
