//  Created by Karen Lusinyan on 27/02/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

@interface CommonPageContent : UIViewController

@property (nonatomic) UIColor *backgroundColor;

@property (nonatomic, getter=isZoomEnabled) BOOL zoomEnabled;       //defualt NO

@property (nonatomic) UIImage *image;

@property (readonly, nonatomic) UIImageView *imageView;

@property (nonatomic) CGFloat horizontalSpaceWhenPortrait;
@property (nonatomic) CGFloat verticalSpaceWhenPortrait;
@property (nonatomic) CGFloat horizontalSpaceWhenLandscape;
@property (nonatomic) CGFloat verticalSpaceWhenLandscape;

+ (instancetype)pageContent;

@end
