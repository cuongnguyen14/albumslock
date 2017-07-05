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
#import "UIImage+CNImage.h"
#import "UIAlertView+Blocks.h"

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


@property (nonatomic) BOOL isEdit;
@property (nonatomic, strong) NSMutableArray<CNFileComponent *> *selectData;

@property (nonatomic) CNFileComponent *firstModel;

@property (nonatomic, strong) UIBarButtonItem *selectAll;
@property (nonatomic, strong) UIBarButtonItem *share;
@property (nonatomic, strong) UIBarButtonItem *deleteAll;
@property (nonatomic, strong) UIBarButtonItem *doneEdit;

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
    
    self.isEdit = NO;
    
    [self.collectionView setAllowsMultipleSelection:YES];
    
}

-(void)setupHeaderView {
    CNFileComponent *model = [self.data firstObject];

    if (model.thumbnailPath.length == 0) {
        return;
    }

    if ([_firstModel isEqual:model]) {
        return;
    } else {
        _firstModel = [model copy];
    }
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [self.backgroundHeaderImageView.layer removeAllAnimations];
    [self.artworkView.layer removeAllAnimations];

    [self.backgroundHeaderImageView.layer addAnimation:transition forKey:nil];
    [self.artworkView.layer addAnimation:transition forKey:nil];

    
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
        for (UIView *view in self.headerView.subviews) {
            if ([view isKindOfClass:[UIVisualEffectView class]]) {
                [view removeFromSuperview];
            }
        }
        [self.headerView insertSubview:blurEffectView aboveSubview:self.backgroundHeaderImageView];
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    
    [self.navigationController.navigationBar.layer removeAllAnimations];
    [self.navigationController.navigationBar.layer addAnimation:animation forKey:nil];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
    }];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = self.parent.tintColor;
    self.navigationController.navigationBar.tintColor = self.parent.tintColor;
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

-(void)loadData:(BOOL)acending {
    
    NSArray *allFile = [sFileManager componentForComponent:self.parent mode:YES];
    
    self.data = [allFile sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [[(CNFileComponent *)a fullFileName] stringByDeletingPathExtension];
        NSString *second = [[(CNFileComponent *)b fullFileName] stringByDeletingPathExtension];
        if ([first compare:second options:NSNumericSearch] == NSOrderedAscending) {
            return acending ? NSOrderedAscending : NSOrderedDescending;
        } else {
            return acending ? NSOrderedDescending : NSOrderedAscending;
        }
    }];
    
    [self.collectionView reloadData];
//    [self.collectionView performBatchUpdates:^{
//        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
//    } completion:nil];
    
    [self setupHeaderView];
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

- (UIBarButtonItem *)selectAll
{
    if (!_selectAll)
    {
        _selectAll = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Select-All"] landscapeImagePhone:nil style:0 target:self action:@selector(doSelectAll:)];
        _selectAll.accessibilityLabel = @"Select All";
        _selectAll.enabled = YES;
    }
    return _selectAll;
}

- (UIBarButtonItem *)share
{
    if (!_share)
    {
        _share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sharered"] landscapeImagePhone:nil style:0 target:self action:@selector(doShare:)];
        _share.accessibilityLabel = @"Select All";
        _share.enabled = NO;
    }
    return _share;
}

- (UIBarButtonItem *)deleteAll
{
    if (!_deleteAll)
    {
        _deleteAll = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Delete"] landscapeImagePhone:nil style:0 target:self action:@selector(doDeleteAll:)];
        _deleteAll.accessibilityLabel = @"Delete All";
        _deleteAll.enabled = NO;
    }
    return _deleteAll;
}

- (UIBarButtonItem *)doneEdit
{
    if (!_doneEdit)
    {
        _doneEdit = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"select"] landscapeImagePhone:nil style:0 target:self action:@selector(doDoneEdit:)];
        _doneEdit.accessibilityLabel = @"Done";
        _doneEdit.enabled = YES;
    }
    return _doneEdit;
}

- (NSArray *)navigationToolItems
{
    NSMutableArray *items = [NSMutableArray new];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    [items addObject:self.selectAll];
    
    [items addObject:flexibleSpace];
    [items addObject:self.deleteAll];
    
    [items addObject:flexibleSpace];
    [items addObject:self.share];

    [items addObject:flexibleSpace];
    [items addObject:self.doneEdit];
        
    return items;
}

-(void)doSelectAll:(id)sender {
    BOOL isSelectAll = self.data.count == [self.collectionView indexPathsForSelectedItems].count;
    if (!isSelectAll) {
        for (NSInteger row = 0; row < [self.collectionView numberOfItemsInSection:0]; row++) {
            [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
        self.selectAll.image = [UIImage imageNamed:@"Deselect-All"];
    } else {
        for (NSInteger row = 0; row < [self.collectionView numberOfItemsInSection:0]; row++) {
            [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO];
        }
        self.selectAll.image = [UIImage imageNamed:@"Select-All"];

    }
}

-(void)doDeleteAll:(id)sender {
    [self activateDelete];
}

-(void)doDoneEdit:(id)sender {
    [self activateEditMode];
}

-(void)doShare:(id)sender {

    if (self.selectData.count == 0) {
        return;
    }
    
    NSMutableArray *sharePhoto = [NSMutableArray new];
    for (CNFileComponent *file in self.selectData) {
        UIImage *image = [UIImage imageWithContentsOfFile:file.absolutePath];
        [sharePhoto addObject:image];
    }
    
    // build an activity view controller
    UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:sharePhoto applicationActivities:nil];
    
    // and present it
    [self presentViewController:controller animated:YES completion:^{
        // executes after the user selects something
    }];

}

-(void)setActionViewEnable:(BOOL)enable {
    for (UIButton *button in self.actionView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button setEnabled:enable];
        }
    }
}

