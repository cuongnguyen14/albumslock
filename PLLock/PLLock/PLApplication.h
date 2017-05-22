//
//  PLApplication.h
//  PLLock
//
//  Created by CuongNguyen on 5/22/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNThemeManager.h"

#define sApplication [PLApplication sharedInstance]

@interface PLApplication : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) CNThemeManager *theme;

@end
