//
//  PLLeftMenuTableViewCell.h
//  PLLock
//
//  Created by CuongNguyen on 6/13/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLLeftMenuItem.h"

@interface PLLeftMenuTableViewCell : UITableViewCell

-(void)displayWithModel:(PLLeftMenuItem *)model;

@end