- (void)activateEditMode
{
    self.isEdit = !self.isEdit;
    
    if (self.isEdit) {
        self.selectData = [NSMutableArray new];
    }

    self.navigationController.toolbar.translucent = NO;
    [self.navigationController setToolbarHidden:!self.isEdit animated:YES];
    [self.navigationController.toolbar setTintColor:MakeColor(255, 26, 85, 1)];
    [self setToolbarItems:[self navigationToolItems]];
    self.actionButton.alpha = self.isEdit ? 0 : 1;
    self.deleteAll.enabled = [self.collectionView indexPathsForSelectedItems].count == 0 ? NO : YES;
    self.share.enabled = [self.collectionView indexPathsForSelectedItems].count == 0 ? NO : YES;

    [self setActionViewEnable:!self.isEdit];
    
    [self.collectionView reloadData];

}

- (void)activateDelete {
    
    [sFileManager deleteComponent:self.selectData];
    
    self.selectData = [NSMutableArray new];

    [self loadData:_sortAcending];
    
    [self activateEditMode];
    
}


#pragma mark - UICollectionViewDataSource

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.selectData removeObject:[self.data objectAtIndex:indexPath.row]];
    self.deleteAll.enabled = [collectionView indexPathsForSelectedItems].count == 0 ? NO : YES;
    self.share.enabled = [collectionView indexPathsForSelectedItems].count == 0 ? NO : YES;

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.data count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PLAlbumDetailsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kCellReuseID" forIndexPath:indexPath];
    
    CNFileComponent *model = [self.data objectAtIndex:indexPath.row];
    
    [cell setupUIWith:model];
    
    [cell setEditing:self.isEdit];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isEdit) {
        [self.selectData addObject:[self.data objectAtIndex:indexPath.row]];
        self.deleteAll.enabled = [collectionView indexPathsForSelectedItems].count == 0 ? NO : YES;
        self.share.enabled = [collectionView indexPathsForSelectedItems].count == 0 ? NO : YES;

    } else {
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
    
}

#pragma mark TZImagePickerControllerDelegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    weakify(self);
    [UIAlertView showWithTitle:@"Delete" message:@"Do you want to delete these photos from Photos Library? \n (It will still show in Recently Deleted album)" cancelButtonTitle:@"NO" otherButtonTitles:@[@"YES"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        
        BOOL isDeleted = buttonIndex != alertView.cancelButtonIndex;
        
        UIViewController *root = [[[UIApplication sharedApplication].delegate window] rootViewController];
        
        [MBProgressHUD showHUDAddedTo:root.view animated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [sImport import:photos assets:assets destination:self_weak_.parent deletedAfterSuccess:isDeleted completedBlock:^(NSError *error) {
                [MBProgressHUD hideHUDForView:root.view animated:YES];
                if (!error) {
                    [self_weak_ loadData:_sortAcending];
                }
            }];
        });
        
    }];
    
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
    
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    
    weakify(self);
    [UIAlertView showWithTitle:@"Delete" message:@"Do you want to delete these videos from Library? \n (It will still show in Recently Deleted album)" cancelButtonTitle:@"NO" otherButtonTitles:@[@"YES"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        
        BOOL isDeleted = buttonIndex != alertView.cancelButtonIndex;
        
        UIViewController *root = [[[UIApplication sharedApplication].delegate window] rootViewController];
        
        [MBProgressHUD showHUDAddedTo:root.view animated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [sImport importVideo:coverImage assets:asset destination:self_weak_.parent deletedAfterSuccess:isDeleted completedBlock:^(NSError *error) {
                [MBProgressHUD hideHUDForView:root.view animated:YES];
                if (!error) {
                    [self_weak_ loadData:_sortAcending];
                }
            }];
        });
        
    }];

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
                 
                 if (self_weak_.parent.folderType == FolderTypeVideo) {
                     imagePickerVc.allowPickingImage = NO;
                     imagePickerVc.allowPickingVideo = YES;
                 } else if (self_weak_.parent.folderType == FolderTypePhoto) {
                     imagePickerVc.allowPickingImage = YES;
                     imagePickerVc.allowPickingVideo = NO;
                 } else {
                     imagePickerVc.allowPickingImage = YES;
                     imagePickerVc.allowPickingVideo = YES;
                 }
                 
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
    int padding = 12;
    CGSize size = CGSizeMake((self.view.bounds.size.width - padding)/3.,
                             (self.view.bounds.size.width - padding)/3.);
    
    [self.collectionView performBatchUpdates:^{
        ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize = size;
    } completion:nil];
}

-(void)updateFourColumn {
    int padding = 15;
    CGSize size = CGSizeMake((self.view.bounds.size.width - padding)/4.,
                             (self.view.bounds.size.width - padding)/4.);
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
    self.sortAcending = !self.sortAcending;
    [self loadData:self.sortAcending];
}

- (IBAction)touchAtButton3:(id)sender {
    [self activateEditMode];
}
- (IBAction)touchAtButton4:(id)sender {

}

@end
