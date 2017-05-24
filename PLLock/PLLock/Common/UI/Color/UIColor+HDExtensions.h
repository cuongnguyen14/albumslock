//
//  UIColor+HDExtensions.h
//  Musitube
//
//  Created by CuongNguyenNgoc on 1/19/16.
//  Copyright © 2016 CNLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HDExtensions)

- (UIColor*)blendWithColor:(UIColor*)color2 alpha:(CGFloat)alpha2;

- (UIColor*)colorWithColor:(UIColor*)color alpha:(CGFloat)alpha;

@end
