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

@interface PLAlbumsViewController () <TZImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) PLActionButton *actionButton;

@end

@implementation PLAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    
    self.view.backgroundColor = [UIColor grayColor];
    self.tableView.backgroundColor = self.view.backgroundColor;
    
    
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

    
    self.actionButton.observedScrollView = self.tableView;
    [self.navigationController.view addSubview:self.actionButton];



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
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

@end
