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
#import <Photos/Photos.h>
#import "MWPhotoBrowser.h"
#import "MWPhotoBrowserPrivate.h"

#define NAVBAR_CHANGE_POINT 50

@interface PLAlbumDetailsViewController () <TZImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MWPhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundHeaderImageView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIImageView *artworkView;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbSubtitle;
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;
@property (weak, nonatomic) IBOutlet UIButton *btn4;


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) CNFolderComponent *parent;

@property (nonatomic) NSArray<CNFileComponent *> *data;
@property (nonatomic) NSArray<MWPhoto *> *viewData;

@property (nonatomic, strong) PLActionButton *actionButton;


@property (nonatomic) BOOL isThreeColumn;
@property (nonatomic) BOOL sortAcending;
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
    
    [self touchAtButton1:nil];
    
    [self setupActionButton];
    
    [self touchAtButton2:nil];
    
    [self setupHeaderView];
}

-(void)setupHeaderView {
    CNFileComponent *model = [self.data firstObject];
    
    if (model.thumbnailPath.length == 0) {
        return;
    }
    
    [self.backgroundHeaderImageView setImageWithURL:[NSURL fileURLWithPath:model.thumbnailPath] placeholderImage:nil];
    [self.artworkView setImageWithURL:[NSURL fileURLWithPath:model.thumbnailPath] placeholderImage:nil];
    self.lbTitle.text = self.parent.fullFileName;
    self.lbSubtitle.text = [NSString stringWithFormat:@"%ld %@", self.parent.size, self.parent.size > 1 ? @"items" : @"item"];
    
    self.lbTitle.textColor = [UIColor whiteColor];
    self.lbSubtitle.textColor = self.parent.tintColor;
    
    self.artworkView.layer.cornerRadius = 8;
    self.artworkView.layer.borderColor = self.parent.tintColor.CGColor;
    self.artworkView.layer.borderWidth = 1;
    
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.headerView.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        blurEffectView.alpha = 0.99;
        [self.headerView insertSubview:blurEffectView aboveSubview:self.backgroundHeaderImageView];
    }

}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [UIView animateWithDuration:0.2 animations:^{
        self.navigationController.navigationBar.translucent = YES;
        self.navigationController.navigationBar.barTintColor = self.parent.tintColor;
        self.navigationController.navigationBar.tintColor = self.parent.tintColor;
    }];
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;

}

-(void)loadData:(BOOL)acending {
    NSArray *allFile = [sFileManager componentForComponent:self.parent mode:YES];
    NSSortDescriptor *date = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:acending];
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

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    int padding = 10;
//    return CGSizeMake(self.view.bounds.size.width/3 - padding,
//                      self.view.bounds.size.width/3 - padding);
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    NSMutableArray *viewPhoto = [NSMutableArray new];
    for (CNFileComponent *file in self.data) {
        MWPhoto *photo = [[MWPhoto alloc] initWithURL:[NSURL fileURLWithPath:file.absolutePath]];
        [viewPhoto addObject:photo];
    }
    self.viewData = [viewPhoto mutableCopy];
    
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];

    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    browser.enableGrid = NO; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    browser.autoPlayOnAppear = NO; // Auto-play first video
        
    // Optionally set the current visible photo before displaying
    [browser setCurrentPhotoIndex:indexPath.row];
    
    browser.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // Present
    [self.navigationController pushViewController:browser animated:YES];

}

#pragma mark TZImagePickerControllerDelegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    UIViewController *root = [[[UIApplication sharedApplication].delegate window] rootViewController];
    [MBProgressHUD showHUDAddedTo:root.view animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakify(self);
        [sImport import:photos assets:assets destination:self.parent completedBlock:^(NSError *error) {
            if (!error) {
                [self_weak_ loadData:_sortAcending];
                [MBProgressHUD hideHUDForView:root.view animated:YES];
            }
        }];
    });
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
                 [sImport takePhoto:self_weak_ destination:self_weak_.parent completedBlock:^(NSError *error) {
                     [self_weak_ loadData:_sortAcending];
                 }];
             }];
         }
         
         // Choose From Gallery
         if (index == 2) {
             
             [self_weak_.actionButton hideButtonsAnimated:YES completionHandler:^{
                 
                 TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9999999 delegate:self_weak_];
                 imagePickerVc.allowTakePicture = NO;
                 imagePickerVc.allowPickingOriginalPhoto = YES;
                 imagePickerVc.allowPreview = NO;
                 imagePickerVc.allowPickingVideo = NO;
                 imagePickerVc.hideWhenCanNotSelect = YES;
                 [self_weak_ presentViewController:imagePickerVc animated:YES completion:nil];
                 
             }];
             
         }
         
     }];
    
    [self.actionButton setButtonsTitles:@[@"+", @"", @""] forState:UIControlStateNormal];
    [self.actionButton setDescriptionsTexts:@[@"", @"From Camera", @"From Library"]];
    [self.actionButton setButtonsImages:@[[NSNull new],
                                          [UIImage imageNamed:@"fromcamera"],
                                          [UIImage imageNamed:@"from-library"]]
                               forState:UIControlStateNormal
                         forOrientation:LGPlusButtonsViewOrientationAll];
    
    
    self.actionButton.observedScrollView = self.collectionView;
    [self.view addSubview:self.actionButton];
}

#pragma mark 

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [self.viewData count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return [self.viewData objectAtIndex:index];
}

#pragma mark - Button action
-(void)updateThreecolumn {
    int padding = 10;
    CGSize size = CGSizeMake(self.view.bounds.size.width/3 - padding,
                             self.view.bounds.size.width/3 - padding);
    
    [self.collectionView performBatchUpdates:^{
        ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize = size;
    } completion:nil];
}

-(void)updateFourColumn {
    int padding = 8;
    CGSize size = CGSizeMake(self.view.bounds.size.width/4 - padding,
                             self.view.bounds.size.width/4 - padding);
    [self.collectionView performBatchUpdates:^{
        ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize = size;
    } completion:nil];
}
- (IBAction)touchAtButton1:(id)sender {
    if (_isThreeColumn == YES) {
        [self updateFourColumn];
        _isThreeColumn = NO;
    } else {
        [self updateThreecolumn];
        _isThreeColumn = YES;
    }
    
}

- (IBAction)touchAtButton2:(id)sender {
    [self loadData:!_sortAcending];
}

- (IBAction)touchAtButton3:(id)sender {
    
}
- (IBAction)touchAtButton4:(id)sender {
    
}

@end
