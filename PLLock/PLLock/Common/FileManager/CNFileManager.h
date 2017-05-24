//
//  CNFileManager.h
//  PLLock
//
//  Created by Cuong Nguyen on 11/4/15.
//  Copyright © 2015 CNLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNFileManagerDelagate.h"

#define sFileManager [CNFileManager shareInstance]

@class CNComponent, CNFileManager, ALAsset;

@interface CNFileManager : NSObject

@property (nonatomic, readonly) CNComponent * _Nonnull rootComponent;

+ (instancetype _Nonnull)shareInstance;

- (NSArray * _Nonnull)componentsAtRoot;

- (CNComponent *_Nullable) componentWithTargetPath:(NSString *_Nonnull)targetPath
                                          fileName:(NSString *_Nonnull)fileName
                                           parents:(NSMutableArray *_Nullable)parents;

- (NSArray * _Nonnull)componentForChooseComponent:(CNComponent * _Nonnull)component
                                             mode:(BOOL)getAll;

- (NSArray* _Nonnull)componentForComponent:(CNComponent * _Nonnull)component
                                      mode:(BOOL)getAll;

- (NSArray* _Nonnull)allChildComponentsForComponent:(CNComponent * _Nonnull)component
                                             getAll:(BOOL)getAll;

- (BOOL)copyComponents:(NSArray <__kindof CNComponent *> * _Nonnull)components
         toDestination:(CNComponent * _Nonnull)destination;

- (BOOL)deleteComponent:(NSArray <__kindof CNComponent *> * _Nonnull)components;

- (BOOL)renameComponent:(CNComponent * _Nonnull)component
        withNewFullName:(NSString * _Nonnull)newFullName;

- (BOOL)moveComponent:(NSArray<__kindof CNComponent *> * _Nonnull)components
        toDestination:(CNComponent * _Nonnull)destination;

- (BOOL)createFolderAtComponent:(CNComponent * _Nonnull)component
                     nameFolder:(NSString * _Nonnull)nameFolder;


- (void)addDelegate:(id<CNFileManagerDelegate> _Nonnull)delegate;
- (void)removeDelegate:(id<CNFileManagerDelegate> _Nonnull)delegate;

@end
