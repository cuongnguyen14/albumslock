//
//  DLAddressBarView.h
//  Downloader
//
//  Created by CuongNguyen on 11/30/16.
//  Copyright © 2016 HDApps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DLAddBarAssesoryTypeStop = 0,
    DLAddBarAssesoryTypeRefresh
} DLAddBarAssesoryType;

@interface DLAddressBarView : UISearchBar

@property (nonatomic, strong) void(^endEdit)();
@property (nonatomic, strong) void(^beginEdit)();
@property (nonatomic, strong) void(^searchPress)(NSString *text);
@property (nonatomic, strong) void(^cancelPress)();
@property (nonatomic, strong) void(^textDidChanged)(NSString *text);
@property (nonatomic, strong) void(^didTouchAssesoryType)(DLAddBarAssesoryType type);

@property (nonatomic, readwrite) UIProgressView *progressView;

-(void)setAddressBarTitle:(NSString *)title;
-(void)setAddressBarLink:(NSString *)link;
-(void)updateAssesoryViewForStateLoading:(BOOL)isLoading;

@end

