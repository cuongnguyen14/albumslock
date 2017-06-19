//
//  NSString+DLStringValidater.m
//  Downloader
//
//  Created by CuongNguyenNgoc on 11/24/15.
//  Copyright © 2015 HDApps. All rights reserved.
//

#import "NSString+DLStringValidater.h"

@implementation NSString (DLStringValidater)

-(BOOL)isValidURL {
    NSString *urlRegEx =
    @"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&amp;=]*)?";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:self];
}

- (NSString *)getTrucateStringWithAlert:(UIAlertController *)alert {
    if (!self || !alert)
        return @"";
    
    float sizeMax = alert.view.frame.size.width - 20;
    float sizePerCharaters = 10;
    
    if ( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        sizePerCharaters = 24;
        sizeMax += 40;
        
    }
    const char *chars = [self UTF8String];
    size_t lengthUTF8String = strlen(chars);
    if (lengthUTF8String*sizePerCharaters <= sizeMax )
        return self;
    int indexTrucate = sizeMax /(sizePerCharaters*2);
    NSString* str1 = [[self substringToIndex: indexTrucate ] stringByAppendingString:@"..."];
    NSString *str2 =  [self substringFromIndex:lengthUTF8String - indexTrucate];
    return [str1 stringByAppendingString:str2];
}

@end
