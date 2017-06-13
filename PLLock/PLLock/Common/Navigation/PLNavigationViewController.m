//
//  PLNavigationViewController.m
//  PLLock
//
//  Created by CuongNguyen on 6/13/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import "PLNavigationViewController.h"
#import "UIViewController+LGSideMenuController.h"

@interface PLNavigationViewController () <UINavigationControllerDelegate>

@property (nonatomic,strong) UIBarButtonItem *leftBarButton;
@property (nonatomic,strong) UIBarButtonItem *rightBarButton;
@property (nonatomic,strong) UIBarButtonItem *backButton;

@end

@implementation PLNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:@"btn_left_menu"];
    self.leftBarButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(_touchOnLeftBarButtonItem:)];
    self.leftBarButton.tintColor = [UIColor lightGrayColor];

    self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    [self.navigationBar setTranslucent:NO];
    self.delegate = self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_touchOnLeftBarButtonItem:(UIBarButtonItem *)sender {
    [self showLeftViewAnimated:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self.viewControllers.firstObject isEqual:viewController]) {
        viewController.navigationItem.leftBarButtonItem = self.leftBarButton;
    }
    if (viewController.navigationItem.backBarButtonItem != self.backButton) {
        viewController.navigationItem.backBarButtonItem = self.backButton;
    }
}


@end
