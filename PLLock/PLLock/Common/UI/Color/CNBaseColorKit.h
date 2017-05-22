
#import <Foundation/Foundation.h>
#import "UIColor+HDExtensions.h"

#define kMakeColor(r,g,b,a) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a]

@interface CNBaseColorKit : NSObject

#pragma mark - Tabbar
- (UIColor *)CN_tabbarColor;
- (UIColor *)CN_tabbarLineColor;

#pragma mark - ....
- (UIColor *)CN_navigationColor;
- (UIColor *)CN_navigationTintColor;

- (UIColor *)CN_viewBackgroundColor;
- (UIColor *)CN_navigationBarBottomLineColor;

- (UIColor *)CN_cellBackgroundColor;
- (UIColor *)CN_cellSelectedColor;
- (UIColor *)CN_separatorColor;

- (UIColor *)CN_titleColor;
- (UIColor *)CN_textColor;
- (UIColor *)CN_textHighLightColor;
- (UIColor *)CN_subTextColor;
- (UIColor *)CN_errorTextColor;

- (UIColor *)CN_tintColor;
- (UIColor *)CN_disableColor;

- (UIColor *)CN_headerBackgroundColor;

- (UIStatusBarStyle)CN_styleStatusBar;

@end
