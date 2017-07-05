//
//  PLImportPhotoManager.m
//  PLLock
//
//  Created by CuongNguyen on 6/2/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import "PLImportPhotoManager.h"
#import "SHPImagePickerController.h"

@implementation PLImportPhotoManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static id _shareInstance = nil;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[self alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)import:(NSArray <UIImage *> *)photos
       assets:(NSArray<PHAsset *> *)assets
  destination:(CNFolderComponent *)folder
deletedAfterSuccess:(BOOL)deleted
completedBlock:(void (^)(NSError *error))completedBlock {
    
    weakify(self);
    for (int i=0;i<photos.count;i++) {
        
        UIImage *image = photos[i];
        PHAsset *asset = assets[i];
        
        [self __import:image assets:asset destination:folder completedBlock:^(NSError *error) {
            if (i == photos.count - 1) {
                
                if (deleted) {
                    [self_weak_ deleted:assets completedBlock:completedBlock];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completedBlock) {
                            completedBlock(nil);
                        }
                    });
                }
                
                return;
            }
        }];
    }
    
}

-(void)takePhoto:(UIViewController *)vc
     destination:(CNFolderComponent *)folder
  completedBlock:(void (^)(NSError *error))completedBlock {
    
    [SHPImagePickerController showImagePickerOfType:SHPImagePickerTypeCamera fromViewController:vc success:^(UIImage *image) {
        
        double timestamp = [[NSDate date] timeIntervalSince1970];
        
        //Photo Name
        NSString *imageName = [NSString stringWithFormat:@"%f.png", timestamp];
        NSString *filePath = [[folder absolutePath] stringByAppendingPathComponent:imageName];
        
        //Photo thumbnail name
        NSString *imageThumbnailName = [NSString stringWithFormat:@".%f.png", timestamp];
        NSString *thumbnailFilePath = [[folder absolutePath] stringByAppendingPathComponent:imageThumbnailName];
        
        //1.Write thumbnail
        
        [UIImagePNGRepresentation(image) writeToFile:thumbnailFilePath atomically:YES];
        
        //2. Write a Photo
        BOOL success = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completedBlock) {
                completedBlock(success ? nil : [NSError new]);
            }
        });
        
    } autoDismiss:YES];
}

-(void)__import:(UIImage *)image
         assets:(PHAsset *)asset
    destination:(CNFolderComponent *)folder
 completedBlock:(void (^)(NSError *error))completedBlock {
    
    NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
    NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
    
    //Photo Name
    NSString *imageName = orgFilename;
    NSString *filePath = [[folder absolutePath] stringByAppendingPathComponent:imageName];
    
    //Photo thumbnail name
    NSString *imageThumbnailName = [NSString stringWithFormat:@".%@", imageName];
    NSString *thumbnailFilePath = [[folder absolutePath] stringByAppendingPathComponent:imageThumbnailName];
    
    //1.Write a thumbnail
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = YES;
    CGSize retinaSquare = CGSizeMake(150, 150);
    [[PHImageManager defaultManager] requestImageForAsset:(PHAsset *)asset
                                               targetSize:retinaSquare
                                              contentMode:PHImageContentModeAspectFill
                                                  options:options
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                
                                                [UIImagePNGRepresentation(result) writeToFile:thumbnailFilePath atomically:YES];
                                                
                                                //2. Write a Photo
                                                BOOL success = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if (completedBlock) {
                                                        completedBlock(success ? nil : [NSError new]);
                                                    }
                                                });
                                            }];
}

-(void)deleted:(NSArray *)assets completedBlock:(void (^)(NSError *error))completedBlock {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:assets];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                if (completedBlock) {
                    completedBlock(nil);
                }
            } else {
                if (completedBlock) {
                    completedBlock(error);
                }
            }
        });
    }];
}

-(void)importVideo:(UIImage *)cover
            assets:(PHAsset *)asset
       destination:(CNFolderComponent *)folder
deletedAfterSuccess:(BOOL)deleted
    completedBlock:(void (^)(NSError *error))completedBlock {
    
    NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
    NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
    
    //Video Name
    NSString *videoName = orgFilename;
    NSString *filePath = [[folder absolutePath] stringByAppendingPathComponent:videoName];
    
    //Photo thumbnail name
    NSString *imageThumbnailName = [NSString stringWithFormat:@".%@", videoName];
    NSString *thumbnailFilePath = [[folder absolutePath] stringByAppendingPathComponent:imageThumbnailName];
    
    //1.Write a thumbnail
    [UIImagePNGRepresentation(cover) writeToFile:thumbnailFilePath atomically:YES];
    
    //2.Write a Video
    weakify(self);
    
    
    PHVideoRequestOptions *options = [PHVideoRequestOptions new];
    options.version = PHVideoRequestOptionsVersionOriginal;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset
                                                    options:options
                                              resultHandler:
     ^(AVAsset * _Nullable avasset,
       AVAudioMix * _Nullable audioMix,
       NSDictionary * _Nullable info)
     {
         NSError *error;
         AVURLAsset *avurlasset = (AVURLAsset*) avasset;
         NSURL *fileURL = [NSURL fileURLWithPath:filePath];
         if ([[NSFileManager defaultManager] copyItemAtURL:avurlasset.URL
                                                     toURL:fileURL
                                                     error:&error]) {
             NSLog(@"Copied correctly");
             if (deleted) {
                 [self_weak_ deleted:@[asset] completedBlock:completedBlock];
             } else {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (completedBlock) {
                         completedBlock(nil);
                     }
                 });
             }

         }
     }];
    
//    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
//    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
//        AVURLAsset* myAsset = (AVURLAsset*)avasset;
//        NSData * data = [NSData dataWithContentsOfFile:myAsset.URL.relativePath];
//        BOOL success = NO;
//        if (data) {
//            success = [data writeToFile:filePath atomically:YES];
//        }
//        
//        if (deleted) {
//            [self_weak_ deleted:@[asset] completedBlock:completedBlock];
//        } else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (completedBlock) {
//                    completedBlock(success ? nil : [NSError new]);
//                }
//            });
//        }
//    }];
}

@end
