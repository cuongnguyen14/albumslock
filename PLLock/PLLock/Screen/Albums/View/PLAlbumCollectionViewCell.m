//
//  PLAlbumCollectionViewCell.m
//  PLLock
//
//  Created by CuongNguyen on 5/25/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import "PLAlbumCollectionViewCell.h"

@interface PLAlbumCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIButton *btnMore;
@property (weak, nonatomic) IBOutlet UIImageView *imgArtwork;
@property (weak, nonatomic) IBOutlet UIView *viewFooter;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbSubtitle;
@property (weak, nonatomic) IBOutlet UIView *viewBaged;

@end

@implementation PLAlbumCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor whiteColor];

    dispatch_async(dispatch_get_main_queue(), ^{
        CALayer * layer = [self layer];
        [layer setShadowOffset:CGSizeMake(0.5, 0.5)];
        [layer setShadowRadius:2.0];
        [layer setShadowColor:[UIColor grayColor].CGColor] ;
        [layer setShadowOpacity:0.3];
        [layer setMasksToBounds:NO];
        [layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.bounds] CGPath]];

    });
}

- (IBAction)touchOnMore:(id)sender {
    
}

-(void)setupUIWith:(CNFolderComponent *)folder {
    self.lbTitle.text = folder.fullFileName;
    self.lbSubtitle.text = [NSString stringWithFormat:@"%ld %@", folder.size, folder.size > 1 ? @"items" : @"item"];
    self.viewBaged.backgroundColor = folder.tintColor;
    self.imgArtwork.image = [UIImage imageNamed:folder.iconName];
}

@end
