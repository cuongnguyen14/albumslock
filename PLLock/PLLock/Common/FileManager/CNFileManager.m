//
//  CNFileManager.m
//  PLLock
//
//  Created by Cuong Nguyen on 11/4/15.
//  Copyright © 2015 CNLabs. All rights reserved.
//

#import "CNFileManager.h"
#import "CNFileComponent.h"
#import "CNFolderComponent.h"
#import "CNComponentPrivateMethod.h"
#import "GCDWebUploader.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define nameFolderRoot @"Root"

@interface CNRootComponent : CNComponent

@property (nonatomic,strong) NSString *absolutePath;
@property (nonatomic,strong) NSString *relativePath;

@end

@implementation CNRootComponent
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.absolutePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Root"];
        self.relativePath = @"Documents/Root";
    }
    return self;
}
@end

@interface CNFileManager()<GCDWebUploaderDelegate> {
    GCDWebUploader *_webServer;
}
@property (nonatomic, readwrite) CNComponent *rootComponent;
@property (nonatomic, strong, readwrite) NSMapTable *delegates;

@end

@implementation CNFileManager

+ (instancetype _Nonnull)shareInstance {
    static dispatch_once_t onceToken;
    static id _shareInstance = nil;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[self alloc] init];
        
    });
    return _shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createRootFolder];
        self.rootComponent = [CNRootComponent new];
        self.delegates = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                               valueOptions:NSMapTableWeakMemory];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didChoosedWifiSharing:) name:@"kWifiSharingDidChangeNotification" object:nil];
    }
    return self;
}

#pragma mark - Private

- (void)mainTheard:(void (^)())mainTheard {
    dispatch_async(dispatch_get_main_queue(), ^{
        mainTheard();
    });
}

- (void)createRootFolder{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:nameFolderRoot];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
}

- (void)_didChoosedWifiSharing:(NSNotification *)obj {
    if ([[obj object] boolValue]) {
        [self _createAndStartServer];
    } else {
        [self _stopServer];
    }
}

