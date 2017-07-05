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
#import "PLAlbumDetailsViewController.h"
#import "UIImage+CNImage.h"


@interface PLAlbumsViewController () <TZImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CNFileManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) PLActionButton *actionButton;
@property (nonatomic) NSArray<CNFolderComponent *> *data;

@end

@implementation PLAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"CATEGORIES";
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = self.view.backgroundColor;
    
    [self setupActionButton];
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([PLAlbumCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:@"kCellReuseID"];

    [self getAllFolder];
    
    [sFileManager addDelegate:self];
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
        [self.navigationController.navigationBar setBackgroundImage:nil
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = nil;
    }];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = nil;
    self.navigationController.navigationBar.tintColor = nil;

    [self.collectionView reloadData];
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
    
    [sFileManager removeDelegate:self];
}

-(void)getAllFolder {
    NSArray *allFolder = [sFileManager componentForComponent:[sFileManager rootComponent] mode:NO];
//    NSSortDescriptor *date = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];
//    self.data = [allFolder sortedArrayUsingDescriptors:[NSArray arrayWithObjects:date, nil]];

    self.data = [allFolder sortedArrayUsingComparator:^NSComparisonResult(CNFolderComponent *obj1, CNFolderComponent *obj2) {
        if ([obj1.dateCreated timeIntervalSince1970] - [obj2.dateCreated timeIntervalSince1970] > 0) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }];
    
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)newFolderAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New Folder" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Enter the folder name";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleNone;
    }];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             NSArray * textfields = alertController.textFields;
                             UITextField * namefield = textfields[0];
                             [alertController dismissViewControllerAnimated:YES completion:nil];
                             [sFileManager createFolderAtComponent:[sFileManager rootComponent] nameFolder:namefield.text];

                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alertController dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alertController addAction:ok];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.data count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PLAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kCellReuseID" forIndexPath:indexPath];
    
    CNFolderComponent *model = [self.data objectAtIndex:indexPath.row];
    
    [cell setupUIWith:model];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int padding = 15;
    return CGSizeMake(self.view.bounds.size.width/2 - padding,
                      self.view.bounds.size.width/2 - padding);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];

    CNFolderComponent *model = [self.data objectAtIndex:indexPath.row];
    PLAlbumDetailsViewController *controller = [[PLAlbumDetailsViewController alloc] initWithFolder:model];
    [self.navigationController pushViewController:controller animated:YES];
    
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
    [PLActionButton plusButtonsViewWithNumberOfButtons:2
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
         
         // New Folder
         if (index == 1) {
             [self_weak_.actionButton hideButtonsAnimated:YES completionHandler:^{
                 [self_weak_ newFolderAlert];
             }];
         }

//         // Take a Photo
//         if (index == 2) {
//             [self_weak_.actionButton hideButtonsAnimated:YES completionHandler:^{
//                 [sImport takePhoto:self_weak_ destination:(CNFolderComponent *)[sFileManager rootComponent] completedBlock:^(NSError *error) {
//                     
//                 }];
//             }];
//         }
//         
//         // Choose From Gallery
//         if (index == 3) {
//             
//             
//             [self_weak_.actionButton hideButtonsAnimated:YES completionHandler:^{
//                 
//                 TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9999999 delegate:self_weak_];
//                 imagePickerVc.allowTakePicture = NO;
//                 imagePickerVc.allowPickingOriginalPhoto = NO;
//                 imagePickerVc.allowPreview = YES;
//                 [self_weak_ presentViewController:imagePickerVc animated:YES completion:nil];
//                 
//             }];
//             
//         }
         
     }];
    
    [self.actionButton setButtonsTitles:@[@"+", @""] forState:UIControlStateNormal];
    [self.actionButton setDescriptionsTexts:@[@"", @"Create New Folder"]];
    [self.actionButton setButtonsImages:@[[NSNull new],
                                          [UIImage imageNamed:@"create-new-folder"]]
                               forState:UIControlStateNormal
                         forOrientation:LGPlusButtonsViewOrientationAll];
    
    
    self.actionButton.observedScrollView = self.collectionView;
    [self.view addSubview:self.actionButton];
}

#pragma mark - File Manager delegate 
- (void)fileManager:(CNFileManager *)fileManager
         actionType:(CNFileManagerActionType)actionType
effectiveComponents:(NSArray <__kindof CNComponent *> *)components
    falureComponent:(NSArray<__kindof CNComponent *> *)errorCopyComponents {
    if (actionType == CNFileManagerActionTypeNew) {
        [self getAllFolder];
    }
}
@end
