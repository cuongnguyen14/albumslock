//
//  UIViewController+Extra.m
//  PLLock
//
//  Created by CuongNguyen on 5/22/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import <objc/runtime.h>

@implementation UIViewController (Extra)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        {
            SEL originalSelector = @selector(initWithNibName:bundle:);
            SEL swizzledSelector = @selector(___initWithNibName:bundle:);
            
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            
            BOOL didAddMethod =
            class_addMethod(class,
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
            
            if (didAddMethod) {
                class_replaceMethod(class,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
        
    });
}

- (instancetype)___initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    NSString *nibName = nibNameOrNil;
    NSBundle *nibBundle = nibBundleOrNil;
    if (!nibName) {
        nibName = NSStringFromClass([self class]);
    }
    if (!nibBundle) {
        nibBundle = [NSBundle mainBundle];
    }
    BOOL isIPHONE4 = (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON);
    BOOL isIPHONE5 = (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON);
    BOOL isIPHONE6 = (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON);
    BOOL isIPHONE6PLUS= (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON);
    BOOL isIPAD= (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)1024) < DBL_EPSILON);
    BOOL haveFindedXib = NO;
    if (!haveFindedXib && isIPHONE6PLUS) {
        NSString *tempNibName = [nibName stringByAppendingString:@"-iPhone6+"];
        NSString *path = [nibBundle pathForResource:tempNibName ofType:@"nib"];
        if (path!=nil) {
            haveFindedXib = YES;
            nibName = tempNibName;
        }
    }
    if (!haveFindedXib && isIPHONE6) {
        NSString *tempNibName = [nibName stringByAppendingString:@"-iPhone6"];
        NSString *path = [nibBundle pathForResource:tempNibName ofType:@"nib"];
        if (path!=nil) {
            haveFindedXib = YES;
            nibName = tempNibName;
        }
    }
    if (!haveFindedXib && isIPHONE5) {
        NSString *tempNibName = [nibName stringByAppendingString:@"-iPhone5"];
        NSString *path = [nibBundle pathForResource:tempNibName ofType:@"nib"];
        if (path!=nil) {
            haveFindedXib = YES;
            nibName = tempNibName;
        }
    }
    if (!haveFindedXib && isIPHONE4) {
        NSString *tempNibName = [nibName stringByAppendingString:@"-iPhone4"];
        NSString *path = [nibBundle pathForResource:tempNibName ofType:@"nib"];
        if (path!=nil) {
            haveFindedXib = YES;
            nibName = tempNibName;
        }
    }
    
    if (!haveFindedXib && isIPAD) {
        NSString *tempNibName = [nibName stringByAppendingString:@"-iPad"];
        NSString *path = [nibBundle pathForResource:tempNibName ofType:@"nib"];
        if (path!=nil) {
            haveFindedXib = YES;
            nibName = tempNibName;
        }
    }
    
    if (!haveFindedXib) {
        NSString *path = [nibBundle pathForResource:nibName ofType:@"nib"];
        if (path==nil) {
            nibName = nibNameOrNil;
            nibBundle = nibBundleOrNil;
        }
    }
    
    self = [self ___initWithNibName:nibName bundle:nibBundle];
    if (self) {
        
    }
    return self;
}


@end
