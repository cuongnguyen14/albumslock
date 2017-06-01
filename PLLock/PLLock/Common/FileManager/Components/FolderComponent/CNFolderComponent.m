//
//  CNFolderComponent.m
//  PLLock
//
//  Created by Cuong Nguyen on 11/7/15.
//  Copyright © 2015 CNLabs. All rights reserved.
//

#import "CNFolderComponent.h"

@implementation CNFolderComponent

- (instancetype)initWithFullFileName:(NSString *)name
                              parent:(CNComponent *)parent
                          folderType:(FolderType)type
                           tintColor:(UIColor *)color
{
    self = [super initWithFullFileName:name parent:parent];
    if (self) {
        self.folderType = type;
        self.tintColor = color;
    }
    return self;
}

- (TypeComponent)type {
    return ComponentTypeFolder;
}

- (CNComponentSizeType)size {
    if (![self absolutePath]) {
        return 0;
    }
    NSArray *allContentsInDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:[self absolutePath]]
                                                                    includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                                       options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    return [allContentsInDirectory count];
}

- (NSDate*)dateCreated {
    NSError *attributesError;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self absolutePath] error:&attributesError];
    NSDate *fileCreationDate = [fileAttributes objectForKey:NSFileCreationDate];
    
    return fileCreationDate;
}

- (id)copy {
    return [[self.class alloc] initWithFullFileName:self.fullFileName
                                             parent:self.parent
                                         folderType:self.folderType
                                          tintColor:self.tintColor];
}

@end
