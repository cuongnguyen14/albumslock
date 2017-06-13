//
//  PLLeftMenuTableViewCell.m
//  PLLock
//
//  Created by CuongNguyen on 6/13/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import "PLLeftMenuTableViewCell.h"

@interface PLLeftMenuTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *artwork;
@property (weak, nonatomic) IBOutlet UILabel *title;


@end

@implementation PLLeftMenuTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)displayWithModel:(PLLeftMenuItem *)model {
    self.artwork.image = [UIImage imageNamed:model.iconName];
    self.title.text = model.displayTitle;
}

@end
