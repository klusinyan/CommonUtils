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
    return [objc_getAssociatedObject(self, @selector(shadowMask)) integerValue];
}

- (void)setShadowMask:(CommonInnerShadowMask)shadowMask
{
    objc_setAssociatedObject(self, @selector(shadowMask), @(shadowMask), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)shadowColor
{
    return objc_getAssociatedObject(self, @selector(shadowColor));
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    objc_setAssociatedObject(self, @selector(shadowColor), shadowColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)shadowOpacity
{
    return [objc_getAssociatedObject(self, @selector(shadowOpacity)) integerValue];
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    objc_setAssociatedObject(self, @selector(shadowOpacity), @(shadowOpacity), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)shadowOffset
{
    return [objc_getAssociatedObject(self, @selector(shadowOffset)) CGSizeValue];
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    objc_setAssociatedObject(self, @selector(shadowOffset), [NSValue valueWithCGSize:shadowOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)shadowRadius
{
    return [objc_getAssociatedObject(self, @selector(shadowRadius)) integerValue];
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    objc_setAssociatedObject(self, @selector(shadowRadius), @(shadowRadius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)cornerRadius
{
    return [objc_getAssociatedObject(self, @selector(cornerRadius)) integerValue];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    objc_setAssociatedObject(self, @selector(cornerRadius), @(cornerRadius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setupAppearance
{
    // add as sublayer so that self.backgroundColor will work nicely
    [self setInnerShadowLayer:[CommonInnerShadow layer]];
    [self innerShadowLayer].actions = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNull null], @"position",
                                       [NSNull null], @"bounds",
                                       [NSNull null], @"contents",
                                       [NSNull null], @"shadowColor",
                                       [NSNull null], @"shadowOpacity",
                                       [NSNull null], @"shadowOffset",
                                       [NSNull null], @"shadowRadius",
                                       nil];
    
    [self.layer addSublayer:[self innerShadowLayer]];
    self.layer.masksToBounds = YES;
    self.userInteractionEnabled = NO;
}

- (void)layoutSubviews
{
    [self innerShadowLayer].frame = self.layer.bounds;
}

@end
