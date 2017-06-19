//
//  DLAddressBarView.m
//  Downloader
//
//  Created by CuongNguyen on 11/30/16.
//  Copyright © 2016 HDApps. All rights reserved.
//

#import "DLAddressBarView.h"

@interface DLAddressBarView() <UISearchBarDelegate>

@property (nonatomic) UITextField *textField;

@property (nonatomic) NSString *currentTitle;
@property (nonatomic) NSString *currentLink;


@property (nonatomic) NSString *addressTitle;
@property (nonatomic) NSString *addressLink;
@property (nonatomic) BOOL isLoadingState;

@end

@implementation DLAddressBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.placeholder = @"Type your search or enter website name";
        
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UITextField class]]) {
                self.textField = (UITextField *)subview;
                break;
            }
            for (UIView *subSubView in subview.subviews) {
                if ([subSubView isKindOfClass:[UITextField class]]) {
                    self.textField = (UITextField *)subSubView;
                    break;
                }
            }
        }
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    
    self.clipsToBounds = NO;
    
    if (self.textField) {
        self.textField.keyboardType = UIKeyboardTypeWebSearch;
        self.textField.returnKeyType = UIReturnKeyGo;
        self.textField.backgroundColor = MakeColor(241, 242, 242, 1);
        self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    
    self.showsBookmarkButton = NO;
    
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)keyboardDidShow: (NSNotification *) notif{
    if (self.window && [self.textField isEditing]) {
        [self setShowsCancelButton:YES animated:NO];
        self.textField.text = self.addressLink;
        [self configUITextField];
    }
}

- (void)keyboardDidHide: (NSNotification *) notif{
    if (self.window && ![self.textField isEditing]) {
        [self setShowsCancelButton:NO animated:NO];
        self.textField.text = self.addressTitle;
        [self configUITextField];
    }
}

-(void)updateAssesoryViewForStateLoading:(BOOL)isLoading {
    self.showsBookmarkButton = NO;
}

-(void)configUITextField {
    
    if (self.textField.text.length == 0 && !self.textField.editing) {
        self.textField.leftViewMode = UITextFieldViewModeAlways;
    } else {
        self.textField.leftViewMode = UITextFieldViewModeNever;
    }
    
    self.textField.textAlignment = NSTextAlignmentLeft;
    self.showsBookmarkButton = NO;
    
    if (self.textField.editing) {
        [self animation:self.textField textAlignment:NSTextAlignmentLeft];
        self.searchTextPositionAdjustment = UIOffsetMake(0, 0);
    } else {
        [self animation:self.textField textAlignment:NSTextAlignmentCenter];
        CGSize size = [self.addressTitle sizeWithAttributes:@{NSFontAttributeName:self.textField.font}];
        if (size.width > (self.textField.bounds.size.width - 40)) {
            self.searchTextPositionAdjustment = UIOffsetMake(0, 0);
        } else {
            self.searchTextPositionAdjustment = UIOffsetMake(4, 0);
        }
    }
}

-(void)animation:(UITextField *)textField textAlignment:(NSTextAlignment)textAlignment{
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [UIView transitionWithView:textField
    //                          duration:0.3
    //                           options:UIViewAnimationOptionTransitionCrossDissolve
    //                        animations:^{
    textField.textAlignment = textAlignment;
    //                        } completion:nil];
    //    });
    
}

-(void)setAddressBarTitle:(NSString *)title {
    if (!self.textField.editing) {
        [self.textField setText:title];
    }
    self.addressTitle = title;
    [self configUITextField];
    
}

-(void)setAddressBarLink:(NSString *)link {
    self.addressLink = link;
    [self configUITextField];
}

- (UIProgressView *)progressView
{
    if (!_progressView)
    {
        CGFloat lineHeight = 1.5f;
        CGRect frame = CGRectMake(0,
                                  self.bounds.size.height - lineHeight,
                                  CGRectGetWidth([[UIScreen mainScreen] bounds]),
                                  lineHeight);
        
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:frame];
        progressView.trackTintColor = [UIColor clearColor];
        progressView.alpha = 0.0f;
        
        [self addSubview:progressView];
        _progressView = progressView;
    }
    return _progressView;
}

#pragma mark -
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:NO];
    [self configUITextField];
    
    self.textField.text = self.addressLink;
    
    if (self.textField.text) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.textField setSelectedTextRange:[self.textField textRangeFromPosition:self.textField.beginningOfDocument toPosition:self.textField.endOfDocument]];
        });
    }
    
    if (self.beginEdit) {
        self.beginEdit();
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //    [searchBar setShowsCancelButton:NO animated:YES];
    //    [self configUITextField];
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        self.textField.text = self.addressTitle;
    //    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                [(UIButton *)subview setEnabled:YES];
            }
            for (UIView *subSubView in subview.subviews) {
                if ([subSubView isKindOfClass:[UIButton class]]) {
                    [(UIButton *)subSubView setEnabled:YES];
                }
            }
        }
    });
    
    if (self.endEdit) {
        self.endEdit();
    }
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (self.textDidChanged) {
        self.textDidChanged(searchText);
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    
    [self configUITextField];
    
    self.currentLink = self.addressLink;
    self.currentTitle = self.addressTitle;
    
    if (self.searchPress) {
        self.searchPress(searchBar.text);
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.textField resignFirstResponder];
    [self configUITextField];
    self.textField.text = self.addressTitle;
    if (self.cancelPress) {
        self.cancelPress();
    }
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    if (self.didTouchAssesoryType) {
        self.didTouchAssesoryType(self.isLoadingState ? DLAddBarAssesoryTypeStop : DLAddBarAssesoryTypeRefresh);
    }
    [self updateAssesoryViewForStateLoading:!self.isLoadingState];
}

@end
