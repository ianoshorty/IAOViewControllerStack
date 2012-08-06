//
//  UIViewController+IAOUIViewControllerStack.m
//  IAOUIViewController
//
//  Created by Ian Outterside on 4/08/12.
//
//

#import "UIViewController+IAOUIViewControllerStack.h"
#import <objc/runtime.h>

static char kIAOROOTVIEWCONTROLLER_IDENTIFIER;

@implementation UIViewController (IAOUIViewControllerStack)

- (void)pushViewController:(UIViewController *)controller animated:(BOOL)animated {
    [self pushViewController:controller animated:animated completion:nil];
}

- (void)pushViewController:(UIViewController *)controller animated:(BOOL)animated completion:(void (^)(void))success {
    
    UIViewController *rootViewController = [self rootViewControllerForNavigationStack];
    
    objc_setAssociatedObject(controller, &kIAOROOTVIEWCONTROLLER_IDENTIFIER, rootViewController, OBJC_ASSOCIATION_ASSIGN);
    
    BOOL previousClip = rootViewController.view.clipsToBounds;
    rootViewController.view.clipsToBounds = YES;
    
    // Transition
    if ([rootViewController.childViewControllers count] > 0) {
        UIViewController *previousViewController = [rootViewController.childViewControllers objectAtIndex:([rootViewController.childViewControllers count] - 1)];
        [rootViewController addChildViewController:controller];
        
        if (animated) {
            controller.view.frame = CGRectMake(rootViewController.view.bounds.origin.x + rootViewController.view.bounds.size.width, rootViewController.view.bounds.origin.y, controller.view.frame.size.width, controller.view.frame.size.height);
            
            [UIView animateWithDuration:0.3 animations:^{
                previousViewController.view.frame = CGRectMake(rootViewController.view.bounds.origin.x - rootViewController.view.bounds.size.width, rootViewController.view.bounds.origin.y, previousViewController.view.frame.size.width, previousViewController.view.frame.size.height);
            }];
        }
        
        [rootViewController transitionFromViewController:previousViewController toViewController:controller duration:0.3 options:UIViewAnimationCurveLinear animations:^{
            
            if (animated) {
                controller.view.frame = CGRectMake(rootViewController.view.bounds.origin.x, rootViewController.view.bounds.origin.y, controller.view.frame.size.width, controller.view.frame.size.height);
            }
            
        } completion:^(BOOL finished) {
            [controller didMoveToParentViewController:rootViewController];
            
            rootViewController.view.clipsToBounds = previousClip;
            
            if (success) {
                success();
            }
        }];
    }
    else {
        void (^addBlock)(void) = ^{
            [controller didMoveToParentViewController:rootViewController];
            rootViewController.view.clipsToBounds = previousClip;
            
            if (success) {
                success();
            }
        };
        
        controller.view.frame = rootViewController.view.bounds;
        [rootViewController addChildViewController:controller];
        [rootViewController.view addSubview:controller.view];
        
        if (animated) {
            
            controller.view.frame = CGRectMake(rootViewController.view.bounds.origin.x + rootViewController.view.bounds.size.width, rootViewController.view.bounds.origin.y, rootViewController.view.bounds.size.width, rootViewController.view.bounds.size.height);
            
            [UIView animateWithDuration:0.3 animations:^{
                
                controller.view.frame = rootViewController.view.bounds;
                
            } completion:^(BOOL finished) {
                
                addBlock();
                
            }];
            
        }
        else {
            addBlock();
        }
    }
}

- (void)popViewControllerAnimated:(BOOL)animated {
    [self popViewControllerAnimated:animated completion:nil];
}

