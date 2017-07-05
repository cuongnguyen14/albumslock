//
//  CNFileComponent.m
//  PLLock
//
//  Created by Cuong Nguyen on 11/7/15.
//  Copyright © 2015 CNLabs. All rights reserved.
//

#import "CNFileComponent.h"
#import "CNComponentPrivateMethod.h"

@interface CNFileComponent ()

@property (nonatomic) TypeComponent type;

@end

#define kSupportZipExtensions @[@"zip"]
#define kSupportRarExtensions @[@"rar"]
#define kSupportPNGExtensions @[@"png",@"jpg",@"jpeg"]
#define kSupportVideoExtensions @[@"mp4",@"mov",@"avi"]

@implementation CNFileComponent

- (instancetype)initWithFullFileName:(NSString *)fullFileName parent:(CNComponent *)parent {
    self = [super initWithFullFileName:fullFileName parent:parent];
    if (self) {

    }
    return self;
}

- (void)setFullFileName:(NSString *)fullFileName {
    [super setFullFileName:fullFileName];
    
    //set type
    NSString *extension = [fullFileName pathExtension].lowercaseString;
    
    if ([extension isEqualToString:@"html"] || [extension isEqualToString:@"htm"]) {
        self.type = ComponentTypeHTML;
        return;
    }
    
    if ([kSupportZipExtensions containsObject:extension]) {
        self.type = ComponentTypeZip;
        return;
    }
    
    if ([kSupportRarExtensions containsObject:extension]) {
        self.type = ComponentTypeRar;
        return;
    }

    if ([kSupportPNGExtensions containsObject:extension]) {
        self.type = ComponentTypePhoto;
        return;
    }
    
    if ([kSupportVideoExtensions containsObject:extension]) {
        self.type = ComponentTypeVideo;
        return;
    }

}

- (CNComponentSizeType)size {
    NSError *attributesError;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self absolutePath] error:&attributesError];
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    
    return [fileSizeNumber longLongValue];
}

- (NSDate*)dateCreated {
    NSError *attributesError;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self absolutePath] error:&attributesError];
    NSDate *fileCreationDate = [fileAttributes objectForKey:NSFileCreationDate];
    
    return fileCreationDate;
}

- (id)copy {
    return [[self.class alloc] initWithFullFileName:self.fullFileName parent:self.parent];
}

@end
