//  Created by Yasuhiro Inami on 2012/10/14.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//  Modified by Karen Lusinyan on 2015/04/10

#import "CommonInnerShadow.h"
#import <objc/runtime.h>

@implementation CommonInnerShadow

- (id)init
{
    self = [super init];
    if (self) {
        
        self.masksToBounds = YES;
        self.needsDisplayOnBoundsChange = YES;
        self.shouldRasterize = YES;
        
        // Standard shadow stuff
        [self setShadowColor:[[UIColor colorWithWhite:0 alpha:1] CGColor]];
        [self setShadowOffset:CGSizeMake(0.0f, 0.0f)];
        [self setShadowOpacity:1.0f];
        [self setShadowRadius:5];
        
        // Causes the inner region in this example to NOT be filled.
        [self setFillRule:kCAFillRuleEvenOdd];
        
        self.shadowMask = CommonInnerShadowMaskAll;
        
    }
    return self;
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    
    CGFloat top = (self.shadowMask & CommonInnerShadowMaskTop ? self.shadowRadius : 0);
    CGFloat bottom = (self.shadowMask & CommonInnerShadowMaskBottom ? self.shadowRadius : 0);
    CGFloat left = (self.shadowMask & CommonInnerShadowMaskLeft ? self.shadowRadius : 0);
    CGFloat right = (self.shadowMask & CommonInnerShadowMaskRight ? self.shadowRadius : 0);
    
    CGRect largerRect = CGRectMake(self.bounds.origin.x - left,
                                   self.bounds.origin.y - top,
                                   self.bounds.size.width + left + right,
                                   self.bounds.size.height + top + bottom);
    
    // Create the larger rectangle path.
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, largerRect);
    
    // Add the inner path so it's subtracted from the outer path.
    // someInnerPath could be a simple bounds rect, or maybe
    // a rounded one for some extra fanciness.
    CGFloat cornerRadius = self.cornerRadius;
    UIBezierPath *bezier;
    if (cornerRadius) {
        bezier = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:cornerRadius];
    } else {
        bezier = [UIBezierPath bezierPathWithRect:self.bounds];
    }
    CGPathAddPath(path, NULL, bezier.CGPath);
    CGPathCloseSubpath(path);
    
    [self setPath:path];
    
    CGPathRelease(path);
}

#pragma mark -

#pragma mark Accessors

- (void)setShadowMask:(CommonInnerShadowMask)shadowMask
{
    _shadowMask = shadowMask;
    [self setNeedsLayout];
}

- (void)setShadowColor:(CGColorRef)shadowColor
{
    [super setShadowColor:shadowColor];
    [self setNeedsLayout];
}

- (void)setShadowOpacity:(float)shadowOpacity
{
    [super setShadowOpacity:shadowOpacity];
    [self setNeedsLayout];
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    [super setShadowOffset:shadowOffset];
    [self setNeedsLayout];
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    [super setShadowRadius:shadowRadius];
    [self setNeedsLayout];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    [super setCornerRadius:cornerRadius];
    [self setNeedsLayout];
}

@end

@implementation UIView (InnerShadow)
@dynamic innerShadowLayer, shadowMask, shadowColor, shadowOpacity, shadowOffset, shadowRadius, cornerRadius;

#pragma mark -

#pragma mark Accessors

- (CommonInnerShadow *)innerShadowLayer
{
    return objc_getAssociatedObject(self, @selector(innerShadowLayer));
}

