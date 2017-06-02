//
//  PLImportPhotoManager.h
//  PLLock
//
//  Created by CuongNguyen on 6/2/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

#define sImport [PLImportPhotoManager shareInstance]

@interface PLImportPhotoManager : NSObject

+ (instancetype)shareInstance;

-(void)import:(NSArray <UIImage *> *)photos
       assets:(NSArray<PHAsset *> *)assets
  destination:(CNFolderComponent *)folder
completedBlock:(void (^)(NSError *error))completedBlock;


@end
