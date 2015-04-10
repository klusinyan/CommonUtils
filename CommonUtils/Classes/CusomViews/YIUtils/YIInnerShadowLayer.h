//  Created by Yasuhiro Inami on 2012/10/14.
//  Copyright (c) 2012年 Yasuhiro Inami. All rights reserved.
//  Modified by Karen Lusinyan on 2015/04/10

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, YIInnerShadowMask) {
    YIInnerShadowMaskNone       = 0,
    YIInnerShadowMaskTop        = 1 << 1,
    YIInnerShadowMaskBottom     = 1 << 2,
    YIInnerShadowMaskLeft       = 1 << 3,
    YIInnerShadowMaskRight      = 1 << 4,
    YIInnerShadowMaskVertical   = YIInnerShadowMaskTop | YIInnerShadowMaskBottom,
    YIInnerShadowMaskHorizontal = YIInnerShadowMaskLeft | YIInnerShadowMaskRight,
    YIInnerShadowMaskAll        = YIInnerShadowMaskVertical | YIInnerShadowMaskHorizontal
};

//
// Ideas from Matt Wilding:
// http://stackoverflow.com/questions/4431292/inner-shadow-effect-on-uiview-layer
//
@interface YIInnerShadowLayer : CAShapeLayer

@property (nonatomic) YIInnerShadowMask shadowMask;

@end

// protocol adapter
@protocol InnerShadowAdapter <NSObject>

@required
@property (nonatomic, strong) YIInnerShadowLayer* innerShadowLayer;

@property (nonatomic) YIInnerShadowMask shadowMask;

@property (nonatomic, strong) UIColor* shadowColor;
@property (nonatomic)         CGFloat  shadowOpacity;
@property (nonatomic)         CGSize   shadowOffset;
@property (nonatomic)         CGFloat  shadowRadius;
@property (nonatomic)         CGFloat  cornerRadius;

- (void)setupAppearance;

@end

// categories
@interface UIView (InnerShadow) <InnerShadowAdapter>

@end

/*
@interface UITableView (InnerShadow) <InnerShadowAdapter>

@end

@interface UIButton (InnerShadow) <InnerShadowAdapter>

@end

@interface SKView (InnerShadow) <InnerShadowAdapter>

@end
 //*/