- (void)popViewControllerAnimated:(BOOL)animated completion:(void (^)(void))success {
    
    UIViewController *rootViewController = [self rootViewControllerForNavigationStack];
    
    // Cant pop if we are at the top
    if (rootViewController == self) {
        return;
    }
    
    BOOL previousClip = rootViewController.view.clipsToBounds;
    rootViewController.view.clipsToBounds = YES;
    
    // Cant pop if we have no children
    if ([rootViewController.childViewControllers count] == 0) {
        return;
    }
    
    UIViewController *topViewController = [rootViewController.childViewControllers objectAtIndex:([rootViewController.childViewControllers count] - 1)];
    
    // Move between top and next child
    if ([rootViewController.childViewControllers count] > 1) {
        UIViewController *nextChildViewController = [rootViewController.childViewControllers objectAtIndex:([rootViewController.childViewControllers count] - 2)];
        
        [topViewController willMoveToParentViewController:nil];
        
        if (animated) {
            nextChildViewController.view.frame = CGRectMake(rootViewController.view.bounds.origin.x - rootViewController.view.bounds.size.width, rootViewController.view.bounds.origin.y, topViewController.view.frame.size.width, topViewController.view.frame.size.height);
            
            [UIView animateWithDuration:0.3 animations:^{
                topViewController.view.frame = CGRectMake(rootViewController.view.bounds.origin.x + rootViewController.view.bounds.size.width, rootViewController.view.bounds.origin.y, topViewController.view.frame.size.width, topViewController.view.frame.size.height);
            }];
        }
        
        [rootViewController transitionFromViewController:topViewController toViewController:nextChildViewController duration:0.3 options:UIViewAnimationCurveLinear animations:^{
            
            if (animated) {
                nextChildViewController.view.frame = CGRectMake(rootViewController.view.bounds.origin.x, rootViewController.view.bounds.origin.y, nextChildViewController.view.frame.size.width, nextChildViewController.view.frame.size.height);
            }
            
        } completion:^(BOOL finished) {
            [topViewController removeFromParentViewController];
            rootViewController.view.clipsToBounds = previousClip;
            
            if (success) {
                success();
            }
        }];
    }
    else {
        void (^removeBlock)(void) = ^{
            [topViewController willMoveToParentViewController:nil];
            [topViewController.view removeFromSuperview];
            [topViewController removeFromParentViewController];
            rootViewController.view.clipsToBounds = previousClip;
            
            if (success) {
                success();
            }
        };
        
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                topViewController.view.frame = CGRectMake(rootViewController.view.bounds.origin.x + rootViewController.view.bounds.size.width, rootViewController.view.bounds.origin.y, topViewController.view.frame.size.width, topViewController.view.frame.size.height);
            } completion:^(BOOL finished) {
                removeBlock();
            }];
        }
        else {
            topViewController.view.frame = CGRectMake(rootViewController.view.bounds.origin.x + rootViewController.view.bounds.size.width, rootViewController.view.bounds.origin.y, topViewController.view.frame.size.width, topViewController.view.frame.size.height);
            
            removeBlock();
        }
        
    }
}

- (void)popToRootViewControllerAnimated:(BOOL)animated {
    [self popToRootViewControllerAnimated:animated completion:nil];
}
- (void)popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))success {
    
    UIViewController *rootViewController = [self rootViewControllerForNavigationStack];
    
    // Cant pop if we are at the top
    if (rootViewController == self) {
        return;
    }
    
    BOOL previousClip = rootViewController.view.clipsToBounds;
    rootViewController.view.clipsToBounds = YES;
    
    // Cant pop if we have no children
    if ([rootViewController.childViewControllers count] == 0) {
        return;
    }
    
    UIViewController *topViewController = [rootViewController.childViewControllers objectAtIndex:([rootViewController.childViewControllers count] - 1)];
    
    while ([rootViewController.childViewControllers count] > 1) {
        UIViewController *controller = [rootViewController.childViewControllers objectAtIndex:([rootViewController.childViewControllers count] - 2)];
        
        [controller willMoveToParentViewController:nil];
        [controller removeFromParentViewController];
    }
    
    void (^removeBlock)(void) = ^{
        [topViewController willMoveToParentViewController:nil];
        [topViewController.view removeFromSuperview];
        [topViewController removeFromParentViewController];
        rootViewController.view.clipsToBounds = previousClip;
        
        if (success) {
            success();
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            topViewController.view.frame = CGRectMake(rootViewController.view.bounds.origin.x + rootViewController.view.bounds.size.width, rootViewController.view.bounds.origin.y, topViewController.view.frame.size.width, topViewController.view.frame.size.height);
        } completion:^(BOOL finished) {
            removeBlock();
        }];
    }
    else {
        topViewController.view.frame = CGRectMake(rootViewController.view.bounds.origin.x + rootViewController.view.bounds.size.width, rootViewController.view.bounds.origin.y, topViewController.view.frame.size.width, topViewController.view.frame.size.height);
        removeBlock();
    }
}

- (UIViewController *)rootViewControllerForNavigationStack {
    
    UIViewController *rvc = (UIViewController *)objc_getAssociatedObject(self, &kIAOROOTVIEWCONTROLLER_IDENTIFIER);
    
    if (rvc) {
        return rvc;
    }
    else {
        return self;
    }
}

@end
