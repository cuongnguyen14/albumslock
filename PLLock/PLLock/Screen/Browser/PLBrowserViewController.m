//
//  PLBrowserViewController.m
//  PLLock
//
//  Created by CuongNguyen on 6/13/17.
//  Copyright © 2017 CuongNguyen. All rights reserved.
//

#import "PLBrowserViewController.h"
#import "DLAddressBarView.h"
#import "DZNWebView.h"
#import "NSString+DLStringValidater.h"

static char CNKVOContext  = 0;
#define DZN_IS_IPAD [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define DZN_IS_LANDSCAPE ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)

@interface PLBrowserViewController () <WKUIDelegate, DZNNavigationDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) DLAddressBarView *addressBar;
@property (nonatomic, strong) UIView *addressView;
@property (nonatomic, strong) DZNWebView *webView;
@property (nonatomic) BOOL isload;
@property (nonatomic) BOOL completedInitialLoad;
@property (nonatomic, strong) UIBarButtonItem *backwardBarItem;
@property (nonatomic, strong) UIBarButtonItem *forwardBarItem;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, weak) UIToolbar *toolbar;
@property (nonatomic, weak) UINavigationBar *navigationBar;
@property (nonatomic, strong) UIView *navigationBarSuperView;
@property (nonatomic, strong) UIBarButtonItem *shareTabBarItem;

@end

@implementation PLBrowserViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.webView = [[DZNWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.allowsBackForwardNavigationGestures = YES;
    self.webView.UIDelegate = self;
    self.webView.navDelegate = self;
    self.webView.scrollView.delegate = self;
    self.webView.opaque = YES;
    
    self.completedInitialLoad = NO;
    
    self.isload = YES;
    
    [self customUserScript];
    
    [self customAddressBar];
}


-(void)customUserScript {
    
    [self webView:self.webView addScriptName:@"cssProperties" injectionTime:WKUserScriptInjectionTimeAtDocumentStart];
    [self webView:self.webView addScriptName:@"cssProperties" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd];
    
    [self webView:self.webView addScriptName:@"video_play_new" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd];
    [self webView:self.webView addScriptMessageHandler:@"videoPlayHandler"];
}

- (void) removeUserScript {
    
    if (self.webView) {
        [self.webView.configuration.userContentController removeAllUserScripts];
        [self webView:self.webView removeScriptMessageHandler:@"videoPlayHandler"];
    }
}

#pragma mark SCRIPT METHOD

-(NSString *)jsCodeByName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return jsCode;
}

-(void)webView:(WKWebView *)webView addScriptName:(NSString *)name injectionTime:(WKUserScriptInjectionTime)injectionTime{
    NSString *scriptCode = [self jsCodeByName:name];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:scriptCode
                                                  injectionTime:injectionTime
                                               forMainFrameOnly:NO];
    [webView.configuration.userContentController addUserScript:script];
}

-(void)webView:(WKWebView *)webView addScriptMessageHandler:(NSString *)name {
//    [webView.configuration.userContentController addScriptMessageHandler:dlDownloadMgr.firewall name:name];
}

- (void) webView:(WKWebView *)webView removeScriptMessageHandler:(NSString *)name {
    [webView.configuration.userContentController removeScriptMessageHandlerForName:name];
}

