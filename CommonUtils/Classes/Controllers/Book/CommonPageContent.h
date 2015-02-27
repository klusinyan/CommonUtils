//  Created by Karen Lusinyan on 27/02/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

@interface CommonPageContent : UIViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGFloat imageDistance;;
@property (nonatomic) UIColor *backgroundColor;                  //default NO
@property (nonatomic, getter=isZoomEnabled) BOOL zoomEnabled;    //defualt NO

+ (instancetype)instance;

@end
