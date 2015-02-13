//  Created by Karen Lusinyan on 13/02/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

@interface CommonPageContent : UIViewController

@property (readwrite, nonatomic, getter=isZoomEnabled) BOOL zoomEnabled;    //defualt NO
@property (readwrite, nonatomic, strong) UIImage *image;                    //default nil
@property (readwrite, nonatomic, strong) UIColor *backgroundColor;          //defualt clear
@property (readwrite, nonatomic, assign) UIEdgeInsets contentInset;         //defualt UIEdgeInsetsMake(0, 5, 0, 5)

@end
