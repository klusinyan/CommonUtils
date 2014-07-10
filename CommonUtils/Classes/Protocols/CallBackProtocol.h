//  Created by Karen Lusinyan on 5/28/13.
//  Copyright (c) 2013 Home. All rights reserved.

@protocol CallBackProtocol <NSObject>

typedef void (^CallBack)(void);

@property (readwrite, nonatomic, copy) CallBack callBack;

@end
