
#import <Foundation/Foundation.h>
#import "CNBaseColorKit.h"

@interface CNThemeManager : NSObject

@property (nonatomic, strong, readonly) CNBaseColorKit *color;

+ (instancetype)shareInstance;

@end
