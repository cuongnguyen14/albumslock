//
//  NSString+DLStringValidater.h
//  Downloader
//
//  Created by CuongNguyenNgoc on 11/24/15.
//  Copyright © 2015 HDApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DLStringValidater)

-(BOOL)isValidURL;
- (NSString *)getTrucateStringWithAlert:(UIAlertController *)alert;

@end
