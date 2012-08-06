//
//  UIViewController+IAOUIViewControllerStack.h
//  IAOUIViewController
//
//  Created by Ian Outterside on 4/08/12.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (IAOUIViewControllerStack)

- (void)pushViewController:(UIViewController *)controller animated:(BOOL)animated;
- (void)pushViewController:(UIViewController *)controller animated:(BOOL)animated completion:(void(^)(void))success;

- (void)popViewControllerAnimated:(BOOL)animated;
- (void)popViewControllerAnimated:(BOOL)animated completion:(void(^)(void))success;

- (void)popToRootViewControllerAnimated:(BOOL)animated;
- (void)popToRootViewControllerAnimated:(BOOL)animated completion:(void(^)(void))success;

- (UIViewController *)rootViewControllerForNavigationStack;

@end
