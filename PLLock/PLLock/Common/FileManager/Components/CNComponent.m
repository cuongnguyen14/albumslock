//  CNComponent.m
//  PLLock
//
//  Created by Cuong Nguyen on 11/4/15.
//  Copyright © 2015 CNLabs. All rights reserved.
//

#import "CNComponent.h"

@interface CNComponent()

@property (nonatomic, copy) NSString *fullFileName;
@property (nonatomic, weak, readwrite) CNComponent *parent;

@end
@implementation CNComponent

- (instancetype)initWithFullFileName:(NSString *)fullFileName
                              parent:(CNComponent *)parent {
    self = [super init];
    if (self) {
        self.parent = parent;
        self.fullFileName = fullFileName.copy;
    }
    
    return self;
}

- (CNComponentSizeType)size {
    //for subclass
    return 0;
}

- (NSDate*)dateCreated {
    //for subclass
    return [NSDate date];
}

- (NSString*)absolutePath{
    return [[self.parent absolutePath] stringByAppendingPathComponent:self.fullFileName];
}

- (NSString *)relativePath {
    return [[self.parent relativePath] stringByAppendingPathComponent:self.fullFileName];
}

- (TypeComponent)type {
    //for subclass
    return ComponentTypeInvalidate;
}

- (BOOL)isEqual:(CNComponent *)component {
    if ([component isKindOfClass:[CNComponent class]]) {
        NSComparisonResult result = [self.absolutePath compare:component.absolutePath];
        return (result == NSOrderedSame);
    }
    return [super isEqual:component];
}

- (NSUInteger)hash {
    return self.absolutePath.hash;
}

- (void) updateParent:(CNComponent *)parent {
    self.parent = parent;
}

- (id) copy {
    CNComponent *cop = [[CNComponent alloc] initWithFullFileName:self.fullFileName parent:self.parent];
    return cop;
}

@end
