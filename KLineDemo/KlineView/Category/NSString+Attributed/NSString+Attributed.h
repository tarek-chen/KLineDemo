//
//  NSString+Attributed.h
//  KLineDemo
//
//  Created by E on 2019/3/29.
//  Copyright © 2019 chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Attributed)
- (NSMutableAttributedString *)attributed;
- (CGFloat)textWidthWithHeight:(CGFloat)height andFont:(CGFloat)font;
- (NSString *)candleDate;

@end

@interface NSMutableAttributedString (Expand)

- (NSMutableAttributedString *)cat_ColorText:(NSArray *)strings color:(UIColor *)color;

- (NSMutableAttributedString *)cat_makeDifferentFontText:(NSArray *)strings font:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
