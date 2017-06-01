//
//  PLAlbumDetailsViewController.m
//  PLLock
//
//  Created by CuongNguyen on 6/2/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import "PLAlbumDetailsViewController.h"
#import "PLAlbumDetailsCollectionViewCell.h"
#import "PLActionButton.h"
#import "TZImagePickerController.h"

@interface PLAlbumDetailsViewController () <TZImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) CNFolderComponent *parent;

@property (nonatomic) NSArray<CNFileComponent *> *data;
@property (nonatomic, strong) PLActionButton *actionButton;

@end

@implementation PLAlbumDetailsViewController

- (instancetype)initWithFolder:(CNFolderComponent *)folder
{
    self = [super init];
    if (self) {
        self.parent = folder;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = self.view.backgroundColor;
        
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PLAlbumDetailsCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:@"kCellReuseID"];

    [self setupActionButton];

    [self loadData];
}

-(void)loadData {
    NSArray *allFile = [sFileManager componentForComponent:self.parent mode:YES];
    NSSortDescriptor *date = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];
    self.data = [allFile sortedArrayUsingDescriptors:[NSArray arrayWithObjects:date, nil]];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    
    @try {
        [self.actionButton.observedScrollView removeObserver:self forKeyPath:@"contentInset"];
        [self.actionButton.observedScrollView removeObserver:self forKeyPath:@"contentOffset"];
        [self.actionButton.observedScrollView removeObserver:self forKeyPath:@"contentSize"];

    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    [self.actionButton removeFromSuperview];
    self.actionButton = nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.data count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PLAlbumDetailsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kCellReuseID" forIndexPath:indexPath];
    
    CNFileComponent *model = [self.data objectAtIndex:indexPath.row];
    
    [cell setupUIWith:model];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int padding = 50/4;
    return CGSizeMake(self.view.bounds.size.width/4 - padding,
                      self.view.bounds.size.width/4 - padding);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
}

#pragma mark TZImagePickerControllerDelegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    [picker showProgressHUD];

    for (UIImage *image in photos) {
        NSString *imageName = [NSString stringWithFormat:@"%f.png", [[NSDate date] timeIntervalSince1970]];
        NSString *filePath = [[self.parent absolutePath] stringByAppendingPathComponent:imageName];
        [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    }
    
    [picker hideProgressHUD];
    
    [self loadData];

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
    [self.view addSubview:self.actionButton];
}

@end
