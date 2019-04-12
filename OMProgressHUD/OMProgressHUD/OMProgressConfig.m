//
//  OMProgressConfig.m
//  OMProgressHUD
//
//  Created by 印聪 on 2019/4/12.
//  Copyright © 2019 tima. All rights reserved.
//

#import "OMProgressConfig.h"

static OMProgressConfig *config = nil;
@implementation OMProgressConfig


+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[OMProgressConfig alloc] init];
    });
    return config;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _loadingMaskColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
        _loadingContentColor = [[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] colorWithAlphaComponent:0.5];
        _loadingContentSize = CGSizeMake(80, 80);
        
        _loadingImageSize = CGSizeMake(46, 46);
        _interLoadingImageTextSpacing = 15;
        _loadImage = [UIImage imageNamed:@"progress_icon_loading"];
        
        _loadingTextColor = [UIColor whiteColor];
        _loadingTextFont = [UIFont systemFontOfSize:16];
        
        _textContentColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
        _textColor = [UIColor whiteColor];
        _font = [UIFont systemFontOfSize:16];
        _textCornerRadius = 6.0;
        _textEdgeInsets = UIEdgeInsetsMake(16, 10, 10, 16);
        
        _position = OMProgressHudTextPositionMiddle;
        _tailSpacing = 40;
        
        _loadingRate = 1.5;
        _loadingText = @"加载中...";
        
    }
    return self;
}

///**覆盖该方法主要确保当用户通过[[Singleton alloc] init]创建对象时对象的唯一性，alloc方法会调用该方法，只不过zone参数默认为nil，因该类覆盖了allocWithZone方法，所以只能通过其父类分配内存，即[super allocWithZone:zone]
// 28  */
//+ (id)allocWithZone:(struct _NSZone *)zone{
//    return [OMProgressConfig sharedInstance];
//}
//
////覆盖该方法主要确保当用户通过copy方法产生对象时对象的唯一性
//- (id)copy{
//    return self;
//}
//
////覆盖该方法主要确保当用户通过mutableCopy方法产生对象时对象的唯一性
// - (id)mutableCopy{
//     return self;
// }

@end
