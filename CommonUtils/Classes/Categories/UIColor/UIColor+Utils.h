//  Created by Karen Lusinyan on 21/06/14.

//color from rgb
#define colorFromRGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

//color from hex
#define colorFromHexValue(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface UIColor (Utils)

+ (NSString *)hexStringFromColor:(UIColor *)color;

@end