#pragma mark Address Bar
-(void)customAddressBar {
    
    self.addressBar = [[DLAddressBarView alloc] init];
    
    weakify(self);
    [self.addressBar setBeginEdit:^{
        
    }];
    
    [self.addressBar setSearchPress:^(NSString *text) {
        NSURL *url = [self_weak_ generateURLWithString:self_weak_.addressBar.text];
        if ([[url absoluteString] isValidURL]) {
            [self_weak_ goToLinkWithUrl:url];
        } else {
            [self_weak_ goToLinkWithUrl:[self_weak_ getUrlSearchWithKey:self_weak_.addressBar.text]];
        }
    }];
    
    [self.addressBar setTextDidChanged:^(NSString *searchText) {
        
        
    }];
    
    [self.addressBar setDidTouchAssesoryType:^(DLAddBarAssesoryType type) {
        if (type == DLAddBarAssesoryTypeStop) {
            [self_weak_.webView stopLoading];
        } else if (type == DLAddBarAssesoryTypeRefresh) {
            [self_weak_.webView reload];
        }
    }];
    
    [self.addressBar setCancelPress:^{

    }];
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    self.view = self.webView;
    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAddressBar];
    
    if (self.webView) {
        [self doButtonHome];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.completedInitialLoad) {
        
        [UIView performWithoutAnimation:^{
            [self configureToolBars];
        }];
        self.completedInitialLoad = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    [self clearProgressViewAnimated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Update frame webview even this view controller is not shown
    //    self.webView.frame = self.view.bounds;
}

- (void) setupAddressBar {
    if (self.addressBar) {
        self.addressBar.backgroundImage = [UIImage new];
        self.addressBar.frame = self.navigationController.navigationBar.bounds;
        self.addressBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        self.addressView = [[UIView alloc] initWithFrame:self.addressBar.bounds];
        [self.addressView addSubview:self.addressBar];
        self.addressView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        self.navigationItem.titleView = self.addressView;
    }
}

#pragma mark - Getter methods

- (UIProgressView *)progressView
{
    if (!_progressView)
    {
        CGFloat lineHeight = 1.5f;
        CGRect frame = CGRectMake(0,
                                  CGRectGetHeight(self.navigationController.navigationBar.bounds) - lineHeight,
                                  CGRectGetWidth(self.navigationController.navigationBar.bounds),
                                  lineHeight);
        
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:frame];
        progressView.trackTintColor = [UIColor clearColor];
        progressView.alpha = 0.0f;
        
        [self.navigationController.navigationBar addSubview:progressView];
        _progressView = progressView;
    }
    return _progressView;
}


- (UIBarButtonItem *)shareTabBarItem
{
    if (!_shareTabBarItem)
    {
        _shareTabBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"safari"] landscapeImagePhone:nil style:0 target:self action:@selector(shareTab:)];
        _shareTabBarItem.accessibilityLabel = @"Share";
        _shareTabBarItem.enabled = YES;
    }
    return _shareTabBarItem;
}

- (UIBarButtonItem *)backwardBarItem
{
    if (!_backwardBarItem)
    {
        _backwardBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_previous"] landscapeImagePhone:nil style:0 target:self action:@selector(goBackward:)];
        _backwardBarItem.accessibilityLabel = @"Backward";
        _backwardBarItem.enabled = NO;
    }
    return _backwardBarItem;
}

- (UIBarButtonItem *)forwardBarItem
{
    if (!_forwardBarItem)
    {
        _forwardBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_next"] landscapeImagePhone:nil style:0 target:self action:@selector(goForward:)];
        _forwardBarItem.landscapeImagePhone = nil;
        _forwardBarItem.accessibilityLabel = @"Forward";
        _forwardBarItem.enabled = NO;
    }
    return _forwardBarItem;
}

-(void)shareTab:(id)sender {
    NSURL *url = [self.webView URL];
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}

- (NSArray *)navigationToolItems
{
    NSMutableArray *items = [NSMutableArray new];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    [items addObject:self.backwardBarItem];
    
    [items addObject:flexibleSpace];
    [items addObject:self.forwardBarItem];
    
    //Share button
    [items addObject:flexibleSpace];
    [items addObject:self.shareTabBarItem];
    
//    //Bookmark button
//    [items addObject:flexibleSpace];
//    [items addObject:self.bookmarkTabBarItem];
    
//    //Multi tab button
//    [items addObject:flexibleSpace];
//    [items addObject:self.multiTabBarItem];
    
    return items;
}

- (void)configureToolBars
{
    [self setToolbarItems:[self navigationToolItems]];
    
    self.toolbar = self.navigationController.toolbar;
    
    self.navigationBar = self.navigationController.navigationBar;
    self.navigationBarSuperView = self.navigationController.navigationBar.superview;
    
    weakify(self);
    [self.navigationBar addObserver:self_weak_ forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:&CNKVOContext ];
    [self.navigationBar addObserver:self_weak_ forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:&CNKVOContext ];
    [self.navigationBar addObserver:self_weak_ forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:&CNKVOContext ];
    
    self.navigationController.hidesBarsWhenVerticallyCompact = YES;
    [self.navigationController setToolbarHidden:NO];
}

