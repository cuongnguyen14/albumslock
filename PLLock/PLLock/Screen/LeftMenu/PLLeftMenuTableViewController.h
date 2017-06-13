//
//  PLLeftMenuTableViewController.h
//  PLLock
//
//  Created by CuongNguyen on 5/22/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger{
    LeftMenuCategories = 0,
    LeftMenuAccount = 1,
    LeftMenuNote = 2,
    LeftMenuBrowser = 3,
    LeftMenuSetting = 4
} MenuType;

@class PLLeftMenuTableViewController;

@protocol PLLeftMenuTableViewControllerDelegate <NSObject>

@optional
- (void)PLLeftMenuViewController:(PLLeftMenuTableViewController *)sender didSelectMenuType:(MenuType)type;

@end


@interface PLLeftMenuTableViewController : UITableViewController

@property (weak) id<PLLeftMenuTableViewControllerDelegate> delegate;

@end
