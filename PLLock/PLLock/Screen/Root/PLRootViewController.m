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
#import "PLNavigationViewController.h"
#import "PLAccountViewController.h"
#import "PLNoteViewController.h"
#import "PLSettingsViewController.h"
#import "PLBrowserViewController.h"

@interface PLRootViewController () <PLLeftMenuTableViewControllerDelegate>

@property (nonatomic) PLNavigationViewController *categoriesViewControler;
@property (nonatomic) PLNavigationViewController *accountViewControler;
@property (nonatomic) PLNavigationViewController *noteViewControler;
@property (nonatomic) PLNavigationViewController *browserViewControler;
@property (nonatomic) PLNavigationViewController *settingsViewControler;

@end

@implementation PLRootViewController

+ (instancetype)rootViewController {
    
    PLAlbumsViewController *rootViewController = [PLAlbumsViewController new];
    
    PLLeftMenuTableViewController *leftViewController = [PLLeftMenuTableViewController new];
    PLRightTableTableViewController *rightViewController = [PLRightTableTableViewController new];
    
    PLNavigationViewController *navigationController = [[PLNavigationViewController alloc] initWithRootViewController:rootViewController];
    
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
    
    leftViewController.delegate = sideMenuController;
    
    sideMenuController.categoriesViewControler = navigationController;
    
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

-(PLNavigationViewController *)categoriesViewControler {
    if (!_categoriesViewControler) {
        PLAlbumsViewController *viewController = [PLAlbumsViewController new];
        _categoriesViewControler = [[PLNavigationViewController alloc] initWithRootViewController:viewController];
    }
    return _categoriesViewControler;
}

-(PLNavigationViewController *)accountViewControler {
    if (!_accountViewControler) {
        PLAccountViewController *viewController = [PLAccountViewController new];
        _accountViewControler = [[PLNavigationViewController alloc] initWithRootViewController:viewController];
    }
    return _accountViewControler;
}

-(PLNavigationViewController *)noteViewControler {
    if (!_noteViewControler) {
        PLNoteViewController *viewController = [PLNoteViewController new];
        _noteViewControler = [[PLNavigationViewController alloc] initWithRootViewController:viewController];
    }
    return _noteViewControler;
}

-(PLNavigationViewController *)browserViewControler {
    if (!_browserViewControler) {
        PLBrowserViewController *viewController = [PLBrowserViewController new];
        _browserViewControler = [[PLNavigationViewController alloc] initWithRootViewController:viewController];
    }
    return _browserViewControler;
}

-(PLNavigationViewController *)settingsViewControler {
    if (!_settingsViewControler) {
        PLSettingsViewController *viewController = [PLSettingsViewController new];
        _settingsViewControler = [[PLNavigationViewController alloc] initWithRootViewController:viewController];
    }
    return _settingsViewControler;
}

#pragma mark - Leftmenu delegate
- (void)PLLeftMenuViewController:(PLLeftMenuTableViewController *)sender didSelectMenuType:(MenuType)type {
    switch (type) {
        case LeftMenuCategories:
        {
            [self setRootViewController:self.categoriesViewControler];
        }
            break;
            
        case LeftMenuNote:
        {
            [self setRootViewController:self.noteViewControler];
        }
            break;
        case LeftMenuAccount:
        {
            [self setRootViewController:self.accountViewControler];
        }
            break;
        case LeftMenuBrowser:
        {
            [self setRootViewController:self.browserViewControler];
        }
            break;
        case LeftMenuSetting:
        {
            [self setRootViewController:self.settingsViewControler];
        }
            break;
        default:
            break;
    }
    [self hideLeftViewAnimated];

}


@end
