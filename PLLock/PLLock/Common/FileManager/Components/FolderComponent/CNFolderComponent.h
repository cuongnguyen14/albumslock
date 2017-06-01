//
//  CNFolderComponent.h
//  PLLock
//
//  Created by Cuong Nguyen on 11/7/15.
//  Copyright © 2015 CNLabs. All rights reserved.
//

#import "CNComponent.h"

typedef enum : NSUInteger {
    FolderTypeiTunes,
    FolderTypePhoto,
    FolderTypeVideo,
    FolderTypeUser
} FolderType;

@interface CNFolderComponent : CNComponent

- (instancetype)initWithFullFileName:(NSString *)name
                              parent:(CNComponent *)parent
                          folderType:(FolderType)type
                           tintColor:(UIColor *)color;

@property (nonatomic) FolderType folderType;
@property (nonatomic) UIColor *tintColor;

@end
