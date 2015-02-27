//  Created by Karen Lusinyan on 27/02/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

#import "CommonAnimation.h"

@protocol CommonPageContentDelegate;

@interface CommonPageContent : UIViewController <CommonAnimationDelegate>

@property (nonatomic) UIColor *backgroundColor;

@property (nonatomic, getter=isZoomEnabled) BOOL zoomEnabled;       //defualt NO

@property (nonatomic) UIImage *image;

@property (readonly, nonatomic) UIImageView *imageView;

@property (nonatomic) NSArray *animations;

@property (nonatomic) CGFloat leadingSpaceWhenPortrait;
@property (nonatomic) CGFloat topSpaceWhenPortrait;
@property (nonatomic) CGFloat leadingSpaceWhenLandscape;
@property (nonatomic) CGFloat topSpaceWhenLandscape;

#pragma CommonAnimationDelegate

@property (nonatomic) CommonAnimationRule animationRule;

@property (nonatomic, getter=isAnimated) BOOL animated;

//not used
@property (nonatomic) id<CommonPageContentDelegate> delegate;

+ (instancetype)pageContent;

@end


//not used
@protocol CommonPageContentDelegate <NSObject>

@optional
- (void)pageContentDidLoad:(CommonPageContent *)content;

- (void)pageContentWillAppear:(CommonPageContent *)content;

- (void)pageContentDidAppear:(CommonPageContent *)content;

- (void)pageContentWillDisappear:(CommonPageContent *)content;

- (void)pageContentDidDisappear:(CommonPageContent *)content;

@end

