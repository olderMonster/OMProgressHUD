//
//  OMProgressConfig.h
//  OMProgressHUD
//
//  Created by 印聪 on 2019/4/12.
//  Copyright © 2019 tima. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

//显示文本时文本垂直方向位置(居上、居中、居下)
typedef NS_ENUM(NSInteger , OMToastVerticalPosition) {
    OMToastVerticalPositionTop,
    OMToastVerticalPositionCenter,
    OMToastVerticalPositionBottom
};

@interface OMProgressConfig : NSObject

/** 加载文本，默认为“加载中...” */
@property (nonatomic , copy)NSString *loadingText;

/** 加载样式图片 */
@property (nonatomic , strong)UIImage *loadImage;

/** 底部半透明背景颜色，loading时的遮罩颜色，默认为透明 */
@property (nonatomic , strong)UIColor *loadingMaskColor;

/** loding的背景颜色 */
@property (nonatomic , strong)UIColor *loadingContentColor;

/** loading文本颜色及字体 */
@property (nonatomic , strong)UIColor *loadingTextColor;
@property (nonatomic , strong)UIFont *loadingTextFont;

/** loading效果灰色背景颜色，默认(80,80) */
@property (nonatomic , assign)CGSize loadingContentSize;

/** loading图片尺寸，默认为(46,46) */
@property (nonatomic , assign)CGSize loadingImageSize;

/** loading图片与文本的间距，默认为15 */
@property (nonatomic , assign)CGFloat interLoadingImageTextSpacing;

/** 显示文本时的背景颜色，一般为黑色半透明 */
@property (nonatomic , strong)UIColor *textContentColor;

/** 文本颜色 */
@property (nonatomic , strong)UIColor *textColor;

/** 文本字体大小，默认为16 */
@property (nonatomic , strong)UIFont *font;

/** 文本的圆角,默认为6 */
@property (nonatomic , assign)CGFloat textCornerRadius;

/** 文本的边距，默认为(16,10,16,10) */
@property (nonatomic , assign)UIEdgeInsets textEdgeInsets;

/** toast文本垂直方向位置,默认居中 */
@property (nonatomic , assign)OMToastVerticalPosition toastPosition;

/** 当position为居上或者居下的时候其距上或者距下的默认边距，默认为40； */
@property (nonatomic , assign)CGFloat tailSpacing;

/** loading动画一周持续时间，默认1.5 */
@property (nonatomic , assign)CGFloat loadingRate;


/**************************** 显示带图的toast信息 *******************************/

/** 带图片显示toast图片的边距，默认为(20,37,20,37) */
@property (nonatomic , assign)UIEdgeInsets tp_ImageEdgeInsets;

/** 带图显示toast文本的边距，默认为(0,12,18,12) */
@property (nonatomic , assign)UIEdgeInsets tp_TextEdgeInsets;

/*******************************************************************************/




+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