- (void)setInnerShadowLayer:(CommonInnerShadow *)innerShadowLayer
{
    objc_setAssociatedObject(self, @selector(innerShadowLayer), innerShadowLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CommonInnerShadowMask)shadowMask
{
    return [self innerShadowLayer].shadowMask;
}

- (void)setShadowMask:(CommonInnerShadowMask)shadowMask
{
    [self innerShadowLayer].shadowMask = shadowMask;
}

- (UIColor *)shadowColor
{
    return [UIColor colorWithCGColor:[self innerShadowLayer].shadowColor];
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    [self innerShadowLayer].shadowColor = shadowColor.CGColor;
}

- (CGFloat)shadowOpacity
{
    return [self innerShadowLayer].shadowOpacity;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    [self innerShadowLayer].shadowOpacity = shadowOpacity;
}

- (CGSize)shadowOffset
{
    return [self innerShadowLayer].shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    [self innerShadowLayer].shadowOffset = shadowOffset;
}

- (CGFloat)shadowRadius
{
    return [self innerShadowLayer].shadowRadius;
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    [self innerShadowLayer].shadowRadius = shadowRadius;
}

- (CGFloat)cornerRadius
{
    return [self innerShadowLayer].cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    
    [self innerShadowLayer].cornerRadius = cornerRadius;
}

- (void)setupInnerShadow
{
    // add as sublayer so that self.backgroundColor will work nicely
    [self setInnerShadowLayer:[CommonInnerShadow layer]];
    [self innerShadowLayer].frame = self.layer.bounds;
    [self innerShadowLayer].actions = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNull null], @"position",
                                       [NSNull null], @"bounds",
                                       [NSNull null], @"contents",
                                       [NSNull null], @"shadowColor",
                                       [NSNull null], @"shadowOpacity",
                                       [NSNull null], @"shadowOffset",
                                       [NSNull null], @"shadowRadius",
                                       nil];
    
    self.layer.masksToBounds = YES;
    
    [self.layer insertSublayer:[self innerShadowLayer] atIndex:0];
}

@end

@implementation UIButton (InnerShadow)
@dynamic innerShadowLayer, shadowMask, shadowColor, shadowOpacity, shadowOffset, shadowRadius, cornerRadius;

#pragma mark -

#pragma mark Accessors

- (CommonInnerShadow *)innerShadowLayer
{
    return objc_getAssociatedObject(self, @selector(innerShadowLayer));
}

- (void)setInnerShadowLayer:(CommonInnerShadow *)innerShadowLayer
{
    objc_setAssociatedObject(self, @selector(innerShadowLayer), innerShadowLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CommonInnerShadowMask)shadowMask
{
    return [self innerShadowLayer].shadowMask;
}

- (void)setShadowMask:(CommonInnerShadowMask)shadowMask
{
    [self innerShadowLayer].shadowMask = shadowMask;
}

- (UIColor *)shadowColor
{
    return [UIColor colorWithCGColor:[self innerShadowLayer].shadowColor];
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    [self innerShadowLayer].shadowColor = shadowColor.CGColor;
}

- (CGFloat)shadowOpacity
{
    return [self innerShadowLayer].shadowOpacity;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    [self innerShadowLayer].shadowOpacity = shadowOpacity;
}

- (CGSize)shadowOffset
{
    return [self innerShadowLayer].shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    [self innerShadowLayer].shadowOffset = shadowOffset;
}

- (CGFloat)shadowRadius
{
    return [self innerShadowLayer].shadowRadius;
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    [self innerShadowLayer].shadowRadius = shadowRadius;
}

- (CGFloat)cornerRadius
{
    return [self innerShadowLayer].cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    
    [self innerShadowLayer].cornerRadius = cornerRadius;
}

- (void)setupInnerShadow
{
    // add as sublayer so that self.backgroundColor will work nicely
    [self setInnerShadowLayer:[CommonInnerShadow layer]];
    [self innerShadowLayer].frame = self.layer.bounds;
    [self innerShadowLayer].actions = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNull null], @"position",
                                       [NSNull null], @"bounds",
                                       [NSNull null], @"contents",
                                       [NSNull null], @"shadowColor",
                                       [NSNull null], @"shadowOpacity",
                                       [NSNull null], @"shadowOffset",
                                       [NSNull null], @"shadowRadius",
                                       nil];
    
    self.layer.masksToBounds = YES;
    
    [self.layer insertSublayer:[self innerShadowLayer] atIndex:0];
}

@end
