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
completedBlock:(void (^)(NSError *error))completedBlock {
    
    for (int i=0;i<photos.count;i++) {
        
        UIImage *image = photos[i];
        PHAsset *asset = assets[i];
        
        [self __import:image assets:asset destination:folder completedBlock:^(NSError *error) {
            if (i == photos.count - 1) {
                if (completedBlock) {
                    completedBlock(nil);
                }
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

        if (completedBlock) {
            completedBlock(success ? nil : [NSError new]);
        }

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
                                                
                                                if (completedBlock) {
                                                    completedBlock(success ? nil : [NSError new]);
                                                }
                                            }];
}

@end