- (void)_stopServer {
    [_webServer stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kServerURLNotification" object:nil];
}

- (void)_createAndStartServer {
    // create webserver
    _webServer = [[GCDWebUploader alloc] initWithUploadDirectory:sFileManager.rootComponent.absolutePath];
    _webServer.delegate = self;
    _webServer.allowHiddenItems = NO;
    if (![_webServer start]) {
        NSLog(@"Can't start server!");
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kServerURLNotification" object:_webServer.serverURL];
}

- (BOOL)checkValidDestinationComponent:(CNComponent *)destComponent
                       sourceComponent:(CNComponent *)sourceComponent {
    
    if (destComponent.absolutePath == nil || sourceComponent.absolutePath == nil) {
        return NO;
    }
    if ([destComponent.absolutePath hasPrefix:[sourceComponent.absolutePath stringByAppendingString:@"/"]] || [destComponent.absolutePath isEqualToString:sourceComponent.absolutePath]) {
        return NO;
    }
    return YES;
}

- (void)generateFileNameForNewComponent:(CNComponent *)component {
    
    //Get file path, file name and extension
    NSString *filePath = component.absolutePath;
    NSString *fileName = [component.fullFileName stringByDeletingPathExtension];
    NSString *pathExtension = [component.fullFileName pathExtension];
    NSString *newFileName = [component.fullFileName stringByDeletingPathExtension];
    NSInteger additionFileName = 1;
    
    //Check if file has exist
    while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //Append "(_additionFileName_)" to the file name
        newFileName = [fileName stringByAppendingString:[NSString stringWithFormat:@"(%ld)", (long)additionFileName]];
        filePath = [component.parent.absolutePath stringByAppendingPathComponent:[newFileName stringByAppendingPathExtension:pathExtension]];
        additionFileName += 1;
    }
    
    component.fullFileName = [newFileName stringByAppendingPathExtension:pathExtension];
}


#pragma mark - Public

- (NSArray * _Nonnull)componentsAtRoot {
    return [self componentForComponent:self.rootComponent mode:YES];
}

- (CNComponent *_Nullable) componentWithTargetPath:(NSString *_Nonnull)targetPath fileName:(NSString *_Nonnull)fileName parents:(NSMutableArray *_Nullable)parents {
    
    //Get path of component
    NSMutableArray *pathArray = [[targetPath componentsSeparatedByString:@"/"] mutableCopy];
    //Remove "Documents" and "Root" folder
    [pathArray removeObjectAtIndex:0];
    [pathArray removeObjectAtIndex:0];
    
    // init component's parents
    if (parents == nil) {
        parents = [NSMutableArray new];
    }
    
    [parents addObject:[self rootComponent]];
    while ([pathArray count] > 0) {
        
        NSString *folderName = pathArray[0];
        CNComponent *com = [[CNFolderComponent alloc] initWithFullFileName:folderName parent:parents.lastObject];
        [parents addObject:com];
        [pathArray removeObjectAtIndex:0];
    }
    
    // Init Component with it's parent
    CNComponent *component = [[CNFileComponent alloc] initWithFullFileName:fileName parent:[parents lastObject]];
    return component;
}

- (NSArray * _Nonnull)componentForComponent:(CNComponent * _Nonnull)component mode:(BOOL)getAll {
    
    NSArray *allPathComponents = [[NSFileManager defaultManager]
                                  contentsOfDirectoryAtURL:[NSURL fileURLWithPath:[component absolutePath]]
                                  includingPropertiesForKeys:@[NSURLNameKey,
                                                               NSURLIsDirectoryKey]
                                  options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    NSMutableArray *listComponentInComponent = [NSMutableArray new];
    NSNumber *isDir = nil;
    for (NSURL *item in allPathComponents) {
        NSString *fileName = nil;
        
        [item getResourceValue:&fileName forKey:NSURLNameKey error:nil];
        [item getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];

        CNComponent *componentItem = nil;
        if (getAll) {
            if ([isDir boolValue]) {
                componentItem = [[CNFolderComponent alloc] initWithFullFileName:fileName parent:component];
                
                ////
                [self updateTypeAndTintColor:(CNFolderComponent *)componentItem];
                ////
                
                
                [listComponentInComponent insertObject:componentItem atIndex:0];
            } else {
                componentItem = [[CNFileComponent alloc] initWithFullFileName:fileName parent:component];
                [listComponentInComponent addObject:componentItem];
            }
        } else if ([isDir boolValue]) {
            componentItem = [[CNFolderComponent alloc] initWithFullFileName:fileName parent:component];
            
            ////
            [self updateTypeAndTintColor:(CNFolderComponent *)componentItem];
            ////

            [listComponentInComponent addObject:componentItem];
        }
    }
    
    return listComponentInComponent;
}

- (NSArray * _Nonnull)componentForChooseComponent:(CNComponent * _Nonnull)component mode:(BOOL)getAll {
    NSArray *allPathComponents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:[component absolutePath]]
                                                               includingPropertiesForKeys:@[NSURLNameKey,NSURLIsDirectoryKey]
                                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    NSMutableArray *listComponentInComponent = [NSMutableArray new];
    NSNumber *isDir = nil;
    for (NSURL *item in allPathComponents) {
        NSString *fileName = nil;
        [item getResourceValue:&fileName forKey:NSURLNameKey error:nil];
        [item getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
        
        CNComponent *componentItem = nil;
        if (getAll) {
            if ([isDir boolValue]) {
                componentItem = [[CNFolderComponent alloc] initWithFullFileName:fileName parent:component];
                [listComponentInComponent insertObject:componentItem atIndex:0];
            } else {
                componentItem = [[CNFileComponent alloc] initWithFullFileName:fileName parent:component];
                [listComponentInComponent addObject:componentItem];
            }
        } else if ([isDir boolValue]) {
            componentItem = [[CNFolderComponent alloc] initWithFullFileName:fileName parent:component];
            [listComponentInComponent addObject:componentItem];
        }
    }
    
    return listComponentInComponent;
}

- (NSArray* _Nonnull)allChildComponentsForComponent:(CNComponent * _Nonnull)component getAll:(BOOL)getAll {
    
    NSArray *allPathComponents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:[component absolutePath]]
                                                               includingPropertiesForKeys:@[NSURLNameKey,NSURLIsDirectoryKey]
                                                                                  options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    NSMutableArray *components = [NSMutableArray new];
    NSNumber *isDir = nil;
    for (NSURL *item in allPathComponents) {
        NSString *fileName = nil;
        [item getResourceValue:&fileName forKey:NSURLNameKey error:nil];
        [item getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
        
        CNComponent *componentItem = nil;
        if (getAll) {
            
            if ([isDir boolValue]) {
                componentItem = [[CNFolderComponent alloc] initWithFullFileName:fileName parent:component];
                [components insertObject:componentItem atIndex:0];
                NSArray *childComponents = [self allChildComponentsForComponent:componentItem getAll:YES];
                [components addObjectsFromArray:childComponents];
            } else {
                componentItem = [[CNFileComponent alloc] initWithFullFileName:fileName parent:component];
                [components addObject:componentItem];
            }
            
        } else {
            
            if ([isDir boolValue]) {
                componentItem = [[CNFolderComponent alloc] initWithFullFileName:fileName parent:component];
                NSArray *childComponents = [self allChildComponentsForComponent:componentItem getAll:NO];
                [components addObjectsFromArray:childComponents];
            } else {
                componentItem = [[CNFileComponent alloc] initWithFullFileName:fileName parent:component];
                [components addObject:componentItem];
            }
        }
    }
    
    return components;
}

- (BOOL)moveComponent:(NSArray<__kindof CNComponent *> *)components toDestination:(CNComponent * _Nonnull)destination{
    BOOL success = NO;
    NSMutableArray *movedComponents = [NSMutableArray array];
    NSMutableArray *oldComponents = [NSMutableArray array];
    NSMutableArray *errorMovedComponents = [NSMutableArray array];
    
    for (CNComponent *component in components) {
        NSString *path = [destination.absolutePath stringByAppendingPathComponent:component.fullFileName];
        
        CNComponent *newComponent = component.copy;
        if (![[NSFileManager defaultManager] fileExistsAtPath:path] && [self checkValidDestinationComponent:destination sourceComponent:component]) {
            success = [[NSFileManager defaultManager] moveItemAtPath:component.absolutePath toPath:path error:nil];
            if (success) {
                
                [oldComponents addObject:component.copy];
                newComponent.parent = destination;
                [movedComponents addObject:newComponent];
            } else{
                // execute moveItemAtPathError
                [errorMovedComponents addObject:newComponent];
            }
        }
        else{
            // fileExistsAtPath = true || move into itself
            [errorMovedComponents addObject:newComponent];
        }
    }
    [self fileManagerCallDelegateActionWithType:CNFileManagerActionTypeDelete effectiveComponent:oldComponents falureComponent:nil];
    [self fileManagerCallDelegateActionWithType:CNFileManagerActionTypeNew effectiveComponent:movedComponents falureComponent:errorMovedComponents];
    
    return YES;
}

- (BOOL)copyComponents:(NSArray <__kindof CNComponent *> * _Nonnull)components toDestination:(CNComponent * _Nonnull)destination{
    
    BOOL success = NO;
    NSMutableArray *copiedComponents = [NSMutableArray array];
    NSMutableArray *errorCopyComponents = [NSMutableArray array];
    for (CNComponent *component in components) {
        NSString *path = [destination.absolutePath stringByAppendingPathComponent:component.fullFileName];
        
        CNComponent *newComponent = component.copy;
        if (![[NSFileManager defaultManager] fileExistsAtPath:path] && [self checkValidDestinationComponent:destination sourceComponent:component]) {
            success = [[NSFileManager defaultManager] copyItemAtPath:component.absolutePath toPath:path error:nil];
            
            if (success) {
                //update parent
                newComponent.parent = destination;
                [copiedComponents addObject:newComponent];
            }
            else{
                // execute func copyItemPath error
                [errorCopyComponents addObject:newComponent];
            }
        }
        else{
            // fileExistsAtPath = true || copy into itself
            [errorCopyComponents addObject:newComponent];
        }
    }
    [self fileManagerCallDelegateActionWithType:CNFileManagerActionTypeNew effectiveComponent:copiedComponents falureComponent:errorCopyComponents];
    
    return YES;
}

- (BOOL)deleteComponent:(NSArray <__kindof CNComponent *> * _Nonnull)components{
    BOOL success = NO;
    NSMutableArray *deletedComponents = [NSMutableArray array];
    NSMutableArray *errorDeletedComponents = [NSMutableArray array];
    NSError *err = nil;
    for (CNComponent *component in components) {
        success = [[NSFileManager defaultManager] removeItemAtPath:component.absolutePath error:&err];
        if (success) {
            [deletedComponents addObject:component];
        }
        else{
            [errorDeletedComponents addObject:component];
        }
    }
    [self fileManagerCallDelegateActionWithType:CNFileManagerActionTypeDelete effectiveComponent:deletedComponents falureComponent:errorDeletedComponents];
    
    return success;
}

- (BOOL)renameComponent:(CNComponent * _Nonnull)component withNewFullName:(NSString * _Nonnull)newFullName {
    //validate name
    NSParameterAssert(component && newFullName.length);
    
    if ([newFullName isEqualToString:[component.absolutePath lastPathComponent]]) {
        return YES;
    }
    // Get all components where a component needs to be renamed
    NSArray *nameComponents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:component.parent.absolutePath error:nil];
    if ([nameComponents containsObject:newFullName]) {
        return NO;
    }
    BOOL success = [[NSFileManager defaultManager] moveItemAtPath:component.absolutePath
                                                           toPath:[component.parent.absolutePath stringByAppendingPathComponent:newFullName]
                                                            error:nil];
    if (success) {
        
        CNComponent *oldComponent = [[CNComponent alloc] initWithFullFileName:component.fullFileName parent:component.parent];
        component.fullFileName = newFullName;

        if (component.type == ComponentTypeFolder) {
            [self fileManagerCallDelegateActionWithType:CNFileManagerActionTypeUpdate effectiveComponent:@[component, oldComponent] falureComponent:nil];
        }
        
    }
    
    return success;
}

- (BOOL)createFolderAtComponent:(CNComponent * _Nonnull)component nameFolder:(NSString * _Nonnull)nameFolder{
    
    BOOL success = NO;
    NSString *path = [component.absolutePath stringByAppendingPathComponent:nameFolder];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return success;
    }
    else{
        success = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
        //        success = [[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:NO attributes:nil error:nil];
        CNFolderComponent *newFolder = [[CNFolderComponent alloc] initWithFullFileName:nameFolder parent:component];
        if (success) {
            // Create first file at this folder to confirm this folder for it be can zip which have vietnamese name
            NSString *dsStoreFilePath = [path stringByAppendingPathComponent:@".DS_Store"];
            [@"" writeToFile:dsStoreFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            [self fileManagerCallDelegateActionWithType:CNFileManagerActionTypeNew effectiveComponent:@[newFolder] falureComponent:nil];
        }
        else{
            [self fileManagerCallDelegateActionWithType:CNFileManagerActionTypeNew effectiveComponent:nil falureComponent:@[newFolder]];
        }
    }
    return success;
}

#pragma - fileDelegate
- (void)fileManagerCallDelegateActionWithType:(CNFileManagerActionType)actionType
                           effectiveComponent:(NSArray <__kindof CNComponent *> *)components
                              falureComponent:(NSArray<__kindof CNComponent *> *)errorCopyComponents{
    [self mainTheard:^{
        
        // error array
        if (errorCopyComponents && errorCopyComponents.count) {
            NSString *message = @"The operation can’t be completed: ";
            
            for (int i = 0; i < errorCopyComponents.count; i++) {
                message = [message stringByAppendingString: [NSString stringWithFormat:@" %@", ((CNComponent*)errorCopyComponents[i]).fullFileName]];
                if (i != errorCopyComponents.count-1) {
                    message = [message stringByAppendingString: @","];
                }
                else{
                    message = [message stringByAppendingString: @"."];
                }
            }
            
            UIAlertView *alertView = [[UIAlertView new] initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            
            for (CNComponent *component in errorCopyComponents) {
                NSLog(@"error component: %@", component.fullFileName);
            }
        }
        
        for (NSString *keyValue in self.delegates) {
            id delegate = [self.delegates objectForKey:keyValue];
            if ([delegate respondsToSelector:@selector(fileManager:actionType:effectiveComponents:falureComponent:)]) {
                [delegate fileManager:self actionType:actionType effectiveComponents:components falureComponent:errorCopyComponents];
            }
            
            if (delegate == nil) {
                [self.delegates removeObjectForKey:keyValue];
            }
            // check object == nil remove
        }
    }];
}

#pragma mark - Registration
- (void)addDelegate:(id<CNFileManagerDelegate> _Nonnull)delegate{
    if (delegate) {
        [self.delegates setObject:delegate forKey:[NSString stringWithFormat:@"%p",delegate]];
    }
}

- (void)removeDelegate:(id<CNFileManagerDelegate> _Nonnull)delegate{
    if (delegate) {
        [self.delegates removeObjectForKey:[NSString stringWithFormat:@"%p",delegate]];
    }
}

#pragma mark - GCDWebUploader delegate
- (void)webUploader:(GCDWebUploader *)uploader didCreateDirectoryAtPath:(NSString *)path {
    if (path) {
        [self fileManagerCallDelegateActionWithType:CNFileManagerActionTypeWifiSharingChange effectiveComponent:nil falureComponent:nil];
    }
}

- (void)webUploader:(GCDWebUploader *)uploader didDeleteItemAtPath:(NSString *)path {
    if (path) {
        [self fileManagerCallDelegateActionWithType:CNFileManagerActionTypeWifiSharingChange effectiveComponent:nil falureComponent:nil];
    }
}

- (void)webUploader:(GCDWebUploader*)uploader didMoveItemFromPath:(NSString*)fromPath toPath:(NSString*)toPath{
    if (fromPath && toPath) {
        [self fileManagerCallDelegateActionWithType:CNFileManagerActionTypeWifiSharingChange effectiveComponent:nil falureComponent:nil];
    }
}

- (void)webUploader:(GCDWebUploader*)uploader didUploadFileAtPath:(NSString*)path{
    if (path) {
        [self fileManagerCallDelegateActionWithType:CNFileManagerActionTypeWifiSharingChange effectiveComponent:nil falureComponent:nil];
    }
}

#pragma mark 

-(void)updateTypeAndTintColor:(CNFolderComponent *)folder {
    
    if ([folder.fullFileName isEqualToString:@"PHOTOS"]) {
        folder.folderType = FolderTypePhoto;
        folder.tintColor = MakeColor(172, 206, 35, 1);
        folder.iconName = @"Photo-Icon";
        return;
    }
    if ([folder.fullFileName isEqualToString:@"VIDEOS"]) {
        folder.folderType = FolderTypeVideo;
        folder.tintColor = MakeColor(255, 190, 0, 1);
        folder.iconName = @"Video";
        return;
    }
    
    if ([folder.fullFileName isEqualToString:@"ACCOUNTS"]) {
        folder.folderType = FolderTypeiTunes;
        folder.tintColor = MakeColor(0, 133, 219, 1);
        folder.iconName = @"Accounts-Icon";
        return;
    }
    
    if ([folder.fullFileName isEqualToString:@"NOTES"]) {
        folder.folderType = FolderTypeiTunes;
        folder.tintColor = MakeColor(177, 20, 100, 1);
        folder.iconName = @"notes-icon-large";
        return;
    }

    if ([folder.fullFileName isEqualToString:@"ITUNES ALBUM"]) {
        folder.folderType = FolderTypeiTunes;
        folder.tintColor = MakeColor(254, 49, 67, 1);
        folder.iconName = @"Itune-Icon";
        return;
    }

    folder.folderType = FolderTypeUser;
    folder.tintColor = [UIColor purpleColor];
    folder.tintColor = MakeColor(13, 205, 192, 1);
    folder.iconName = @"My-file-icon";

}
@end
