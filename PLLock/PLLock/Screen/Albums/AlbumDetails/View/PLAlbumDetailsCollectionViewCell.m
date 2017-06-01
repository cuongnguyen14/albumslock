//
//  PLAlbumDetailsCollectionViewCell.m
//  PLLock
//
//  Created by CuongNguyen on 6/2/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import "PLAlbumDetailsCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface PLAlbumDetailsCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *imgArtwork;

@end

@implementation PLAlbumDetailsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor lightGrayColor];
}

-(void)setupUIWith:(CNFileComponent *)file {
    if (file.type == ComponentTypePhoto) {
        [self.imgArtwork setImageWithURL:[NSURL fileURLWithPath:file.absolutePath] placeholderImage:nil];
    }
}

@end
