
#import "CNBaseColorKit.h"

@implementation CNBaseColorKit

/////////////////////////////////////////////////////////
- (UIColor *)CN_backgroundColor {
    return kMakeColor(152, 192, 95, 1.0);
}
- (UIColor *)CN_tintColor {
    return [UIColor whiteColor];
}
- (UIColor *)CN_invertColor {
    return [UIColor blackColor];
}
/////////////////////////////////////////////////////////

#pragma mark - tabbar

- (UIColor *)CN_tabbarColor {
    return kMakeColor(35, 35, 35, 1.0);
}

- (UIColor *)CN_tabbarLineColor {
    return [self CN_separatorColor];
}

- (UIColor *)CN_navigationColor {
    return kMakeColor(29, 30, 33, 1.0);
}

- (UIColor *)CN_navigationTintColor {
    return [self CN_tintColor];
}

- (UIColor *)CN_navigationBarBottomLineColor {
    return [self CN_viewBackgroundColor];
}

- (UIColor *)CN_viewBackgroundColor {
    return [UIColor blackColor];
}

- (UIColor *)CN_cellBackgroundColor {
    return [self CN_viewBackgroundColor];
}

- (UIColor *)CN_textColor {
    return [UIColor whiteColor];
}

- (UIColor *)CN_errorTextColor {
    return [self CN_textColor];
}

- (UIColor *)CN_textHighLightColor {
    return [self CN_tintColor];
}

- (UIColor *)CN_subTextColor {
    return kMakeColor(146, 146, 146, 1);
}

- (UIColor *)CN_disableColor {
    return [[self CN_backgroundColor] blendWithColor:[self CN_tintColor] alpha:0.7];
}

- (UIColor *)CN_cellSelectedColor {
    return [[self CN_cellBackgroundColor] blendWithColor:[self CN_invertColor] alpha:0.1];
}

- (UIColor *)CN_titleColor {
    return [UIColor whiteColor];
}

- (UIColor *)CN_separatorColor {
    return [UIColor colorWithRed:42/255.f green:44/255.f blue:47/255.f alpha:1];
}

- (UIColor *)CN_headerBackgroundColor {
    return [UIColor colorWithRed:18/255.f green:19/255.f blue:20/255.f alpha:1];
}

#pragma mark - Status bar

- (UIStatusBarStyle)CN_styleStatusBar {
    return UIStatusBarStyleLightContent;
}

@end
