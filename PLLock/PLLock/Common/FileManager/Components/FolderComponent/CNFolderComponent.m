//
//  CNFolderComponent.m
//  PLLock
//
//  Created by Cuong Nguyen on 11/7/15.
//  Copyright © 2015 CNLabs. All rights reserved.
//

#import "CNFolderComponent.h"

@implementation CNFolderComponent

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

- (id)copy {
    return [[self.class alloc] initWithFullFileName:self.fullFileName parent:self.parent];
}

@end
