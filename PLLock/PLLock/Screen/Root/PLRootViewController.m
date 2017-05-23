//
//  PLRootViewController.m
//  PLLock
//
//  Created by CuongNguyen on 5/22/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import "PLRootViewController.h"
#import "PLAlbumsViewController.h"
#import "PLRightTableTableViewController.h"
#import "PLLeftMenuTableViewController.h"

@interface PLRootViewController ()

@property (nonatomic) UIViewController *topVC;

@end

@implementation PLRootViewController

+ (instancetype)rootViewController {
    
    UIViewController *rootViewController = [PLAlbumsViewController new];
    UITableViewController *leftViewController = [PLLeftMenuTableViewController new];
    UITableViewController *rightViewController = [PLRightTableTableViewController new];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    PLRootViewController *sideMenuController =
        [PLRootViewController sideMenuControllerWithRootViewController:navigationController
                                                    leftViewController:leftViewController
                                                   rightViewController:rightViewController];
    float scaleRatio = 0.7;
    
    sideMenuController.leftViewWidth = [UIScreen mainScreen].bounds.size.width * scaleRatio;
    sideMenuController.leftViewPresentationStyle = LGSideMenuPresentationStyleSlideBelow;
    sideMenuController.leftViewSwipeGestureEnabled = YES;
    
    sideMenuController.rightViewWidth = [UIScreen mainScreen].bounds.size.width * scaleRatio;
    sideMenuController.rightViewPresentationStyle = LGSideMenuPresentationStyleSlideBelow;
    sideMenuController.rightViewSwipeGestureEnabled = YES;

    
    return sideMenuController;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
