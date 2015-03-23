//  Created by Karen Lusinyan on 15/06/14.
//  Copyright (c) 2014 Karen Lusinyan. All rights reserved.

#import "CommonBanner.h"

@interface CommonBannerViewController : UIViewController <CommonBannerDelegate, CommonBannerDataSource>

@property (readwrite, nonatomic, assign) BOOL canDisplayAds;

@end
