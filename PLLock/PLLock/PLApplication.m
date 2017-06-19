//
//  PLApplication.m
//  PLLock
//
//  Created by CuongNguyen on 5/22/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import "PLApplication.h"

@implementation PLApplication

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.theme = [CNThemeManager shareInstance];
    }
    return self;
}

//if ([folder.fullFileName isEqualToString:@"PHOTOS"]) {
//if ([folder.fullFileName isEqualToString:@"VIDEOS"]) {
//
//if ([folder.fullFileName isEqualToString:@"ACCOUNTS"]) {
//
//if ([folder.fullFileName isEqualToString:@"NOTES"]) {
//
//if ([folder.fullFileName isEqualToString:@"ITUNES ALBUM"]) {

-(void)setupApplication {
    
    [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"ITUNES ALBUM"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"PHOTOS"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"VIDEOS"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"ACCOUNTS"];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"NOTES"];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"User Folder 1"];
                        [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"User Folder 2"];
                        [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"User Folder 3"];
                        [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"User Folder 4"];
                        [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"User Folder 5"];
                        [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"User Folder 6"];
                        [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"User Folder 7"];
                    });
                });
                
            });
            
        });
        
    });
    
    
    
}
@end
