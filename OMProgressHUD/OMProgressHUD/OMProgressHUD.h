//
//  TMSProgressHUD.h
//  TiMaSuperApp
//
//  Created by 印聪 on 2017/6/29.
//  Copyright © 2017年 tima. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OMProgressHUD : UIView


/**
 显示环形加载样式
 */
+ (void)show;


/**
 显示图片加载样式，图片在config中设.加载文本为"加载中..."
 */
+ (void)showImageLoading;


/**
 显示图片加载样式，图片在config中设置.加载文本传入

 @param loadingText 加载文本
 */
+ (void)showImageLoading:(NSString *)loadingText;

/**
 取消loading
 */
+ (void)dismiss;


/**
 显示提示文本

 @param message 提示文本
 */
+ (void)show:(NSString *)message;



@end
