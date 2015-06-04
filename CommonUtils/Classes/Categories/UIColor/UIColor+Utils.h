//  Created by Karen Lusinyan on 21/06/14.

@interface UIColor (Utils)

+ (UIColor *)colorFromRed:(float)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

+ (UIColor *)colorFromHexValue:(NSInteger)rgbValue;

+ (NSString *)hexStringFromColor:(UIColor *)color;

+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end
