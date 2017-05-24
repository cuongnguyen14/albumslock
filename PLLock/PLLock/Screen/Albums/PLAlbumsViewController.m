//
//  PLAlbumsViewController.m
//  PLLock
//
//  Created by CuongNguyen on 5/22/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import "PLAlbumsViewController.h"
#import "TZImagePickerController.h"
#import "PLActionButton.h"
#import "PLAlbumCollectionViewCell.h"

@interface PLAlbumsViewController () <TZImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) PLActionButton *actionButton;
@property (nonatomic) NSArray<CNFolderComponent *> *data;

@end

@implementation PLAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.view.backgroundColor = [UIColor grayColor];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    
    [self setupActionButton];
    
    [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"HELLO"];
    [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"HELLO1"];

    [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"HELLO2"];

    [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"HELLO3"];
    [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"HELLO4"];
    [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"HELLO5"];

    [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"HELLO6"];
    [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"HELLO7"];
    [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:@"HELLO8"];

    self.data = [sFileManager componentForComponent:[sFileManager rootComponent] mode:NO];

    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PLAlbumCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:@"kCellReuseID"];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.data count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    id model = [self.d.items objectAtIndex:indexPath.row];
//    
    PLAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kCellReuseID" forIndexPath:indexPath];
//
//    [cell configUIWithModel:model];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int padding = 24;
    return CGSizeMake(self.view.bounds.size.width/2 - padding,
                      self.view.bounds.size.width/2 - padding);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];

}


#pragma mark TZImagePickerControllerDelegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {
    
}

#pragma mark Action Button

-(void)setupActionButton {
    
    weakify(self);
    self.actionButton =
    [PLActionButton plusButtonsViewWithNumberOfButtons:3
                               firstButtonIsPlusButton:YES
                                         showAfterInit:YES
                                         actionHandler:^(LGPlusButtonsView *plusButtonView,
                                                         NSString *title,
                                                         NSString *description,
                                                         NSUInteger index)
     {
         NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
         
         // X Button
         if (index == 0) {
             
         }
         
         // Take a Photo
         if (index == 1) {
             [self_weak_.actionButton hideButtonsAnimated:YES completionHandler:^{
             }];
         }
         
         // Choose From Gallery
         if (index == 2) {
             
             
             [self_weak_.actionButton hideButtonsAnimated:YES completionHandler:^{
                 
                 TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9999999 delegate:self_weak_];
                 imagePickerVc.allowTakePicture = NO;
                 imagePickerVc.allowPickingOriginalPhoto = NO;
                 imagePickerVc.allowPreview = YES;
                 [self_weak_ presentViewController:imagePickerVc animated:YES completion:nil];
                 
             }];
             
         }
         
     }];
    
    [self.actionButton setButtonsTitles:@[@"+", @"", @""] forState:UIControlStateNormal];
    [self.actionButton setDescriptionsTexts:@[@"", @"Take a photo", @"Choose from gallery"]];
    [self.actionButton setButtonsImages:@[[NSNull new],
                                          [UIImage imageNamed:@"Camera"],
                                          [UIImage imageNamed:@"Picture"]]
                               forState:UIControlStateNormal
                         forOrientation:LGPlusButtonsViewOrientationAll];
    
    
    self.actionButton.observedScrollView = self.collectionView;
    [self.navigationController.view addSubview:self.actionButton];
}

@end
