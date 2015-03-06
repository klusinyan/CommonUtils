//  Created by Karen Lusinyan on 27/02/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CommonAnimation.h"

typedef NS_ENUM(NSInteger, CommonPageAnimationRule) {
    CommonPageAnimationRuleNone=0,
    CommonPageAnimationRuleShowOnce,
    CommonPageAnimationRuleShowAlways,
};

@protocol CommonPageContentDelegate;

@interface CommonPageContent : UIViewController

@property (nonatomic) UIColor *backgroundColor;

@property (nonatomic, getter=isZoomEnabled) BOOL zoomEnabled;       //defualt NO

@property (nonatomic) UIImage *image;

@property (nonatomic) NSString *imageUrl;

@property (readonly, nonatomic) UIImageView *imageView;

@property (nonatomic) CGFloat leadingSpaceWhenPortrait;
@property (nonatomic) CGFloat topSpaceWhenPortrait;
@property (nonatomic) CGFloat leadingSpaceWhenLandscape;
@property (nonatomic) CGFloat topSpaceWhenLandscape;

//animations
@property (nonatomic) NSArray *animations;
@property (nonatomic) CommonPageAnimationRule animationRule;

@property (nonatomic) id<CommonPageContentDelegate> delegate;

+ (instancetype)pageContent;

@end

@protocol CommonPageContentDelegate <NSObject>

@optional
- (void)pageContentDidLoad:(CommonPageContent *)content;

- (void)pageContentWillAppear:(CommonPageContent *)content;

- (void)pageContentDidAppear:(CommonPageContent *)content;

- (void)pageContentWillDisappear:(CommonPageContent *)content;

- (void)pageContentDidDisappear:(CommonPageContent *)content;

@end

