//  Created by Alessio on 25/11/13.
//  Copyright (c) 2013 Karen Lusinyan. All rights reserved.

#import <Foundation/Foundation.h>

@protocol ALESecondaryViewControllerDelegate <NSObject>

@optional
- (void)didPressCloseButtonInSecondaryController:(UIViewController *)controller;
- (void)didSelectObject:(id)object inSecondaryViewController:(UIViewController *)controller;
- (void)didDeleteObject:(id)object inSecondaryViewController:(UIViewController *)controller;
- (void)didPressButton:(UIButton *)button inSecondaryViewController:(UIViewController *)controller;
- (void)didPressButtonWithTag:(NSUInteger)tag inSecondaryViewController:(UIViewController *)controller;
- (void)didAddObject:(id)object inSecondaryViewController:(UIViewController *)controller;
- (void)didSaveObject:(id)object inSecondaryViewController:(UIViewController *)controller;
- (void)didPressSendButtonInSecondaryController:(UIViewController *)controller;
- (void)didCompleteTaskWithResult:(id)result inSecondaryController:(UIViewController *)controller;
- (void)didPressSystemItemWithType:(UIBarButtonSystemItem)systemItem inSecondaryViewController:(UIViewController *)controller;

@end
