
#import "CNThemeManager.h"
#import "CNBaseColorKit.h"

@interface CNThemeManager ()

@property (nonatomic, strong, readwrite) CNBaseColorKit *color;

@end

@implementation CNThemeManager

+ (instancetype)shareInstance {
    static CNThemeManager *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!shareInstance) {
            shareInstance = [[self alloc] init];
        }
    });
    return shareInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        
        //COLOR
        self.color = [[NSClassFromString(@"CNBaseColorKit") alloc] init];
        if (!self.color) {
            self.color = [[CNBaseColorKit alloc] init];
        }
        
        //FONT
        
        
    }
    return self;
}

@end
