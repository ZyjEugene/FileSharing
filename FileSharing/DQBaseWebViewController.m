//
//  DQBaseWebViewController.m
//  WebThings
//
//  Created by Heidi on 2017/9/22.
//  Copyright © 2017年 machinsight. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "DQBaseWebViewController.h"
#import "Masonry.h"

@interface DQBaseWebViewController ()<WKNavigationDelegate>

/** web */
@property (nonatomic, strong) WKWebView *wkWebView;
/** 进度条 */
@property (nonatomic, strong) UIProgressView *progressView;
/** 直接调用分享页面，一定要全局文档对象 */
@property(nonatomic, strong) UIDocumentInteractionController *documentController;

@end

@implementation DQBaseWebViewController

/**
 初始化本地、网络文件展示控制器

 @param title 控制器title
 @param fileURL 本地文件路径(fileURLWithPath:编码后的url -> 前缀@“file://”)
 * 网络文件路径(URLWithString:编码后的url -> 前缀“http://”)
 @param pathType 文件路径类型（本地、网络）
 @return 展示控制器对象
 */
- (instancetype)initWithViewTitle:(NSString *)title
                          fileURl:(NSURL *)fileURL
                     filePathType:(DQFilePathType)pathType {
    self = [super init];
    if (self) {
        self.navTitle = title;
        self.fileURL = fileURL;
        self.pathType = pathType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.navTitle;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"file_share_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(onFileSharingClick:)];

    [self initWebView];
    //[self loadFileData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.wkWebView.navigationDelegate = self;
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress"
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    self.wkWebView.navigationDelegate = nil;

    [super viewDidDisappear:animated];
}

- (void)initWebView {
    // 进度条
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(1);
    }];
    // web布局
    [self.wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressView.mas_bottom);
        make.left.bottom.right.equalTo(self.view);
    }];
}

/** 加载文件数据 */
- (void)loadFileData {

    NSString *tempURL = self.fileURL.absoluteString;
    NSURL *url = self.fileURL;
    if ([[tempURL lowercaseString] hasPrefix:@"http://"] ||
        self.pathType == DQFilePathTypeNetFile) {
        // 网络文件路径 xls、pdf、html、txt
        if (self.pathType == DQFilePathTypeLocalTXT ||
            [tempURL.lowercaseString hasSuffix:@"txt"]) {
            // txt
            NSData *data = [NSData dataWithContentsOfURL:url];
            if (data == nil) {
                // @"数据异常"
            } else {
                [self.wkWebView loadData:data MIMEType:@"text/plain" characterEncodingName:@"UTF-8" baseURL:url];
            }
        } else {
            // xls、pdf、html
            [self.wkWebView loadRequest:[NSURLRequest requestWithURL:url]];
        }
    } else {
        // 本地文件 xls、pdf、html、txt
        if (self.pathType == DQFilePathTypeLocalHTML) {
            // html
            NSString *path = [[NSBundle mainBundle] pathForResource:self.localHtmlName ofType:@"html"];
            NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
            [self.wkWebView loadHTMLString:htmlString baseURL:baseURL];
        } else if (self.pathType == DQFilePathTypeLocalTXT ||
                   [tempURL.lowercaseString hasSuffix:@"txt"]) {
            // txt
            NSData *data = [NSData dataWithContentsOfURL:url];
            if (data == nil) {
                // @"数据异常"
            } else {
                [self.wkWebView loadData:data MIMEType:@"text/plain" characterEncodingName:@"UTF-8" baseURL:url];
            }
        } else {
            // xls、pdf
            [self.wkWebView loadFileURL:url allowingReadAccessToURL:url];
        }
    }
}

#pragma mark - Actions
- (void)onFileSharingClick:(id)sender {
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:self.fileURL];
    self.documentController.name = self.title;
    BOOL isOpen = [self.documentController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    if (isOpen) {
        NSLog(@"-- 分享成功 --");
    } else {
        NSLog(@"-- 分享失败 --");
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:@"estimatedProgress"] && object == self.wkWebView) {
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:YES];
        if(self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WKNavigationDelegate来追踪加载过程
/// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {

}

/// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {

}

/// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

}

/// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {

}

/// 网络异常、页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {

}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {

}

#pragma mark - Lazy
- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc] init];
        [self.view addSubview:_wkWebView];
        if (@available(iOS 11.0, *)) {
            _wkWebView.scrollView.contentInset = UIEdgeInsetsZero;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _wkWebView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.tintColor = [UIColor redColor];
        _progressView.trackTintColor = [UIColor grayColor];
        [self.view addSubview:_progressView];
    }
    return _progressView;
}

@end

