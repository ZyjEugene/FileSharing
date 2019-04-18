//
//  DQBaseWebViewController.h
//  WebThings
//
//  Created by Heidi on 2017/9/22.
//  Copyright © 2017年 machinsight. All rights reserved.
//  文档预览及文档共享

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DQFilePathType) {
    DQFilePathTypeNetFile = 0, // 网络文件 xls、pdf、html、txt
    DQFilePathTypeNetTXT,      // 网络文件 txt

    DQFilePathTypeLocalFile,   // 本地文件 xls、pdf
    DQFilePathTypeLocalTXT,    // 本地文件 txt
    DQFilePathTypeLocalHTML,   // 本地文件 mainBundle中的html
};

@interface DQBaseWebViewController : UIViewController

#pragma mark - 初始化方法一
/** 导航条标题 */
@property (nonatomic, copy) NSString *navTitle;

/** 本地文件路径(fileURLWithPath:编码后的url -> 前缀@“file://”)
 *  网络文件路径(URLWithString:编码后的url -> 前缀“http://”) */
@property (nonatomic, strong) NSURL *fileURL;

/** 预览本地bundle html文件名 */
@property (nonatomic, copy) NSString *localHtmlName;

/** 文件路径类型 */
@property (nonatomic, assign) DQFilePathType pathType;

#pragma mark - 初始化方法二
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
                     filePathType:(DQFilePathType)pathType;

#pragma mark - 加载文件
- (void)loadFileData;

@end 
