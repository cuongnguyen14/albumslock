//
//  PLAlbumDetailsCollectionViewCell.m
//  PLLock
//
//  Created by CuongNguyen on 6/2/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import "PLAlbumDetailsCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+CNImage.h"

@interface PLAlbumDetailsCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *imgArtwork;
@property (nonatomic) BOOL editing;
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UIImageView *selectView;

@end

@implementation PLAlbumDetailsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor whiteColor];
    self.selectView.image = [[UIImage imageNamed:@"checked"] imageWithColor:[UIColor whiteColor]];
    [self updateView];
}

- (void)setEditing:(BOOL)editing {
    _editing = editing;
    [self updateView];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateView];
}

-(void)updateView {
    if (self.editing) {
        self.editView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.5];
    } else {
        self.editView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.1];
    }
    if (self.selected) {
        self.selectView.hidden = NO;
        self.editView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.1];
    } else {
        self.selectView.hidden = YES;
    }
}
-(void)setupUIWith:(CNFileComponent *)file {
    if (file.type == ComponentTypePhoto) {
        [self.imgArtwork setImageWithURL:[NSURL fileURLWithPath:file.thumbnailPath] placeholderImage:nil];
    }
}

@end