#pragma mark - Setter methods

- (void)setLoadingError:(NSError *)error
{
    switch (error.code) {
        case NSURLErrorUnknown:
        case NSURLErrorCancelled:   return;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}


#pragma mark - DZNWebViewController methods

- (void)loadURL:(NSURL *)URL
{
    NSURL *baseURL = [[NSURL alloc] initFileURLWithPath:URL.path.stringByDeletingLastPathComponent isDirectory:YES];
    [self loadURL:URL baseURL:baseURL];
}

- (void)loadURL:(NSURL *)URL baseURL:(NSURL *)baseURL
{
    if ([URL isFileURL]) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
        NSString *HTMLString = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        
        [self.webView loadHTMLString:HTMLString baseURL:baseURL];
    }
    else {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
        [self.webView loadRequest:request];
    }
}

- (void)goBackward:(id)sender
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (void)goForward:(id)sender
{
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}

- (void)updateToolbarItems
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:[self.webView isLoading]];
    
    self.backwardBarItem.enabled = [self.webView canGoBack];
    self.forwardBarItem.enabled = [self.webView canGoForward];
}

- (void)clearProgressViewAnimated:(BOOL)animated
{
    if (!_progressView) {
        return;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0
                     animations:^{
                         self.progressView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self destroyProgressViewIfNeeded];
                     }];
}

- (void)destroyProgressViewIfNeeded
{
    if (_progressView) {
        [_progressView removeFromSuperview];
        _progressView = nil;
    }
}


-(void)disableOriginalLongPressOfWebView:(WKWebView *)webView {
    [webView evaluateJavaScript:@"document.body.style.webkitTouchCallout='none';" completionHandler:nil];
}

#pragma mark - DZNNavigationDelegate methods
-(void)updateAddressTitle {
    weakify(self);
    [self.webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *title, NSError * _Nullable error) {
        if (title && [title isKindOfClass:[NSString class]] && title.length > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self_weak_.addressBar setAddressBarTitle:title];
                [self_weak_.addressBar setAddressBarLink:[[self.webView URL] absoluteString]];
            });
        }
    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(self.isload ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(self.isload ? WKNavigationResponsePolicyAllow : WKNavigationResponsePolicyCancel);
}

- (void)webView:(DZNWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self.addressBar setAddressBarTitle:[[self.webView URL] host]];
    [self.addressBar setAddressBarLink:[[self.webView URL] absoluteString]];
    [self.addressBar updateAssesoryViewForStateLoading:YES];
    [self disableOriginalLongPressOfWebView:webView];
}

- (void)webView:(DZNWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    [self.addressBar updateAssesoryViewForStateLoading:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:[self.webView isLoading]];
}

- (void)webView:(DZNWebView *)webView didUpdateProgress:(CGFloat)progress
{
    
    if (self.progressView.alpha == 0 && progress > 0) {
        
        self.progressView.progress = 0;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.progressView.alpha = 1.0;
        }];
    }
    else if (self.progressView.alpha == 1.0 && progress == 1.0)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.progressView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.progressView.progress = 0;
        }];
    }
    
    [self.progressView setProgress:progress animated:YES];
}

- (void)webView:(DZNWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self updateAddressTitle];
    [self.addressBar updateAssesoryViewForStateLoading:NO];
    [self disableOriginalLongPressOfWebView:webView];
    BOOL isLoading = [self.webView isLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:isLoading];
    
}

- (void)webView:(DZNWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self disableOriginalLongPressOfWebView:webView];
    [self.addressBar updateAssesoryViewForStateLoading:NO];
    [self setLoadingError:error];
    
    // if this is a cancelled error, then don't affect the title
    switch (error.code) {
        case NSURLErrorCancelled:   return;
    }
    
    self.title = nil;
}


#pragma mark - WKUIDelegate methods

