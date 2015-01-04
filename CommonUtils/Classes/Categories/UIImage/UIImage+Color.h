//  Created by Karen Lusinyan on 17/10/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

@interface UIImage (Color)

+ (UIImage *)imageFromColor:(UIColor *)color;

- (UIImage *)imageWithColor:(UIColor *)color;

//Aggiunte da Niccolò
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)tintImage:(UIImage *)baseImage color:(UIColor *)theColor;
- (UIImage *)imageTintedWithColor:(UIColor *)color;

@end
