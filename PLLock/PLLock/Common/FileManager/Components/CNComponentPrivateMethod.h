//
//  CNComponentPrivateMethod.h
//  PLLock
//
//  Created by Cuong Nguyen on 11/7/15.
//  Copyright © 2015 CNLabs. All rights reserved.
//

@class CNComponent;
@interface CNComponent (PrivateMethod)

@property (nonatomic, copy) NSString *fullFileName;
@property (nonatomic, weak, readwrite) CNComponent *parent;

@end
