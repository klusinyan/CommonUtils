//  Created by Karen Lusinyan on 27/02/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

@interface CommonPageContent : UIViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGFloat horizontalSpace;                  //defualt 5
@property (nonatomic) CGFloat verticalSpace;                    //defualt 0
@property (nonatomic) UIColor *backgroundColor;                 //default NO
@property (nonatomic, getter=isZoomEnabled) BOOL zoomEnabled;   //defualt NO

+ (instancetype)instance;

@end
