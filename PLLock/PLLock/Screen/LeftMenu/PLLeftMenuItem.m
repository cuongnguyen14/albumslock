//
//  PLLeftMenuItem.m
//  PLLock
//
//  Created by CuongNguyen on 6/13/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import "PLLeftMenuItem.h"

@implementation PLLeftMenuItem

- (instancetype)initWithIconName:(NSString *)iconName title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.iconName = iconName;
        self.displayTitle = title;
    }
    return self;
}
@end
