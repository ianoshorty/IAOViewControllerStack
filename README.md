# IAOViewControllerStack

IAOViewControllerStack is a UIViewController category that adds UINavigationController like push and pull directly to UIViewController.

Its functionality is entirely contained within the category, and it's as easy as including the category header file in your view controllers to gain the functionality.

Optional success callback block parameters are provided in order to be called-back after successful push / pop.

### Push Example

``` objective-c

	TestViewController *testViewController = [[TestViewController alloc] initWithNibName:@"TestViewController" bundle:[NSBundle mainBundle]];
    testViewController.title = @"Next View Controller";
    
    [self pushViewController:testViewController animated:YES];

```

### Pop Example

``` objective-c

	[self popViewControllerAnimated:YES];

```

### Pop To Root Example

``` objective-c

	[self popToRootViewControllerAnimated:YES];

```

## Notes
The category leverages the Objective-C runtime to dynamically associate the required property to your view controllers.  It uses the UIViewController containement methods added in iOS5 in order to display your view controllers.

## Requirements
 - iOS 5+

## Install
Simply copy and paste the 2 files inside the IAOViewControllerStack folder inside the project and #import "UIViewController+IAOUIViewControllerStack.h" in your view controller header

## Example
A small iPad example is inside the project to demo functionality.

## Creator
[Ian Outterside](http://www.twitter.com/ianoshorty)

## License
I intend to full open source this category, though I have not decided on a license.

## Legal
I hereby accept NO liability or responsibility if using this code causes any problems for you.  Always check and test before you import other frameworks / libraries and files into your projects!  This will be inside the license when I decide on one!