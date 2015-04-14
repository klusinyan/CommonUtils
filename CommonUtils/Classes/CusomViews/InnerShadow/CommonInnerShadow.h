//  Created by Yasuhiro Inami on 2012/10/14.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//  Modified by Karen Lusinyan on 2015/04/10

typedef NS_ENUM(NSInteger, CommonInnerShadowMask) {
    CommonInnerShadowMaskNone       = 0,
    CommonInnerShadowMaskTop        = 1 << 1,
    CommonInnerShadowMaskBottom     = 1 << 2,
    CommonInnerShadowMaskLeft       = 1 << 3,
    CommonInnerShadowMaskRight      = 1 << 4,
    CommonInnerShadowMaskVertical   = CommonInnerShadowMaskTop | CommonInnerShadowMaskBottom,
    CommonInnerShadowMaskHorizontal = CommonInnerShadowMaskLeft | CommonInnerShadowMaskRight,
    CommonInnerShadowMaskAll        = CommonInnerShadowMaskVertical | CommonInnerShadowMaskHorizontal
};

//
// Ideas from Matt Wilding:
// http://stackoverflow.com/questions/4431292/inner-shadow-effect-on-uiview-layer
//
@interface CommonInnerShadow : CAShapeLayer

@property (nonatomic) CommonInnerShadowMask shadowMask;

@end

@protocol InnerShadowAdapter <NSObject>

@required
@property (nonatomic, strong) CommonInnerShadow *innerShadowLayer;

@property (nonatomic) CommonInnerShadowMask shadowMask;

@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic)         CGFloat  shadowOpacity;
@property (nonatomic)         CGSize   shadowOffset;
@property (nonatomic)         CGFloat  shadowRadius;
@property (nonatomic)         CGFloat  cornerRadius;

- (void)setupInnerShadow;

@end

@interface UIView (InnerShadow) <InnerShadowAdapter>

@end

@interface UIButton (InnerShadow) <InnerShadowAdapter>

@end

