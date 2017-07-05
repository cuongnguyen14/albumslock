//  CNFileManagerDelagate.h
//  PLLock
//
//  Created by Cuong Nguyen on 11/6/15.
//  Copyright © 2015 CNLabs. All rights reserved.
//

typedef enum {
    CNFileManagerActionTypeUnknown,
    CNFileManagerActionTypeNew,
    CNFileManagerActionTypeDelete,
    CNFileManagerActionTypeUpdate,
    CNFileManagerActionTypeWifiSharingChange
} CNFileManagerActionType;

typedef enum{
    CNAlertTypeNone,
    CNAlertTypeSameName,
    CNAlertTypeDeleteNotSuccess,
    CNAlertTypeRenameNotSuccess,
    CNAlertTypeMoveNotSuccess,
    CNAlertTypeNewNotSucces,
    CNAlertTypeCopyNotSuccess
} CNAlertType;

@class CNFileManager, CNComponent;

@protocol CNFileManagerDelegate <NSObject>

@required

- (void)fileManager:(CNFileManager *)fileManager
         actionType:(CNFileManagerActionType)actionType
effectiveComponents:(NSArray <__kindof CNComponent *> *)components
    falureComponent:(NSArray<__kindof CNComponent *> *)errorCopyComponents;

@end
