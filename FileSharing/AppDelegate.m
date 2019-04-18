//
//  AppDelegate.m
//  FileSharing
//
//  Created by Eugene on 2019/4/17.
//  Copyright © 2019 Eugene. All rights reserved.
//

#import "AppDelegate.h"
#import "DQBaseWebViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) DQBaseWebViewController *webView;

@end

@implementation AppDelegate

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    // to do something
    return YES;
}
#else
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options {
    // to do something
    NSString *str = [NSString stringWithFormat:@"\n发送请求的应用程序的 Bundle ID：%@\n\n文件的NSURL：%@", options[UIApplicationOpenURLOptionsSourceApplicationKey], url];
    NSLog(@"options:%@",str);
    if (options) {
        /** 1、在info.plist中注册本App为可共享应用程序以及注册可接受文件类型（pdf、xls、word、image等等） 2、AppDelegate中接收应用程序发送方发来的文件路径
            3、处理文件路径
         */
        self.webView.pathType = DQFilePathTypeLocalFile;
        self.webView.fileURL = url;
        [self.webView loadFileData];
    }
    return YES;
}
#endif

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    self.webView = [[DQBaseWebViewController alloc] init];
    UINavigationController *navController    = [[UINavigationController alloc] initWithRootViewController:self.webView];
    self.window                    = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor    = [UIColor whiteColor];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];

     return YES;
}

@end