- (DZNWebView *)webView:(DZNWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

#pragma mark - UIScrollViewDelegate

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    
    BOOL isNavHidden = self.navigationBar.frame.origin.y < 0;
    
    if (isNavHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    return !isNavHidden;
}

#pragma mark - Key Value Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != &CNKVOContext ) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([object isEqual:self.navigationBar]) {
        
        // Skips for landscape orientation, since there is no status bar visible on iPhone landscape
        if (DZN_IS_LANDSCAPE) {
            return;
        }
        
        id new = change[NSKeyValueChangeNewKey];
        
        if ([keyPath isEqualToString:@"hidden"] && [new boolValue] && self.navigationBar.center.y >= -2.0) {
            
            self.navigationBar.hidden = NO;
            
            if (!self.navigationBar.superview) {
                [self.navigationBarSuperView addSubview:self.navigationBar];
            }
        }
        
        if ([keyPath isEqualToString:@"center"]) {
            
            CGPoint center = [new CGPointValue];
            
            if (center.y < -2.0) {
                center.y = -2.0;
                self.navigationBar.center = center;
                
                [UIView beginAnimations:@"DZNNavigationBarAnimation" context:nil];
                
                for (UIView *subview in self.navigationBar.subviews) {
                    if (subview != self.navigationBar.subviews[0]) {
                        subview.alpha = 0.0;
                    }
                }
                
                [UIView commitAnimations];
            }
        }
    }
    
    if ([object isEqual:self.webView] && ([keyPath isEqualToString:@"canGoBack"] || [keyPath isEqualToString:@"canGoForward"])) {
        [self updateToolbarItems];
    }
}

#pragma mark - View lifeterm

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc {
    NSLog(@"== Dealloc %@ cmnr ==", [self class]);
    [self myDealloc];
}

- (void)cancelRequest {
    
    [self myDealloc];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self myDealloc];
    });
}

-(void)myDealloc {
    [self.webView stopLoading];
    [self removeUserScript];
    @try {
        [self.navigationBar removeObserver:self forKeyPath:@"hidden" context:&CNKVOContext ];
        [self.navigationBar removeObserver:self forKeyPath:@"center" context:&CNKVOContext ];
        [self.navigationBar removeObserver:self forKeyPath:@"alpha" context:&CNKVOContext ];
        [self.webView removeObserver:self forKeyPath:@"canGoBack" context:&CNKVOContext ];
        [self.webView removeObserver:self forKeyPath:@"canGoForward" context:&CNKVOContext ];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    _progressView = nil;
    _navigationBar = nil;
    _navigationBarSuperView = nil;
    _backwardBarItem = nil;
    _forwardBarItem = nil;
    _shareTabBarItem = nil;
    _progressView = nil;
    
    _webView.scrollView.delegate = nil;
    _webView.navDelegate = nil;
    _webView.UIDelegate = nil;
    _webView = nil;
    self.view = nil;
}

- (NSURL *)generateURLWithString:(NSString *)str {
    NSURL *result = [NSURL URLWithString:str];
    if (![result.scheme isEqual:@"http"] && ![result.scheme isEqual:@"https"]) {
        result = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", str]];
    }
    return result;
}

#pragma mark - webview delegate

-(NSString *)titleOfWebView:(UIWebView *)webView {
    NSURL *url = [webView.request URL];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.domain"];
    title = [self trimmingString:title];
    if (title.length == 0) {
        title = [url absoluteString];
    }
    if ([title hasPrefix:@"www."]) {
        title = [title stringByReplacingOccurrencesOfString:@"www." withString:@""];
    }
    return title;
}

-(void) doButtonHome {
    [self goToLinkWithUrl:[NSURL URLWithString:@"https://www.google.com"]];
}

- (void)goToLinkWithUrl:(NSURL *)url{
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.addressBar setAddressBarTitle:[url host]];
    [self.addressBar setAddressBarLink:[url absoluteString]];
    [self.addressBar updateAssesoryViewForStateLoading:YES];
}

- (NSString *)trimmingString:(NSString *)string{
    return [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}

-(NSURL *)getUrlSearchWithKey:(NSString*) key {
    
    NSString *result = @"";
    key = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    key = [key stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *currentLanguage = [[language componentsSeparatedByString:@"-"] firstObject];
    
    result = [NSString stringWithFormat:@"https://google.com/search?q=%@&hl=%@", key, currentLanguage];
    
    return [NSURL URLWithString:result];
}

@end
