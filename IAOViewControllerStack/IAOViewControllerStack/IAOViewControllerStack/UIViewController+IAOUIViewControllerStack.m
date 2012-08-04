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
static char kIAOVIEWCONTROLLERSTACK_IDENTIFIER;

@implementation UIViewController (IAOUIViewControllerStack)

- (void)pushViewController:(UIViewController *)controller animated:(BOOL)animated {
    
    UIViewController *rootViewController = [self rootViewControllerForNavigationStack];
    
    NSMutableArray *viewControllerStack = [rootViewController viewControllerStack];
    
    if (!viewControllerStack) {
        viewControllerStack = [NSMutableArray arrayWithCapacity:1];
        objc_setAssociatedObject(rootViewController, &kIAOVIEWCONTROLLERSTACK_IDENTIFIER, viewControllerStack, OBJC_ASSOCIATION_RETAIN);
    }
    
    // Set the viewcontrollers root view controller property
    objc_setAssociatedObject(controller, &kIAOROOTVIEWCONTROLLER_IDENTIFIER, rootViewController, OBJC_ASSOCIATION_ASSIGN);
    
    [rootViewController addChildViewController:controller];
    
    // Transition
    if ([viewControllerStack count] > 0) {
        UIViewController *previousViewController = [viewControllerStack objectAtIndex:([viewControllerStack count] - 1)];
        
        controller.view.frame = CGRectMake(rootViewController.view.bounds.origin.x + rootViewController.view.bounds.size.width, rootViewController.view.bounds.origin.y, controller.view.frame.size.width, controller.view.frame.size.height);
        
        if (animated) {
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
    
            // Add the viewcontroller to the stack
            [viewControllerStack addObject:controller];
        }];
    }
    else {
        void (^addBlock)(void) = ^{
            [controller didMoveToParentViewController:rootViewController];
            
            // Add the viewcontroller to the stack
            [viewControllerStack addObject:controller];
        };
        
        controller.view.frame = rootViewController.view.bounds;
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
    
    UIViewController *rootViewController = [self rootViewControllerForNavigationStack];
    
    // Cant pop if we are at the top
    if (rootViewController == self) {
        return;
    }
    
    NSMutableArray *viewControllerStack = [rootViewController viewControllerStack];
    
    // Cant pop if we have no children
    if (!viewControllerStack || [viewControllerStack count] == 0) {
        return;
    }
    
    UIViewController *topViewController = [viewControllerStack objectAtIndex:([viewControllerStack count] - 1)];
    
    // Move between top and next child
    if ([viewControllerStack count] > 1) {
        UIViewController *nextChildViewController = [viewControllerStack objectAtIndex:([viewControllerStack count] - 2)];
    
        nextChildViewController.view.frame = CGRectMake(rootViewController.view.bounds.origin.x - rootViewController.view.bounds.size.width, rootViewController.view.bounds.origin.y, topViewController.view.frame.size.width, topViewController.view.frame.size.height);
        
        [topViewController willMoveToParentViewController:nil];
        
        if (animated) {
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
            [viewControllerStack removeObject:topViewController];
        }];
    }
    else {
        void (^removeBlock)(void) = ^{
            [topViewController willMoveToParentViewController:nil];
            [topViewController.view removeFromSuperview];
            [topViewController removeFromParentViewController];
            [viewControllerStack removeObject:topViewController];
        };
        
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                topViewController.view.frame = CGRectMake(rootViewController.view.bounds.origin.x + rootViewController.view.bounds.size.width, rootViewController.view.bounds.origin.y, topViewController.view.frame.size.width, topViewController.view.frame.size.height);
            } completion:^(BOOL finished) {
                removeBlock();
            }];
        }
        else {
            removeBlock();
        }
        
    }
}

- (void)popToRootViewControllerAnimated:(BOOL)animated {
    
    UIViewController *rootViewController = [self rootViewControllerForNavigationStack];
    
    // Cant pop if we are at the top
    if (rootViewController == self) {
        return;
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

- (NSMutableArray *)viewControllerStack {
    UIViewController *rootViewController = [self rootViewControllerForNavigationStack];
    
    if (rootViewController != self) {
        return nil;
    }
    
    return (NSMutableArray *)objc_getAssociatedObject(self, &kIAOVIEWCONTROLLERSTACK_IDENTIFIER);
}

@end
