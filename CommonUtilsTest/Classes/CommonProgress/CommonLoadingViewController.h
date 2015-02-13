//  Created by Karen Lusinyan on 13/02/15.
//  Copyright (c) 2015 Karen Lusinyan. All rights reserved.

@interface CommonLoadingViewController : UIViewController

@property (readwrite, nonatomic, strong) UIColor *backgroundColor;
@property (readwrite, nonatomic, strong) UIColor *themeColor;

+ (instancetype)instanceWithTarget:(id)target;

@end
