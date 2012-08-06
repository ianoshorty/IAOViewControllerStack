//
//  TestViewController.m
//  prototype
//
//  Created by Ian Outterside on 4/08/12.
//
//

#import "TestViewController.h"
#import "UIViewController+IAOUIViewControllerStack.h"

@interface TestViewController ()

@end

@implementation TestViewController
@synthesize viewControllerLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.viewControllerLabel.text = self.title;
}

- (void)viewDidUnload
{
    [self setViewControllerLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)addViewControllerPressed:(id)sender {

    UIViewController *rootViewController = [self rootViewControllerForNavigationStack];
    TestViewController *testViewController = [[TestViewController alloc] initWithNibName:@"TestViewController" bundle:[NSBundle mainBundle]];
    testViewController.title = [NSString stringWithFormat:@"%i", [rootViewController.childViewControllers count]];
    
    NSLog(@"Saving %@", testViewController.title);
    
    [self pushViewController:testViewController animated:YES completion:^{
        NSLog(@"%@",[rootViewController childViewControllers]);
    }];
}

- (IBAction)removeViewControllerPressed:(id)sender {
    [self popViewControllerAnimated:YES completion:^{
        UIViewController *rootViewController = [self rootViewControllerForNavigationStack];
        NSLog(@"%@",[rootViewController childViewControllers]);
    }];
}

- (IBAction)rootViewControllerPressed:(id)sender {
    [self popToRootViewControllerAnimated:YES completion:^{
        UIViewController *rootViewController = [self rootViewControllerForNavigationStack];
        NSLog(@"%@",[rootViewController childViewControllers]);
    }];
}

@end
