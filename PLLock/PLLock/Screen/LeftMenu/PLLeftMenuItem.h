//
//  PLLeftMenuItem.h
//  PLLock
//
//  Created by CuongNguyen on 6/13/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLLeftMenuItem : NSObject

@property (nonatomic) NSString *iconName;
@property (nonatomic) NSString *displayTitle;

- (instancetype)initWithIconName:(NSString *)iconName title:(NSString *)title;

@end
