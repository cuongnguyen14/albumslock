//
//  CNComponent.h
//  PLLock
//
//  Created by Cuong Nguyen on 11/4/15.
//  Copyright © 2015 CNLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef unsigned long CNComponentSizeType;

typedef NS_ENUM(NSUInteger, TypeComponent) {
    ComponentTypeFolder = 0,
    ComponentTypeFilePDF,
    ComponentTypeFileDoc,
    ComponentTypeFileMp3,
    ComponentTypeHTML,
    ComponentTypeZip,
    ComponentTypeRar,
    ComponentTypeVideo,
    ComponentTypeAudio,
    ComponentTypePhoto,
    ComponentTypeFileUnknown,
    ComponentTypeInvalidate
};

@interface CNComponent : NSObject

@property (nonatomic, weak, readonly) CNComponent *parent;

- (NSString *)fullFileName;

- (instancetype)initWithFullFileName:(NSString *)fullFileName
                              parent:(CNComponent *)parent;
- (NSString *)absolutePath;
- (NSString *)relativePath;

- (TypeComponent)type;
- (CNComponentSizeType)size;
- (NSDate *)dateCreated;
- (void)updateParent:(CNComponent *)parent;

@end
