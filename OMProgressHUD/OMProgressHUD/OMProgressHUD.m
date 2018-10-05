//
//  TMSProgressHUD.m
//  TiMaSuperApp
//
//  Created by 印聪 on 2017/6/29.
//  Copyright © 2017年 tima. All rights reserved.
//

#import "OMProgressHUD.h"

@interface OMProgressHUD()

@property (nonatomic , strong)UIImageView *loadingImageView;
@property (nonatomic , strong)UIImageView *centerImageView;
@property (nonatomic , strong)UILabel *messageLabel;

@end

@implementation OMProgressHUD


+ (instancetype)defaultView{
    static OMProgressHUD *defaultView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultView = [[OMProgressHUD alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    });
    return defaultView;
}



- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.centerImageView];
        [self addSubview:self.loadingImageView];
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
        
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = 80;
    self.centerImageView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * 0.5 - width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5 - width * 0.5 - 64, width, width);
    self.loadingImageView.bounds = CGRectMake(0, 0, width * 0.6, width * 0.6);
    self.loadingImageView.center = self.centerImageView.center;
    
}


#pragma mark -- private method
- (UIWindow *)frontWindow {
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= UIWindowLevelNormal);
        
        if(windowOnMainScreen && windowIsVisible && windowLevelSupported) {
            return window;
        }
    }
    return nil;
}

- (void)beginLoadAnimation{
    //动画
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: -M_PI * 2.0 ];
    rotationAnimation.duration = 0.8;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = ULLONG_MAX;
    [self.loadingImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
}


- (void)endLoadAnimation{
    [self.loadingImageView.layer removeAllAnimations];
}

#pragma mark -- public method
+ (void)show{
    
    [OMProgressHUD defaultView].loadingImageView.hidden = NO;
    [OMProgressHUD defaultView].centerImageView.hidden = NO;
    [OMProgressHUD defaultView].messageLabel.hidden = NO;
    [[OMProgressHUD defaultView] setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [[OMProgressHUD defaultView] setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
    UIWindow *window = [[OMProgressHUD defaultView] frontWindow];
    if (window) {
        [window addSubview:[OMProgressHUD defaultView]];
        [[OMProgressHUD defaultView] beginLoadAnimation];
    }
   
}

+ (void)dismiss{
    
    if ([OMProgressHUD defaultView]) {
        [OMProgressHUD defaultView].messageLabel.text = nil;
        [[OMProgressHUD defaultView] endLoadAnimation];
        [[OMProgressHUD defaultView] removeFromSuperview];
        
        if ([OMProgressHUD defaultView].messageLabel) {
            [[OMProgressHUD defaultView].messageLabel removeFromSuperview];
        }
        
    }
}


+ (void)show:(NSString *)message{
    
    if ([OMProgressHUD defaultView].messageLabel && [[OMProgressHUD defaultView].messageLabel.text isEqualToString:message]) {
        return;
    }
    
    
    UIWindow *window = [[OMProgressHUD defaultView] frontWindow];
    if (window) {
        
        if ([OMProgressHUD defaultView].messageLabel) {
            [[OMProgressHUD defaultView].messageLabel removeFromSuperview];
        }
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        [label sizeToFit];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        label.backgroundColor = [[UIColor colorWithRed:60/255.0 green:60/255.0 blue:60/255.0 alpha:1.0] colorWithAlphaComponent:0.8];
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 5;
        label.text = message;
        CGFloat textMaxW = [UIScreen mainScreen].bounds.size.width - 20;
        CGSize size = [message sizeWithAttributes:@{NSFontAttributeName:label.font}];
        size = CGSizeMake(size.width + 20, 50);
        if (size.width > textMaxW) {
            //最大高度为屏幕高度减去下边距(label距离屏幕底部)高度(40)，再减去上边距高度(20)
            CGFloat maxH = [UIScreen mainScreen].bounds.size.height - 40 - 20;
            CGRect rect = [message boundingRectWithSize:CGSizeMake(textMaxW, maxH) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil];
            size = CGSizeMake(textMaxW, rect.size.height + 10);
        }
        label.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - size.width) * 0.5, [UIScreen mainScreen].bounds.size.height - 40 - size.height, size.width, size.height);
        [window addSubview:label];
        
        [OMProgressHUD defaultView].messageLabel = label;
        
        
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(dismissInfo:) userInfo:label repeats:NO];
        
    }
}

+ (void)dismissInfo:(NSTimer *)timer{
    
    UILabel *label = timer.userInfo;
    [label removeFromSuperview];
    if ([label.text isEqualToString:[OMProgressHUD defaultView].messageLabel.text]) {
        [OMProgressHUD defaultView].messageLabel = nil;
        [[OMProgressHUD defaultView] removeFromSuperview];
    }
}


#pragma mark -- getters and setters
- (UIImageView *)loadingImageView{
    if (_loadingImageView == nil) {
        _loadingImageView = [[UIImageView alloc] init];
        _loadingImageView.image = [UIImage imageNamed:@"loading_icon"];
    }
    return _loadingImageView;
}

- (UIImageView *)centerImageView{
    if (_centerImageView == nil) {
        _centerImageView = [[UIImageView alloc] init];
        _centerImageView.image = [UIImage imageNamed:@"loading_bg"];
    }
    return _centerImageView;
}



@end
